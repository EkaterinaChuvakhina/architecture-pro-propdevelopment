#!/bin/bash

kubectl create clusterrolebinding support-view-binding --clusterrole=support-view --group=support-group --user=user-support
kubectl create rolebinding developer-manage-binding --role=developer-manage --group=developers-group --user=user-dev -n dev-ns
kubectl create clusterrolebinding security-manage-binding --clusterrole=security-manage --group=security-group --user=user-sec
kubectl create rolebinding security-access-binding --role=security-access --group=security-group --user=user-sec -n secure-ns
