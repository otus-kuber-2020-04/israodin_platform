Kubernetes controllers.
ReplicaSet, Deployment,
DaemonSet
Избавляем бизнес от ИТ-зависимости
1 . 1
Подготовка
Домашняя работа предполагает выполнение в локальном
кластере
Для начала установим kind и создадим кластер.
Будем использовать следующую конфигурацию нашего
локального кластера - kind-config.yaml:
kind
Инструкция по
быстрому старту
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
Избавляем бизнес от ИТ-зависимости
1 . 2
Подготовка
Запустите создание кластера kind:
После появления отчета об успешном создании убедитесь что
развернуто три master ноды и три worker ноды:
kind create cluster --config kind-config.yaml
$ kubectl get nodes
NAME STATUS ROLES AGE VERSION
kind-control-plane Ready master 5m16s v1.16.3
kind-control-plane2 Ready master 4m14s v1.16.3
kind-control-plane3 Ready master 3m3s v1.16.3
kind-worker Ready <none> 2m9s v1.16.3
kind-worker2 Ready <none> 2m8s v1.16.3
kind-worker3 Ready <none> 2m9s v1.16.3
Избавляем бизнес от ИТ-зависимости
1 . 3
ReplicaSet
В предыдущем домашнем задании мы запускали standalone pod
с микросервисом frontend. Пришло время доверить управление
pod'ами данного микросервиса одному из контроллеров
Kubernetes.
Начнем с ReplicaSet и запустим одну реплику микросервиса
frontend.
Создайте и примените манифест frontend-replicaset.yaml с
содержимым со следующей страницы
Не забудьте изменить образ на собранный в предущем ДЗ
Избавляем бизнес от ИТ-зависимости
2 . 1
ReplicaSet
apiVersion: apps/v1
kind: ReplicaSet
metadata:
name: frontend
labels:
app: frontend
spec:
replicas: 1
template:
metadata:
labels:
app: frontend
spec:
containers:
- name: server
image: avtandilko/hipster-frontend:v0.0.1
Избавляем бизнес от ИТ-зависимости
2 . 2
ReplicaSet
Как можно понять из появившейся ошибки - в описании ReplicaSet
не хватает важной секции
Определите, что необходимо добавить в манифест, исправьте его
и примените вновь. Подсказку можно найти в готовом
манифеста
Не забудьте про то, что без указания environment переменных
сервис не заработает
В результате вывод команды kubectl get pods -l
app=frontend должен показывать, что запущена одна реплика
микросервиса frontend:
примере
NAME READY STATUS RESTARTS AGE
frontend-klglk 1/1 Running 0 73s
Избавляем бизнес от ИТ-зависимости
2 . 3
ReplicaSet
Одна работающая реплика - это уже неплохо, но в реальной
жизни, как правило, требуется создание нескольких инстансов
одного и того же сервиса для:
Повышения отказоустойчивости
Распределения нагрузки между репликами
Давайте попробуем увеличить количество реплик сервиса adhoc командой:
kubectl scale replicaset frontend --replicas=3
Избавляем бизнес от ИТ-зависимости
2 . 4
ReplicaSet
Проверить, что ReplicaSet контроллер теперь управляет тремя
репликами, и они готовы к работе, можно следующим образом:
Проверим, что благодаря контроллеру pod'ы действительно
восстанавливаются после их ручного удаления:
$ kubectl get rs frontend
NAME DESIRED CURRENT READY AGE
frontend 3 3 3 13m
kubectl delete pods -l app=frontend | kubectl get pods -l app=frontend -w
Избавляем бизнес от ИТ-зависимости
2 . 5
ReplicaSet
Повторно примените манифест frontend-replicaset.yaml
Убедитесь, что количество реплик вновь уменьшилось до одной
Измените манифест таким образом, чтобы из манифеста сразу
разворачивалось три реплики сервиса, вновь примените его
Избавляем бизнес от ИТ-зависимости
2 . 6
Обновление ReplicaSet
Давайте представим, что мы обновили исходный код и хотим
выкатить новую версию микросервиса
Добавьте на DockerHub версию образа с новым тегом (v0.0.2,
можно просто перетегировать старый образ)
Обновите в манифесте версию образа
Примените новый манифест, параллельно запустите
отслеживание происходящего:
kubectl apply -f frontend-replicaset.yaml | kubectl get pods -l app=frontend -w
Кажется, ничего не произошло
Избавляем бизнес от ИТ-зависимости
2 . 7
Обновление ReplicaSet
Давайте проверим образ, указанный в ReplicaSet:
И образ из которого сейчас запущены pod, управляемые
контроллером:
kubectl get replicaset frontend -o=jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get pods -l app=frontend -o=jsonpath='{.items[0:3].spec.containers[0].image}'
Обратите внимание на использование ключа -o jsonpath
для форматирования вывода. Подробнее с данным
функционалом kubectl можно ознакомиться по ссылке
Избавляем бизнес от ИТ-зависимости
2 . 8
Обновление ReplicaSet
Удалите все запущенные pod и после их пересоздания еще раз
проверьте, из какого образа они развернулись
Руководствуясь материалами лекции опишите произошедшую
ситуацию, почему обновление ReplicaSet не повлекло обновление
запущенных pod?
Мы, тем временем, перейдем к следующему контроллеру, более
подходящему для развертывания и обновления приложений
внутри Kubernetes
Избавляем бизнес от ИТ-зависимости
2 . 9
Deployment
Для начала - воспроизведите действия, проделанные с
микросервисом frontend для микросервиса paymentService.
Результат:
Собранный и помещенный в Docker Hub образ с двумя тегами
v0.0.1 и v0.0.2
Валидный манифест paymentservice-replicaset.yaml с тремя
репликами, разворачивающими из образа версии v0.0.1
Избавляем бизнес от ИТ-зависимости
3 . 1
Deployment
Приступим к написанию Deployment манифеста для сервиса
payment
Скопируйте содержимое файла paymentservicereplicaset.yaml в файл paymentservice-deployment.yaml
Измените поле kind с ReplicaSet на Deployment
Манифест готов 😉 Примените его и убедитесь, что в кластере
Kubernetes действительно запустилось три реплики сервиса
payment и каждая из них находится в состоянии Ready
Обратите внимание, что помимо Deployment (kubectl get
deployments) и трех pod, у нас появился новый ReplicaSet
(kubectl get rs)
Избавляем бизнес от ИТ-зависимости
3 . 2
Deployment
Вспомним зависимость между Deployment, ReplicaSet и Pod:
Избавляем бизнес от ИТ-зависимости
3 . 3
Обновление Deployment
Давайте попробуем обновить наш Deployment на версию образа
v0.0.2
Обратите внимание на последовательность обновления pod. По
умолчанию применяется стратегия Rolling Update:
Создание одного нового pod с версией образа v0.0.2
Удаление одного из старых pod
Создание еще одного нового pod
...
kubectl apply -f paymentservice-deployment.yaml | kubectl get pods -l app=paymentservice
-w
Избавляем бизнес от ИТ-зависимости
3 . 4
Обновление Deployment
Убедитесь что:
Все новые pod развернуты из образа v0.0.2
Создано два ReplicaSet:
Один (новый) управляет тремя репликами pod с образом
v0.0.2
Второй (старый) управляет нулем реплик pod с образом v0.0.1
Также мы можем посмотреть на историю версий нашего
Deployment:
kubectl rollout history deployment paymentservice
Избавляем бизнес от ИТ-зависимости
3 . 5
Deployment | Rollback
Представим, что обновление по каким-то причинам произошло
неудачно и нам необходимо сделать откат. Kubernetes
предоставляет такую возможность:
В выводе мы можем наблюдать, как происходит постепенное
масштабирование вниз "нового" ReplicaSet, и масштабирование
вверх "старого"
kubectl rollout undo deployment paymentservice --to-revision=1 | kubectl get rs -l
app=paymentservice -w
Избавляем бизнес от ИТ-зависимости
3 . 6
Deployment | Задание со ⭐
С использованием параметров maxSurge и maxUnavailable
самостоятельно реализуйте два следующих сценария
развертывания:
Аналог blue-green:
1. Развертывание трех новых pod
2. Удаление трех старых pod
Reverse Rolling Update:
1. Удаление одного старого pod
2. Создание одного нового pod
3. ...
Избавляем бизнес от ИТ-зависимости
3 . 7
Deployment | Задание со ⭐
с описанием стратегий развертывания для
Deployment.
В результате должно получиться два манифеста:
paymentservice-deployment-bg.yaml
paymentservice-deployment-reverse.yaml
Документация
Избавляем бизнес от ИТ-зависимости
3 . 8
Probes
Мы научились разворачивать и обновлять наши микросервисы,
но можем ли быть уверены, что они корректно работают после
выкатки? Один из механизмов Kubernetes, позволяющий нам
проверить это -
Давайте на примере микросервиса frontend посмотрим на то,
как probes влияют на процесс развертывания.
Создайте манифест frontend-deployment.yaml из которого
можно развернуть три реплики pod с тегом образа v0.0.1
Добавьте туда описание readinessProbe. Описание можно взять из
манифеста по
Probes
ссылке
Избавляем бизнес от ИТ-зависимости
4 . 1
Probes
Примените манифест с readinessProbe. Если все сделано
правильно, то мы вновь увидим три запущенных pod в описании
которых (kubectl describe pod) будет указание на наличие
readinessProbe и ее параметры
Давайте попробуем сымитировать некорректную работу
приложения и посмотрим, как будет вести себя обновление:
Замените в описании пробы URL /_healthz на /_health
Разверните версию v0.0.2
В манифесте, который попадет в PR, readinessProbe должна
остаться рабочей
Избавляем бизнес от ИТ-зависимости
4 . 2
Probes
Если посмотреть на текущее состояние нашего микросервиса,
мы увидим, что был создан один pod новой версии, но его статус
готовности следующий:
Команда kubectl describe pod поможет нам понять причину:
NAME READY STATUS RESTARTS AGE
frontend-6bf67c4974-2cns9 0/1 Running 0 10s
Events:
Type Reason Age From Message
---- ------ ---- ---- -------
Warning Unhealthy 11s (x22 over 3m41s) kubelet, kind-worker Readiness probe
failed: HTTP probe failed with statuscode: 404
Избавляем бизнес от ИТ-зависимости
4 . 3
Probes
Как можно было заметить, пока readinessProbe для нового pod
не станет успешной - Deployment не будет пытаться продолжить
обновление.
На данном этапе может возникнуть вопрос - как автоматически
отследить успешность выполнения Deployment (например для
запуска в CI/CD).
В этом нам может помочь следующая команда:
kubectl rollout status deployment/frontend
Избавляем бизнес от ИТ-зависимости
4 . 4
Probes
Таким образом описание pipeline, включающее в себя шаг
развертывания и шаг отката, в самом простом случае может
выглядеть так (синтаксис GitLab CI):
deploy_job:
stage: deploy
script:
- kubectl apply -f frontend-deployment.yaml
- kubectl rollout status deployment/frontend --timeout=60s
rollback_deploy_job:
stage: rollback
script:
- kubectl rollout undo deployment/frontend
when: on_failure
Избавляем бизнес от ИТ-зависимости
4 . 5
DaemonSet
Рассмотрим еще один контроллер Kubernetes. Отличительная
особенность DaemonSet в том, что при его применении на каждом
физическом хосте создается по одному экземпляру pod,
описанного в спецификации.
Типичные кейсы использования DaemonSet:
Сетевые плагины
Утилиты для сбора и отправки логов (Fluent Bit, Fluentd, etc...)
Различные утилиты для мониторинга (Node Exporter, etc...)
...
Избавляем бизнес от ИТ-зависимости
5 . 1
DaemonSet | Задание со ⭐
Опробуем DaemonSet на примере
Найдите в интернете или напишите самостоятельно манифест
node-exporter-daemonset.yaml для развертывания DaemonSet с
Node Exporter
После применения данного DaemonSet и выполнения команды:
kubectl port-forward <имя любого pod в DaemonSet>
9100:9100 метрики должны быть доступны на localhost: curl
localhost:9100/metrics
Node Exporter
Избавляем бизнес от ИТ-зависимости
5 . 2
DaemonSet | Задание с ⭐⭐
Как правило, мониторинг требуется не только для worker, но и для
master нод. При этом, по умолчанию, pod управляемые DaemonSet
на master нодах не разворачиваются
Найдите способ модернизировать свой DaemonSet таким
образом, чтобы Node Exporter был развернут как на master, так и
на worker нодах (конфигурацию самих нод изменять нельзя)
Отразите изменения в манифесте
Избавляем бизнес от ИТ-зависимости
5 . 3
Проверка ДЗ
Основная часть домашнего задания проверяется
автоматически. После успешного прохождения тестов вы можете
самостоятельно сделать Merge в master ветку.
Если вы сделали одно или несколько заданий со ⭐ и хотите
получить комментарии преподавателя:
Добавьте к PR метку Review Required
Не делайте Merge самостоятельно
Тесты основной части задания должны быть успешными
Избавляем бизнес от ИТ-зависимости
6 . 1
Проверка ДЗ
Поместите все файлы, созданные в процессе выполнения
домашнего задания в директорию kubernetes-controllers
Структура репозитория при выполнении всех заданий со ⭐:
├── kubernetes-intro
└── kubernetes-controllers
├── frontend-deployment.yaml
├── frontend-replicaset.yaml
├── node-exporter-daemonset.yaml
├── paymentservice-deployment-bg.yaml
├── paymentservice-deployment-reverse.yaml
├── paymentservice-deployment.yaml
└── paymentservice-replicaset.yaml
Избавляем бизнес от ИТ-зависимости
6 . 2
Проверка ДЗ
Результаты вашей работы должны быть добавлены в ветку
kubernetes-controllers вашего GitHub репозитория
<YOUR_LOGIN>_platform
В README.md рекомендуется внести описание того, что сделано
Создайте Pull Request к ветке master (описание PR рекомендуется
заполнять)
Добавьте метку kubernetes-controllers к вашему PR
Избавляем бизнес от ИТ-зависимости
6 . 3
Избавляем бизнес от ИТ-зависимости
Проверка ДЗ
После того как автоматизированные тесты проверят
корректность выполнения ДЗ, необходимо сделать merge ветки
kubernetes-controllers в master и закрыть PR
Если у вас возникли вопросы по ДЗ и необходима консультация
преподавателей - после прохождения автотестов добавьте к PR
метку Review Required и не мерджите PR самостоятельно
Избавляем бизнес от ИТ-зависимости
6 . 4