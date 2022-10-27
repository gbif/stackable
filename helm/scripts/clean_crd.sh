#!/bin/bash
kubectl get crd | awk '/stackable.tech/{print $1}' | xargs kubectl delete crd 