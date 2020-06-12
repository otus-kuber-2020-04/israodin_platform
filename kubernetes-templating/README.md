
###install nginx-ingress
helm3 repo add stable https://kubernetes-charts.storage.googleapis.com
helm3 repo  list
kubectl create ns nginx-ingress
helm3 upgrade --install nginx-ingress stable/nginx-ingress --wait  --namespace=nginx-ingress--version=1.11.1

####install cert-manager
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release- 0.9/deploy/manifests/00-crds.yaml
kubectl create ns cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
helm upgrade --install cert-manager jetstack/cert-manager --wait  --namespace=cert-manager --version=0.9.0

Перед началом работы над домашним заданием вам
необходимо:
1. Любым удобным способом (через web console, через gcloud, с
использованием terraform) создать managed kubernetes кластер в
облаке GCP
2. Настроить kubectl на локальной машине:

gcloud beta container clusters get-credentials ...

❗ В данной домашней работе конфигурация кластера не
имеет принципиального значения, можно использовать
параметры по умолчанию

Избавляем бизнес от ИТ-зависимости

2 . 7

Устанавливаем готовые Helm charts

Попробуем установить Helm charts созданные сообществом. С
их помощью создадим и настроим инфраструктурные сервисы,
необходимые для работы нашего кластера.
Для установки будем использовать Helm 3

Избавляем бизнес от ИТ-зависимости

3 . 1

Устанавливаем готовые Helm charts

Сегодня будем работать со следующими сервисами:

- сервис, обеспечивающий доступ к публичным

ресурсам кластера

- сервис, позволяющий динамически генерировать

Let's Encrypt сертификаты для ingress ресурсов

- специализированный репозиторий для хранения

helm charts

- хранилище артефактов общего назначения (Docker

Registry), поддерживающее helm charts
###nginx-ingress
helm3 install nginx-ingress stable/nginx-ingress

###cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager-legacy.crds.yaml
helm3 repo add jetstack https://charts.jetstack.io
helm3 install cert-manager --namespace cert-manager jetstack/cert-manager

###chartmuseum
helm3 install my-chartmuseum -f custom.yaml stable/chartmuseum

###harbor
helm3 repo add harbor https://helm.goharbor.io
helm3 install harbor harbor/harbor


Избавляем бизнес от ИТ-зависимости

3 . 2

Подготовка

Для начала нам необходимо установить Helm 3 на локальную
машину.
Инструкции по установке можно найти по
Скачайте binary файл для вашей OS и
поместите его в $PATH
Критерий успешности установки - после выполнения команды:

Ожидается следующий вывод:

ссылке

последний доступный

helm version

version.BuildInfo{Version:"v3.0.2",
GitCommit:"19e47ee3283ae98139d98460de796c1be1e3975f", GitTreeState:"clean",
GoVersion:"go1.13.5"}

Избавляем бизнес от ИТ-зависимости

3 . 3

Памятка по использованию Helm

Создание release:

Обновление release:

Создание или обновление release:
$ helm install <chart_name> --name=<release_name> --namespace=<namespace>
$ kubectl get secrets -n <namespace> | grep <release_name>
sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m

$ helm upgrade <release_name> <chart_name> --namespace=<namespace>
$ kubectl get secrets -n <namespace> | grep <release_name>
sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
sh.helm.release.v1.<release_name>.v2 helm.sh/release.v1 1 56m

$ helm upgrade --install <release_name> <chart_name> --namespace=<namespace>
$ kubectl get secrets -n <namespace> | grep <release_name>
sh.helm.release.v1.<release_name>.v1 helm.sh/release.v1 1 115m
sh.helm.release.v1.<release_name>.v2 helm.sh/release.v1 1 56m
sh.helm.release.v1.<release_name>.v3 helm.sh/release.v1 1 5s

Избавляем бизнес от ИТ-зависимости

3 . 4

Add helm repo

Добавьте репозиторий stable
По умолчанию в Helm 3 не установлен репозиторий stable

helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo list
NAME URL
stable https://kubernetes-charts.storage.googleapis.com

Избавляем бизнес от ИТ-зависимости

3 . 5

nginx-ingress

Создадим namespace и release nginx-ingress

Разберем используемые ключи:
--wait - ожидать успешного окончания установки ( )
--timeout - считать установку неуспешной по истечении
указанного времени
--namespace - установить chart в определенный namespace (если
не существует, необходимо создать)
--version - установить определенную версию chart
kubectl create ns nginx-ingress
helm upgrade --install nginx-ingress stable/nginx-ingress --wait \
--namespace=nginx-ingress \
--version=1.11.1

подробности

Избавляем бизнес от ИТ-зависимости

3 . 6

cert-manager

Добавим репозиторий, в котором хранится актуальный helm
chart cert-manager:

Также для установки cert-manager предварительно потребуется
создать в кластере некоторые CRD ( на документацию по
установке):

Еще одна подготовка, описанная в документации:
helm repo add jetstack https://charts.jetstack.io

ссылка

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-
0.9/deploy/manifests/00-crds.yaml

kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"

Избавляем бизнес от ИТ-зависимости

3 . 7

cert-manager

Установим cert-manager:

helm upgrade --install cert-manager jetstack/cert-manager --wait \
--namespace=cert-manager \
--version=0.9.0

Избавляем бизнес от ИТ-зависимости

3 . 8

cert-manager

Самостоятельное задание

Изучите cert-manager, и определите, что еще
требуется установить для корректной работы
Поместите манифесты дополнительно созданных ресурсов в
директорию kubernetes-templating/cert-manager/
Проверить корректную работу cert-manager можно будет на
последующих helm chart
документацию

Избавляем бизнес от ИТ-зависимости

3 . 9

chartmuseum

Кастомизируем установку chartmuseum
Создайте директорию kubernetes-templating/chartmuseum/ и
поместите туда файл values.yaml
Изучите оригинального файла values.yaml
Включите:

Создание ingress ресурса с корректным hosts.name (должен
использоваться nginx-ingress)
Автоматическую генерацию Let's Encrypt сертификата
содержимое

https://github.com/helm/charts/tree/master/stable/chartmuseum

Избавляем бизнес от ИТ-зависимости

3 . 10

chartmuseum

Файл values.yaml для chartmuseum будет выглядеть примерно
следующим образом:

ingress:
enabled: true
annotations:
kubernetes.io/ingress.class: nginx
kubernetes.io/tls-acme: "true"
certmanager.k8s.io/cluster-issuer: "letsencrypt-production"
certmanager.k8s.io/acme-challenge-type: http01
hosts:
- name: chartmuseum.example.com
path: /
tls: true
tlsSecret: chartmuseum.example.com

Вместо example.com укажите EXTERNAL-IP сервиса вашего
nginx-ingress в формате <IP-адрес.nip.io>, например
1.1.1.1.nip.io

Избавляем бизнес от ИТ-зависимости

3 . 11

chartmuseum

Установим chartmuseum:

Проверим, что release chartmuseum установился:
kubectl create ns chartmuseum
helm upgrade --install chartmuseum stable/chartmuseum --wait \
--namespace=chartmuseum \
--version=2.3.2 \
-f kubernetes-templating/chartmuseum/values.yaml

helm ls -n chartmuseum

Избавляем бизнес от ИТ-зависимости

3 . 12

chartmuseum

helm 2 хранил информацию о релизе в configMap'ах (kubectl
get configmaps -n kube-system).
А Helm 3 хранит информацию в secrets (kubectl get secrets -
n chartmuseum).

Избавляем бизнес от ИТ-зависимости

3 . 13

chartmuseum

Критерий успешности установки

Chartmuseum доступен по URL https://chartmuseum.
<IP>.nip.io
Сертификат для данного URL валиден

Избавляем бизнес от ИТ-зависимости

3 . 14

chartmuseum | Задание со ⭐

Научитесь работать с chartmuseum
Опишите в PR последовательность действий, необходимых для
добавления туда helm chart's и их установки с использованием
chartmuseum как репозитория

Избавляем бизнес от ИТ-зависимости

3 . 15

harbor

Самостоятельное задание

Установите harbor в кластер с использованием helm3
Используйте репозиторий
и CHART VERSION 1.1.2
Требования:

Должен быть включен ingress и настроен host harbor.<IP-
адрес>.nip.io

Должен быть включен TLS и выписан валидный сертификат
Скопируйте используемый файл values.yaml в директорию
kubernetes-templating/harbor/

https://github.com/goharbor/harbor-helm

Избавляем бизнес от ИТ-зависимости

3 . 16

harbor

Tips & Tricks

Формат описания переменных в файле values.yaml для
chartmuseum и harbor отличается
Helm3 не создает namespace в который будет установлен release
Проще выключить сервис notary, он нам не понадобится
Реквизиты по умолчанию - admin/Harbor12345
nip.io может оказаться забанен в cert-manager. Если у вас есть
собственный домен - лучше использовать его, либо попробовать
xip.io, либо переключиться на staging ClusterIssuer
Обратите внимание, как helm3 хранит информацию о release:
kubectl get secrets -n harbor -l owner=helm

Избавляем бизнес от ИТ-зависимости

3 . 17

harbor

Критерий успешности установки

Harbor запущен и работает
Предъявленные требования выполняются

Избавляем бизнес от ИТ-зависимости

3 . 18

Используем helmfile | Задание со ⭐
Опишите установку nginx-ingress, cert-manager и harbor в
helmfile
Приложите получившийся helmfile.yaml и другие файлы (при
их наличии) в директорию kubernetes-templating/helmfile

Избавляем бизнес от ИТ-зависимости

3 . 19

Создаем свой helm chart

Избавляем бизнес от ИТ-зависимости

4 . 1

Создаем свой helm chart

Типичная жизненная ситуация:
У вас есть приложение, которое готово к запуску в Kubernetes
У вас есть манифесты для этого приложения, но вам надо
запускать его на разных окружениях с разными параметрами
Возможные варианты решения:
Написать разные манифесты для разных окружений
Использовать "костыли" - sed, envsubst, etc...
Использовать полноценное решение для шаблонизации (helm,
etc...)

Избавляем бизнес от ИТ-зависимости

4 . 2

Создаем свой helm chart
Мы рассмотрим третий вариант. Возьмем готовые манифесты и
подготовим их к релизу на разные окружения.
Использовать будем демо-приложение ,
представляющее собой типичный набор микросервисов.
Стандартными средствами helm инициализируйте структуру
директории с содержимым будущего helm chart

hipster-shop

helm create kubernetes-templating/hipster-shop

Избавляем бизнес от ИТ-зависимости

4 . 3

Создаем свой helm chart

Изучите созданный в качестве примера файл values.yaml и
шаблоны в директории templates, примерно так выглядит
стандартный helm chart.
Мы будем создавать chart для приложения с нуля, поэтому
удалите values.yaml и содержимое templates.
После этого перенесите all-hipster-shop.yaml в
директорию templates.

файл

Избавляем бизнес от ИТ-зависимости

4 . 4

Создаем свой helm chart

В целом, helm chart уже готов, вы можете попробовать
установить его:

После этого можно зайти в UI используя сервис типа NodePort
(создается из манифестов) и проверить, что приложение
заработало.
kubectl create ns hipster-shop
helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace
hipster-shop

Избавляем бизнес от ИТ-зависимости

4 . 5

Создаем свой helm chart
Сейчас наш helm chart hipster-shop совсем не похож на
настоящий. При этом, все микросервисы устанавливаются из
одного файла all-hipster-shop.yaml
Давайте исправим это и первым делом займемся
микросервисом frontend. Скорее всего он разрабатывается
отдельной командой, а исходный код хранится в отдельном
репозитории.
Поэтому, было бы логично вынести все что связано с frontend в
отдельный helm chart.
Создадим заготовку:

helm create kubernetes-templating/frontend

Избавляем бизнес от ИТ-зависимости

4 . 6

Создаем свой helm chart

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

Манифест для ingress необходимо написать самостоятельно
Избавляем бизнес от ИТ-зависимости

4 . 7

Создаем свой helm chart

После того, как вынесете описание deployment и service для
frontend из файла all-hipster-shop.yaml переустановите chart
hipster-shop и проверьте, что доступ к UI пропал и таких ресурсов
больше нет.
Установите chart frontend в namespace hipster-shop и проверьте
что доступ к UI вновь появился:

helm upgrade --install frontend kubernetes-templating/frontend --namespace hipster-shop

Избавляем бизнес от ИТ-зависимости

4 . 8

Создаем свой helm chart

Пришло время минимально шаблонизировать наш chart frontend
Для начала продумаем структуру файла values.yaml
Docker образ из которого выкатывается frontend может
пересобираться, поэтому логично вынести его тег в переменную
frontend.image.tag
В values.yaml это будет выглядеть следующим образом:

image:
tag: v0.1.3

❗Это значение по умолчанию и может (и должно быть) быть
переопределено в CI/CD pipeline

Избавляем бизнес от ИТ-зависимости

4 . 9

Создаем свой helm chart

Теперь в манифесте deployment.yaml надо указать, что мы
хотим использовать это переменную.
Было:

Стало:
image: gcr.io/google-samples/microservices-demo/frontend:v0.1.3

image: gcr.io/google-samples/microservices-demo/frontend:{{ .Values.image.tag }}

Попробуйте обновить chart и убедиться, что ничего не
изменилось

Избавляем бизнес от ИТ-зависимости

4 . 10

Создаем свой helm chart

Аналогичным образом шаблонизируйте следующие параметры
frontend chart
Количество реплик в deployment
Port, targetPort и NodePort в service
Опционально - тип сервиса. Ключ NodePort должен появиться в
манифесте только если тип сервиса - NodePort
Другие параметры, которые на ваш взгляд стои шаблонизировать
❗Не забывайте указывать в файле values.yaml значения по
умолчанию

Избавляем бизнес от ИТ-зависимости

4 . 11

Создаем свой helm chart
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

Избавляем бизнес от ИТ-зависимости

4 . 12

Создаем свой helm chart
Теперь наш frontend стал немного похож на настоящий helm
chart. Не стоит забывать, что он все еще является частью одного
большого микросервисного приложения hipster-shop.
Поэтому было бы неплохо включить его в зависимости этого
приложения.
Для начала, удалите release frontend из кластера:

helm delete frontend -n hipster-shop

Избавляем бизнес от ИТ-зависимости

4 . 13

Создаем свой helm chart

В Helm 2 файл requirements.yaml содержал список
зависимостей helm chart (другие chart). В Helm 3 список
зависимостей рекомендуют объявлять в файле Chart.yaml.

Добавьте chart frontend как зависимость

Обновим зависимости:
При указании зависимостей в старом формате, все будет
работать, единственное выдаст предупреждение. Подробнее

dependencies:
- name: frontend
version: 0.1.0
repository: "file://../frontend"

helm dep update kubernetes-templating/hipster-shop

Избавляем бизнес от ИТ-зависимости

4 . 14

Создаем свой helm chart

В директории kubernetes-templating/hipster-shop/charts
появился архив frontend-0.1.0.tgz содержащий chart frontend
определенной версии и добавленный в chart hipster-shop как
зависимость.
Обновите release hipster-shop и убедитесь, что ресурсы frontend
вновь созданы.

Избавляем бизнес от ИТ-зависимости

4 . 15

Создаем свой helm chart
Осталось понять, как из CI-системы мы можем менять
параметры helm chart, описанные в values.yaml.
Для этого существует специальный ключ --set
Изменим NodePort для frontend в release, не меняя его в самом
chart:

helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace
hipster-shop --set frontend.service.NodePort=31234

Так как как мы меняем значение переменной для зависимости - перед
названием переменной указываем имя (название chart) этой зависимости.
Если бы мы устанавливали chart frontend напрямую, то команда выглядела
бы как --set service.NodePort=31234

Избавляем бизнес от ИТ-зависимости

4 . 16

Создаем свой helm chart | Задание со ⭐

Выберите сервисы, которые можно установить как зависимости,
используя community chart's.
Например, это может быть Redis.
Реализуйте их установку через requirements.yaml и
обеспечьте сохранение работоспособности приложения.

Избавляем бизнес от ИТ-зависимости

4 . 17

Работа с helm-secrets | Необязательное
задание

Разберемся как работает плагин helm-secrets. Для этого
добавим в Helm chart секрет и научимся хранить его в
зашифрованном виде.
Начнем с того, что установим плагин и необходимые для него
зависимости (здесь и далее инструкции приведены для MacOS):

brew install sops
brew install gnupg2
brew install gnu-getopt
helm plugin install https://github.com/futuresimple/helm-secrets --version 2.0.2

В домашней работы мы будем использовать PGP, но никто не
запрещает самостоятельно попробовать повторить задание
с KMS 😊

Избавляем бизнес от ИТ-зависимости

5 . 1

Работа с helm-secrets | Необязательное
задание

Сгенерируем новый PGP ключ:

Ответьте на все вопросы. После этого командой gpg -k можно
проверить, что ключ появился:
gpg --full-generate-key

$ gpg -k
/Users/vegas/.gnupg/pubring.kbx
-------------------------------
pub rsa2048 2019-09-15 [SC]
B086BD636EBD989F87399DD22B929BDEC3CFE7EC
uid [ultimate] otusdemo <otusdemo@express42.com>
sub rsa2048 2019-09-15 [E]

Избавляем бизнес от ИТ-зависимости

5 . 2

Работа с helm-secrets | Необязательное
задание

Создадим новый файл secrets.yaml в директории kubernetes-
templating/frontend со следующим содержимым:

И попробуем зашифровать его:
visibleKey: hiddenValue

sops -e -i --pgp <$ID> secrets.yaml

Примечание - вместо ID подставьте длинный хеш, в выводе
на предыдущей странице это
B086BD636EBD989F87399DD22B929BDEC3CFE7EC

Избавляем бизнес от ИТ-зависимости

5 . 3

Работа с helm-secrets | Необязательное
задание

Проверьте, что файл secrets.yaml изменился. Сейчас его
содержание должно выглядеть примерно так:

visibleKey:
ENC[AES256_GCM,data:N/ZmTE2PoaFn1qI=,iv:raG0p01sjoG/bSo9LM9NbzgxKuLCI3QMMfjsT1RYvbU=,tag
:2bI3zG8++m9Fo8d85caFaw==,type:str]
sops:
kms: []
gcp_kms: []
azure_kv: []
lastmodified: '2019-09-19T12:55:33Z'
...

Заметьте, что структура файла осталась прежней. Мы видим
ключ visibleKey, но его значение зашифровано

Избавляем бизнес от ИТ-зависимости

5 . 4

Работа с helm-secrets | Необязательное
задание
В таком виде файл уже можно коммитить в Git, но для начала -
научимся расшифровывать его.
Можно использовать любой из инструментов:

# helm secrets
helm secrets view secrets.yaml
# sops
sops -d secrets.yaml

Избавляем бизнес от ИТ-зависимости

5 . 5

Работа с helm-secrets | Необязательное
задание
Теперь осталось понять, как добавить значение нашего секрета
в настоящий секрет kubernetes и устанавливать его вместе с
основным helm chart.

Создайте в директории kubernetes-
templating/frontend/templates еще один файл secret.yaml.

Несмотря на похожее название его предназначение будет
отличаться.
Поместите туда следующий шаблон:

apiVersion: v1
kind: Secret
metadata:
name: secret
type: Opaque
data:
visibleKey: {{ .Values.visibleKey | b64enc | quote }}

Избавляем бизнес от ИТ-зависимости

5 . 6

Работа с helm-secrets | Необязательное
задание

Теперь, если мы передадим в helm файл secrets.yaml как
values файл - плагин helm-secrets поймет, что его надо
расшифровать, а значение ключа visibleKey подставить в
соответствующий шаблон секрета.
Запустим установку:

helm secrets upgrade --install frontend kubernetes-templating/frontend --namespace
hipster-shop \
-f kubernetes-templating/frontend/values.yaml \
-f kubernetes-templating/frontend/secrets.yaml

В процессе установки helm-secrets расшифрует наш
секретный файл в другой временный файл
secrets.yaml.dec, а после выполнения установки - удалит
его Избавляем бизнес от ИТ-зависимости

5 . 7

Работа с helm-secrets | Необязательное
задание

Проверьте, что секрет создан, и его содержимое соответствует
нашим ожиданиям
Предложите способ использования плагина helm-secrets в CI/CD
Про что необходимо помнить, если используем helm-secrets
(например, как обезопасить себя от коммита файлов с секретами,
которые забыл зашифровать)?
Если вы попробовали использовать helm-secrets с KMS - опишите
результаты своей работы

Избавляем бизнес от ИТ-зависимости

5 . 8

Проверка
Поместите все получившиеся helm chart's в ваш установленный
harbor в публичный проект.
Создайте файл kubernetes-templating/repo.sh со следующим
содержанием:

После исполнения этого файла должен появляться
репозиторий, из которого можно установить следующие helm
chart's:
templating/frontend
templating/hipster-shop
#!/bin/bash
helm repo add templating <Ссылка на ваш репозиторий>

Избавляем бизнес от ИТ-зависимости

6

Kubecfg

Избавляем бизнес от ИТ-зависимости

7 . 1

Kubecfg
Представим, что одна из команд разрабатывающих сразу
несколько микросервисов нашего продукта решила, что helm не
подходит для ее нужд и попробовала использовать решение на
основе jsonnet - kubecfg.
Посмотрим на возможности этой утилиты. Работать будем с
сервисами paymentservice и shippingservice.
Для начала - вынесите манифесты описывающие service и

deployment для этих микросервисов из файла all-hipster-
shop.yaml в директорию kubernetes-templating/kubecfg

Избавляем бизнес от ИТ-зависимости

7 . 2

Kubecfg

В итоге должно получиться четыре файла:

Можно заметить, что манифесты двух микросервисов очень
похожи друг на друга и может иметь смысл генерировать их из
какого-то шаблона. Попробуем сделать это.
$ tree -L 1 kubecfg
kubecfg
├── paymentservice-deployment.yaml
├── paymentservice-service.yaml
├── shippingservice-deployment.yaml
└── shippingservice-service.yaml

Обновите release hipster-shop, проверьте что
микросервисы paymentservice и shippingservice исчезли
из установки и магазин стал работать некорректно (при
нажатии на кнопку Add to Cart)

Избавляем бизнес от ИТ-зависимости

7 . 3

Kubecfg

Установите (доступна в виде сборок по MacOS и Linux и
в Homebrew)

kubecfg

$ kubecfg version
kubecfg version: v0.14.0
jsonnet version: v0.14.0
client-go version: v0.0.0-master+2d32dcd

Избавляем бизнес от ИТ-зависимости

7 . 4

Kubecfg
Kubecfg предполагает хранение манифестов в файлах формата
.jsonnet и их генерацию перед установкой. Пример такого файла
можно найти в
Напишем по аналогии свой .jsonnet файл - services.jsonnet.
Для начала в файле мы должны указать libsonnet библиотеку,
которую будем использовать для генерации манифестов. В
домашней работе воспользуемся
Импортируем ее:

официальном репозитории

готовой от bitnami

local kube = import "https://github.com/bitnami-labs/kube-
libsonnet/raw/52ba963ca44f7a4960aeae9ee0fbee44726e481f/kube.libsonnet";

Избавляем бизнес от ИТ-зависимости

7 . 5

Kubecfg

Перейдем к основной части
Общая логика происходящего следующая:
1. Пишем общий для сервисов , включающий описание
service и deployment
2. от него, указывая параметры для конкретных
сервисов

шаблон

Наследуемся

❗ Рекомендуем не заглядывать в сниппеты в ссылках и
попробовать самостоятельно разобраться с jsonnet
В качестве подсказки можно использовать и готовый
services.jsonnet, который должен выглядеть примерно
следующим образом

Избавляем бизнес от ИТ-зависимости

7 . 6

Kubecfg

Проверим, что манифесты генерируются корректно:

И установим их:

Через какое-то время магазин снова должен заработать и
товары можно добавить в корзину
kubecfg show services.jsonnet

kubecfg update services.jsonnet --namespace hipster-shop

Избавляем бизнес от ИТ-зависимости

7 . 7

Задание со ⭐

Выберите еще один микросервис из состава hipster-shop и
попробуйте использовать другое решение на основе jsonnet,
например или
Приложите артефакты их использования в директорию
kubernetes-templating/jsonnet и опишите проделанную работу и
порядок установки.

Kapitan qbec

Избавляем бизнес от ИТ-зависимости

7 . 8

Kustomize

Избавляем бизнес от ИТ-зависимости

8 . 1

Kustomize | Самостоятельное задание

Отпилите еще один (любой) микросервис из all-hipster-
shop.yaml.yaml и самостоятельно займитесь его kustomизацией.

В минимальном варианте достаточно реализовать установку на
два окружения - hipster-shop (namespace hipster-shop) и
hipster-shop-prod (namespace hipster-shop-prod) из одних
манифестов deployment и service.
Окружения должны отличаться:
Набором labels во всех манифестах
Префиксом названий ресурсов
Ваш вариант...

Избавляем бизнес от ИТ-зависимости

8 . 2

Kustomize | Самостоятельное задание

Результаты вашей работы поместите в директорию kubernetes-
templating/kustomize. Установка на выбранное окружение

должна работать следующим образом:

kubectl apply -k kubernetes-templating/kustomize/overrides/<Название окружения>/

Избавляем бизнес от ИТ-зависимости

8 . 3

Проверка ДЗ
Результаты вашей работы должны быть добавлены в ветку
kubernetes-templating вашего GitHub репозитория
<YOUR_LOGIN>_platform
В README.md рекомендуется внести описание того, что сделано
Создайте Pull Request к ветке master (описание PR рекомендуется
заполнять)
Добавьте метку kubernetes-templating к вашему PR

Избавляем бизнес от ИТ-зависимости

9 . 1

Избавляем бизнес от ИТ-зависимости

Проверка ДЗ
Данное задание будет проверяться в полуавтоматическом
режиме. Не пугайтесь того, что тесты в итоге завершатся
неуспешно.
При этом смотрите в лог Travis, чтобы понять, действительно ли
они дошли до "правильной ошибки"

, говорящей о том, что

дальнейшая проверка будет производиться вручную.

Избавляем бизнес от ИТ-зависимости

9 . 2