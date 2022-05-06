#!/bin/bash

export BASE_DIR=$(pwd)
export REPO_DIR=$(pwd)/Binance-Futures-Signals
while getopts :u: flag
do
    case "${flag}" in
        u) export USUARIO=${OPTARG};;
    esac
done


case $1 in
     -u|--user)
          #mv $REPO_DIR $REPO_DIR/Binance-Futures-Signals-rollback
          #echo "Clonando repositório"
          #echo "git clone https://github.com/lagoanova/Binance-Futures-Signals.git"
          #git clone https://github.com/lagoanova/Binance-Futures-Signals.git
          echo "Verificando se diretório do usuário existe"
          if [ -d "$BASE_DIR/$USUARIO" ]; then

            cd $BASE_DIR/$USUARIO/Binance-Futures-Signals
            echo "Finalizando instância em execução"
            export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO down
            [ -d "$BASE_DIR/$USUARIO/Binance-Futures-Signals-rollback " ] && rm -rf $BASE_DIR/$USUARIO/Binance-Futures-Signals-rollback 
            mv $BASE_DIR/$USUARIO/Binance-Futures-Signals $BASE_DIR/$USUARIO/Binance-Futures-Signals-rollback
            
          else

            echo "Criando novo usuário $USUARIO"
            mkdir -v $BASE_DIR/$USUARIO

          fi
          cp -av $REPO_DIR $BASE_DIR/$USUARIO/
          echo "Copiando o arquivo do ambiente .env para o diretorio do usuário"
          cp -av $BASE_DIR/$USUARIO/.env $BASE_DIR/$USUARIO/Binance-Futures-Signals/
          cd $BASE_DIR/$USUARIO/Binance-Futures-Signals
          echo "Iniciando instância"
          export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO up -d
          ;;

     -a|--all)
          for i in $(ls); do
            cd $BASE_DIR/$i/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i down
            echo "O diretório do usuário existe então mova a diretorio atual para rollback e faça a cópia do repo para o diretorio do usuário"
            [ -d "$BASE_DIR/$i/Binance-Futures-Signals-rollback " ] && rm -rf $BASE_DIR/$i/Binance-Futures-Signals-rollback 
            mv $BASE_DIR/$i/Binance-Futures-Signals $BASE_DIR/$i/Binance-Futures-Signals-rollback
            cp -av $REPO_DIR $BASE_DIR/$i/
            cp -av $BASE_DIR/$USUARIO/.env $BASE_DIR/$i/Binance-Futures-Signals/
            cd $BASE_DIR/$i/Binance-Futures-Signals
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