#!/bin/bash

export ROOT_DIR=/root
export WORK_DIR=$(pwd)
export REPO_DIR=$(pwd)/Binance-Futures-Signals
while getopts :u: flag
do
    case "${flag}" in
        u) export USUARIO=${OPTARG};;
    esac
done

[ -d "REPO_DIR" ] && mv $REPO_DIR-rollback
git clone https://github.com/lagoanova/Binance-Futures-Signals.git $ROOT_DIR

case $1 in
     -u|--user)      
          echo "Verificando se diretorio do usuario existe"
          if [ -d "$WORK_DIR/$USUARIO" ]; then

            cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
            echo "Finalizando instancia em execucao"
            export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO down
            [ -d "$WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback " ] && rm -rf $WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback 
            mv $WORK_DIR/$USUARIO/Binance-Futures-Signals $WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback
            
          else

            echo "Criando novo usuario $USUARIO"
            mkdir -v $WORK_DIR/$USUARIO

          fi
          cp -av $REPO_DIR $WORK_DIR/$USUARIO/
          echo "Copiando o arquivo do ambiente .env para o diretorio do usuario"
          cp -av $WORK_DIR/$USUARIO/.env $WORK_DIR/$USUARIO/Binance-Futures-Signals/
          cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
          echo "Iniciando instancia"
          export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO up -d
          ;;

     -a|--all)
          for i in $(ls); do
            cd $WORK_DIR/$i/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i down
            echo "O diretorio do usuario existe entao mova a diretorio atual para rollback e faca a capia do repo para o diretorio do usuario"
            [ -d "$WORK_DIR/$i/Binance-Futures-Signals-rollback " ] && rm -rf $WORK_DIR/$i/Binance-Futures-Signals-rollback 
            mv $WORK_DIR/$i/Binance-Futures-Signals $WORK_DIR/$i/Binance-Futures-Signals-rollback
            cp -av $REPO_DIR $WORK_DIR/$i/
            cp -av $WORK_DIR/$USUARIO/.env $WORK_DIR/$i/Binance-Futures-Signals/
            cd $WORK_DIR/$i/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i up -d
          done
          ;;
     *)
         echo "
         usage: 
         controle -u usuario para criar ou atualizar um usuario
         controle -a para atualizar todos os usuarios
         
         ";;
esac