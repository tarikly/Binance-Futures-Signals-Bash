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


case $1 in
     -u|--user)
          mv $REPO_DIR $REPO_DIR/Binance-Futures-Signals-rollback
          #echo "Clonando repositório"
          #echo "git clone https://github.com/lagoanova/Binance-Futures-Signals.git"
          git clone https://github.com/lagoanova/Binance-Futures-Signals.git $ROOT_DIR
          echo "Verificando se diretório do usuário existe"
          if [ -d "$WORK_DIR/$USUARIO" ]; then

            cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
            echo "Finalizando instância em execução"
            export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO down
            [ -d "$WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback " ] && rm -rf $WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback 
            mv $WORK_DIR/$USUARIO/Binance-Futures-Signals $WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback
            
          else

            echo "Criando novo usuário $USUARIO"
            mkdir -v $WORK_DIR/$USUARIO

          fi
          cp -av $REPO_DIR $WORK_DIR/$USUARIO/
          echo "Copiando o arquivo do ambiente .env para o diretorio do usuário"
          cp -av $WORK_DIR/$USUARIO/.env $WORK_DIR/$USUARIO/Binance-Futures-Signals/
          cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
          echo "Iniciando instância"
          export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO up -d
          ;;

     -a|--all)
          for i in $(ls); do
            cd $WORK_DIR/$i/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i down
            echo "O diretório do usuário existe então mova a diretorio atual para rollback e faça a cópia do repo para o diretorio do usuário"
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
         controle -u usuario para criar ou atualizar um usuário
         controle -a para atualizar todos os usuários
         
         ";;
esac