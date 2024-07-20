# Plugins for Mrcmd Tool v0.13.1
Этот репозиторий содержит базовые плагины для [Mrcmd Tool](https://github.com/mondegor/mrcmd).

## Статус проекта
Проект находится на стадии бета-тестирования и активно применяется при разработке.

## Инсталляция плагинов
- Выбрать рабочую директорию, содержащую директорию `mrcmd`;
- `curl -fsSL -o mrcmd-plugins.zip https://github.com/mondegor/mrcmd-plugins/archive/refs/tags/v0.13.1.zip --ssl-no-revoke`
- `unzip mrcmd-plugins.zip && rm mrcmd-plugins.zip && mv mrcmd-plugins-0.13.1 mrcmd/plugins`
- `mrcmd state` // проверить, что плагины утилиты были установлены (см. Shared plugins path)

## Краткое описание плагинов

### Основные плагины
- `global` - глобальные переменные в рамках проекта;
- `pm` - менеджер установленных плагинов;

### Docker
- `docker` - набор команд для работы с Docker (https://docs.docker.com/);
- `docker-compose` - набор команд для работы с Docker Compose (https://docs.docker.com/compose/);

### Языки программирования
- `go` - Golang `Docker` (https://go.dev/);
- `go-dev` - Golang нативный (https://go.dev/);
- `mvn` - Apache Maven Java 17 `Docker` (https://maven.apache.org/guides/);
- `java` - Java 17 `Docker` (https://dev.java/);
- `nodejs` - Node.js `Docker` (https://nodejs.org/en/docs);
- `php-alpine` - PHP на образе Alpine `Docker` (https://www.php.net/docs.php);
- `php-cli` - PHP Cli `Docker` (https://www.php.net/docs.php);
- `php-fpm` - PHP FPM `Docker` (https://www.php.net/docs.php);
- `php-symfony` - установщик Symfony `Docker` (https://www.php.net/docs.php);

### Реляционные и NoSQL базы данных
- `cassandra` - хранилище данных Apache Cassandra `Docker` (https://cassandra.apache.org/doc/latest/);
- `mongo` - база данных MongoDB `Docker` (https://www.mongodb.com/docs/);
- `mysql` - база данных Mysql `Docker` (https://dev.mysql.com/doc/);
- `postgres` - база данных Postgres `Docker` (https://www.postgresql.org/docs/);
- `redis` - хранилище данных типа ключ-значение Redis `Docker` (https://redis.io/docs/);
- `minio` - S3 хранилище `Docker` (https://min.io/docs/);

### Брокеры сообщений
- `kafka` - распределённый программный брокер сообщений Apache Kafka `Docker` (https://kafka.apache.org/);
    - `kafka-ui` - панель управления для Apache Kafka `Docker` (https://github.com/provectus/kafka-ui);
    - `zookeeper` - открытая программная служба для координации распределённых систем Apache Zookeeper `Docker` (https://zookeeper.apache.org/);
- `rabbitmq` - программный брокер сообщений RabbitMQ на основе стандарта AMQP `Docker` (https://www.rabbitmq.com/);

### Службы мониторинга
- `prometheus` - Prometheus - сбор и хранение метрик `Docker` (https://prometheus.io/docs);
- `nodeexporter` - агент Node Exporter для сбора метрик для операционных систем на базе ядра Linux `Docker` (https://github.com/prometheus/node_exporter/blob/master/README.md);
- `postgresexporter` - агент Postgres Exporter для сбора метрик баз данных PostgreSQL `Docker` (https://github.com/prometheus-community/postgres_exporter/blob/master/README.md);
- `grafana` - платформа Grafana для визуализации, мониторинга и анализа данных `Docker` (https://grafana.com/docs/grafana/latest/);
- `grafana-loki` - система Grafana Loki для сбора, хранения и анализа логов `Docker` (https://grafana.com/docs/loki/latest/);
- `grafana-promtail` - агент Grafana Promtail для сбора логов и отправки их в Loki `Docker` (https://grafana.com/docs/loki/latest/send-data/promtail/);
- `sentry` - система Sentry для мониторинга ошибок `Docker` (https://github.com/getsentry/sentry#readme);

### Другие плагины
- `go-migrate` - миграция БД `Docker` (https://github.com/golang-migrate/migrate#readme);
- `golangci-lint` - линтеры для GO `Docker` (https://github.com/golangci/golangci-lint);
- `keycloak` - сервис аутентификации `Docker` (https://www.keycloak.org/documentation);
- `nginx` - сервер Nginx `Docker` (https://docs.nginx.com/);
- `traefik` - сервер Traefik `Docker` (https://doc.traefik.io/);
- `plantuml` - PlantUML `Docker` (https://plantuml.com/starting);
- `shellcheck` - статический анализатор shell скриптов `Docker` (https://www.shellcheck.net/);
- `ssh` - набор команд для генерации `SSH` ключей и регистрации их в `SSH Agent`;
- `vendor` - загрузчик данных из zip архивов и git репозиториев;

### Библиотеки
- `openapi-lib` - библиотека для сборки API документации как общей, так и по модулям
  из заранее заготовленных частей документации, хранящихся в виде файлов;