
###install nginx-ingress
helm3 repo add stable https://kubernetes-charts.storage.googleapis.com
helm3 repo  list
kubectl create ns nginx-ingress
helm3 upgrade --install nginx-ingress stable/nginx-ingress --wait  --namespace=nginx-ingress --version=1.39.0

####install cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager-legacy.crds.yaml
kubectl create ns cert-manager
#kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
helm3 upgrade --install cert-manager jetstack/cert-manager --wait  --namespace=cert-manager --version=0.15.1
helm3 install cert-manager jetstack/cert-manager  --namespace cert-manager  --version v0.15.1 

###install chartmuseum
kubectl create ns chartmuseum
helm3 upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=2.13.0 -f kubernetes-templating/chartmuseum/values.yaml

###install harbor
kubectl create ns harbor
helm3 repo add harbor https://helm.goharbor.io
helm3 repo update
helm3 upgrade --install harbor harbor/harbor --wait --namespace=harbor-system --version=1.3.2 -f kubernetes-templating/harbor/values.yaml

chartmuseum | Задание со ⭐
Научимся работать с chartmuseum и зальем в наш репозиторий - примеру frontend
Добавяем наш репозитарий
helm repo add chartmuseum https://chartmuseum.35.189.202.237.nip.io/
"chartmuseum" has been added to your repositories
Проверяем линтером
helm lint
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
Пакуем
helm package .
Successfully packaged chart and saved it to: /Users/alexey/kovtalex_platform/kubernetes-templating/frontend/frontend-0.1.0.tgz

Заливаем
curl -L --data-binary "@frontend-0.1.0.tgz" https://chartmuseum.35.189.202.237.nip.io/api/charts
{"saved":true}
Обновляем список repo
helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "harbor" chart repository
...Successfully got an update from the "chartmuseum" chart repository
...Successfully got an update from the "templating" chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
Ищем наш frontend в репозитории
helm search repo -l chartmuseum/
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
chartmuseum/frontend    0.1.0           1.16.0          A Helm chart for Kubernetes
И выкатываем
helm upgrade --install frontend chartmuseum/frontend --namespace hipster-shop
Release "frontend" does not exist. Installing it now.
NAME: frontend
LAST DEPLOYED: Sat May 30 01:59:17 2020
NAMESPACE: hipster-shop
STATUS: deployed
REVISION: 1
TEST SUITE: None

