#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: support-view
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services", "configmaps", "nodes"]
  verbs: ["get", "list", "watch"]
EOF

kubectl create ns dev-ns || true
cat <<EOF | kubectl apply -f - -n dev-ns
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-ns
  name: developer-manage
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-manage
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
EOF

kubectl create ns secure-ns || true
cat <<EOF | kubectl apply -f - -n secure-ns
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: secure-ns
  name: security-access
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
EOF

echo "Роли созданы."