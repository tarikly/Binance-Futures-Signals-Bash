#!/bin/bash

export ROOT_DIR=/root
export WORK_DIR=$(pwd)
export REPO_DIR=$ROOT_DIR/Binance-Futures-Signals
export GITHUB_USERNAME=nomedousuario
export GITHUB_PASSWORD=senhadousuario
export REPO_URL=github.com/lagoanova/Binance-Futures-Signals.git

while getopts :u: flag
do
    case "${flag}" in
        u) export USUARIO=${OPTARG};;
    esac
done

[ -d "$REPO_DIR-rollback" ] && mv $REPO_DIR-rollback $REPO_DIR-bkp-$(date '+%d-%m-%Y_%H-%M') 2> /dev/null
[ -d "$REPO_DIR" ] && mv $REPO_DIR $REPO_DIR-rollback 2> /dev/null

git clone https://$GITHUB_USERNAME:$GITHUB_PASSWORD@$REPO_URL  $REPO_DIR && echo Repositorio Clonado!

case $1 in
     -u|--user)
          echo "Verificando se diretorio do usuario existe"
          if [ -d "$WORK_DIR/$USUARIO" ]; then

            cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
            echo "Finalizando instancia em execucao"
            export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO down
            docker rmi $(docker images | grep "$USUARIO " | awk '{print $3}')
            [ -d "$WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback " ] && rm -rf $WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback 2> /dev/null
            mv $WORK_DIR/$USUARIO/Binance-Futures-Signals $WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback 2> /dev/null

          else

            echo "
            Usuario nao encontrado!
            Crie o diretorio $WORK_DIR/$USUARIO e o arquivo $WORK_DIR/$USUARIO/.env do ambiente da app." && exit 1

          fi

          cp -av $REPO_DIR $WORK_DIR/$USUARIO/ && echo "Repositorio copiado para o diretorio do usuario: $USUARIO"
          echo "Copiando o arquivo do ambiente .env para o diretorio do usuario: $USUARIO"
          cp -av $WORK_DIR/$USUARIO/.env $WORK_DIR/$USUARIO/Binance-Futures-Signals/
          cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
          echo "Iniciando instancia"
          export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO up -d
          ;;

     -a|--all)
          for i in $(ls); do
            cd $WORK_DIR/$i/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i down
            docker rmi $(docker images | grep "$i " | awk '{print $3}')
            echo "O diretorio do usuario existe entao mova a diretorio atual para rollback e faca a capia do repo para o diretorio do usuario"
            [ -d "$WORK_DIR/$i/Binance-Futures-Signals-rollback " ] && rm -rf $WORK_DIR/$i/Binance-Futures-Signals-rollback 
            mv $WORK_DIR/$i/Binance-Futures-Signals $WORK_DIR/$i/Binance-Futures-Signals-rollback
            cp -av $REPO_DIR $WORK_DIR/$i/
            cp -av $WORK_DIR/$i/.env $WORK_DIR/$i/Binance-Futures-Signals/
            cd $WORK_DIR/$i/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i up -d
          done
          ;;
      -r|--rollback)
          if [[ ! -z USUARIO ]];
          then
            echo variavel nao existe!
            for i in $(ls); do
              cd $WORK_DIR/$i/Binance-Futures-Signals
              echo "Finalizando instancia em execucao"
              export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i down
              docker rmi $(docker images | grep "$i " | awk '{print $3}')
              cd $WORK_DIR/$i
              rm -rf $WORK_DIR/$i/Binance-Futures-Signals
              [ -d "$WORK_DIR/$i/Binance-Futures-Signals-rollback " ] && mv $WORK_DIR/$i/Binance-Futures-Signals
              cd $WORK_DIR/$i/Binance-Futures-Signals
              export TAG="`git rev-parse --short=10 HEAD`-$i" && docker compose --project-name $i up -d
            done

          else
            echo variavel existe!
            cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
            echo "Finalizando instancia em execucao"
            export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO down
            docker rm  $(docker container ls -qa --filter name=$USUARIO*)
            docker rmi $(docker images | grep "$USUARIO " | awk '{print $3}')
            cd $WORK_DIR/$USUARIO
            rm -rf $WORK_DIR/$USUARIO/Binance-Futures-Signals
            [ -d "$WORK_DIR/$USUARIO/Binance-Futures-Signals-rollback " ] && mv $WORK_DIR/$USUARIO/Binance-Futures-Signals
            cd $WORK_DIR/$USUARIO/Binance-Futures-Signals
            export TAG="`git rev-parse --short=10 HEAD`-$USUARIO" && docker compose --project-name $USUARIO up -d
          fi

        ;;
     *)
         echo "
         usage: 
         controle -u usuario para criar ou atualizar um usuario
         controle -a para atualizar todos os usuarios

         ";;
esac
