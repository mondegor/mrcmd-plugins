# Plugins for Mrcmd Tool v0.10.1
Этот репозиторий содержит базовые плагины для [Mrcmd Tool](https://github.com/mondegor/mrcmd).

## Статус проекта
Проект находится на стадии бета-тестирования и активно применяется при разработке.

## Инсталляция плагинов
- Выбрать рабочую директорию, содержащую директорию `mrcmd`;
- `curl -fsSL -o mrcmd-plugins.zip https://github.com/mondegor/mrcmd-plugins/archive/refs/tags/v0.10.1.zip --ssl-no-revoke`
- `unzip mrcmd-plugins.zip && rm mrcmd-plugins.zip && mv mrcmd-plugins-0.10.1 mrcmd/plugins`
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
- `php-symfony` - Установщик Symfony `Docker` (https://www.php.net/docs.php);

### Реляционные и NoSQL базы данных
- `cassandra` - хранилище данных Apache Cassandra `Docker` (https://cassandra.apache.org/doc/latest/);
- `mongo` - база данных MongoDB `Docker` (https://www.mongodb.com/docs/);
- `mysql` - база данных Mysql `Docker` (https://dev.mysql.com/doc/);
- `postgres` - база данных Postgres `Docker` (https://www.postgresql.org/docs/);
- `redis` - хранилище данных типа ключ-значение Redis `Docker` (https://redis.io/docs/);

### Брокеры сообщений
- `kafka` - распределённый программный брокер сообщений Apache Kafka `Docker` (https://kafka.apache.org/);
    - `kafka-ui` - панель управления для Apache Kafka `Docker` (https://github.com/provectus/kafka-ui);
    - `zookeeper` - открытая программная служба для координации распределённых систем Apache Zookeeper `Docker` (https://zookeeper.apache.org/);
- `rabbitmq` - программный брокер сообщений RabbitMQ на основе стандарта AMQP `Docker` (https://www.rabbitmq.com/);

### Другие плагины
- `go-migrate` - Миграция БД `Docker` (https://github.com/golang-migrate/migrate#readme);
- `golangci-lint` - Линтеры для GO `Docker` (https://github.com/golangci/golangci-lint);
- `keycloak` - Сервис аутентификации `Docker` (https://www.keycloak.org/documentation);
- `minio` - S3 хранилище `Docker` (https://min.io/docs/);
- `nginx` - сервер Nginx `Docker` (https://docs.nginx.com/);
- `traefik` - сервер Traefik `Docker` (https://doc.traefik.io/);
- `plantuml` - PlantUML `Docker` (https://plantuml.com/starting);
- `prometheus` - Prometheus `Docker` (https://prometheus.io/docs);
- `sentry` - Sentry - мониторинг ошибок `Docker` (https://github.com/getsentry/sentry#readme);
- `shellcheck` - Статический анализатор shell скриптов `Docker` (https://www.shellcheck.net/);
- `ssh` - Набор команд для генерации `SSH` ключей и регистрации их в `SSH Agent`;
- `vendor` - Загрузчик данных из zip архивов и git репозиториев;

### Библиотеки
- `openapi-lib` - Библиотека для сборки API документации как общей, так и по модулям
  из заранее заготовленных частей документации, хранящихся в виде файлов;