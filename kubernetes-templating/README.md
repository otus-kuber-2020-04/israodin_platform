
###install nginx-ingress
helm3 repo add stable https://kubernetes-charts.storage.googleapis.com
helm3 repo  list
kubectl create ns nginx-ingress
helm3 upgrade --install nginx-ingress stable/nginx-ingress --wait  --namespace=nginx-ingress --version=1.39.0

####install cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager-legacy.yaml
kubectl create ns cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
helm3 upgrade --install cert-manager jetstack/cert-manager --wait  --namespace=cert-manager --version=0.15.1
helm3 install cert-manager jetstack/cert-manager  --namespace cert-manager  --version v0.15.1 

###install chartmuseum
kubectl create ns chartmuseum
helm3 upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=2.13.0 -f kubernetes-templating/chartmuseum/values.yaml

###install harbor
helm3 repo add harbor https://helm.goharbor.io
helm3 update repo
helm3 upgrade --install harbor harbor/harbor --wait --namespace=harbor-system --version=1.3.2 -f kubernetes-templating/harbor/values.yaml

