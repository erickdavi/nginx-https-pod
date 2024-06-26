#!/bin/bash

VARS_FILE="./.vars"
if [ -f ${VARS_FILE} ]
then
 source ${VARS_FILE}
else
  echo "Crie o arquivo de variáveis ${VARS_FILE} e inicialize suas variáveis"
  exit 1
fi


deploy(){
  kubectl apply -f ./nginx-config.yaml
  envsubst < nginx-secret.yaml | kubectl apply -f -
  kubectl apply -f ./nginx-https-pod.yaml
  kubectl apply -f ./nginx-service.yaml
  sleep 5
  kubectl get cm,secret,pod,svc
}
undeploy(){
  kubectl delete -f ./nginx-config.yaml
  kubectl delete -f ./nginx-secret.yaml
  kubectl delete -f ./nginx-https-pod.yaml
  kubectl delete -f ./nginx-service.yaml
  sleep 5
  kubectl get cm,secret,pod,svc
}

case $1 in

  'deploy')
    deploy
  ;;
  'undeploy')
    undeploy
  ;;
  'pub')
    kubectl port-forward service/nginx-https 443:443 &
  ;;
  'unpub')
    kill -9 $(ps -ef | awk '!/awk/ && /kubectl port-forward/ {print $2}')
  ;;
  *)
    echo "Invalid Option"
esac
