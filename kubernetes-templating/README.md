
###install nginx-ingress
helm3 repo add stable https://kubernetes-charts.storage.googleapis.com
helm3 repo  list
kubectl create ns nginx-ingress
helm3 upgrade --install nginx-ingress stable/nginx-ingress --wait  --namespace=nginx-ingress --version=1.39.0

####install cert-manager
helm3 repo add jetstack https://charts.jetstack.io
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager-legacy.crds.yaml
kubectl create ns cert-manager
helm3 upgrade --install cert-manager jetstack/cert-manager --wait  --namespace=cert-manager --version=0.15.1
helm3 install cert-manager jetstack/cert-manager  --namespace cert-manager  --version v0.15.1 
kubectl apply -f cluster-issuer-prod.yaml
kkubectl apply -f cluster-issuer-stage.yaml

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

Создаем свой helm chart
helm create kubernetes-templating/hipster-shop
**********************************************************
Mы будем создавать chart для приложения с нуля, поэтому
удалите values.yaml и содержимое templates.
После этого перенесите https://github.com/express42/otus-platform-snippets/blob/master/Module-04/05-Templating/manifests/all-hipster-shop.yaml all-hipster-shop.yaml в
директорию templates.
*******************************************
kubectl create ns hipster-shop
helm3 upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop

helm create kubernetes-templating/frontend
**************************************************************************************
Аналогично чарту hipster-shop удалите файл values.yaml и
файлы в директории templates, создаваемые по умолчанию.
Выделим из файла all-hipster-shop.yaml манифесты для
установки микросервиса frontend.
В директории templates чарта frontend создайте файлы:
deployment.yaml - должен содержать соответствующую часть из
файла all-hipster-shop.yaml
service.yaml - должен содержать соответствующую часть из файла
all-hipster-shop.yaml
ingress.yaml - должен разворачивать ingress с доменным именем
shop.<IP-адрес>.nip.io
************************************************************
helm3 upgrade --install frontend kubernetes-templating/frontend --namespace hipster-shop

***********************************************************
Как должен выглядеть минимальный итоговый файл
values.yaml:
image:
tag: v0.1.3
replicas: 1
service:
type: NodePort
port: 80
targetPort: 8079
NodePort: 30001
*******************************************************************

Добавьте chart frontend как зависимость
Обновим зависимости:
При указании зависимостей в старом формате, все будет
работать, единственное выдаст предупреждение. Подробнее
dependencies:
- name: frontend
version: 0.1.0
repository: "file://../frontend"

helm dep update kubernetes-templating/hipster-shop