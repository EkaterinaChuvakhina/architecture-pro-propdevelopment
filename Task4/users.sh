#!/bin/bash

USER_NAME="user-support"
GROUP="support-group"

openssl genrsa -out ${USER_NAME}.key 2048
openssl req -new -key ${USER_NAME}.key -out ${USER_NAME}.csr -subj "/CN=${USER_NAME}/O=${GROUP}"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USER_NAME}
spec:
  request: $(cat ${USER_NAME}.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages: ["client auth"]
EOF

kubectl certificate approve ${USER_NAME}
kubectl get csr ${USER_NAME} -o jsonpath='{.status.certificate}' | base64 --decode > ${USER_NAME}.crt

kubectl config set-credentials ${USER_NAME} --client-certificate=${USER_NAME}.crt --client-key=${USER_NAME}.key
kubectl config set-context ${USER_NAME}-context --cluster=your-cluster-name --user=${USER_NAME}

echo "Пользователь ${USER_NAME} создан."