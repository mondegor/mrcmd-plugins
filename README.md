# Plugins for Mrcmd Tool v0.6.6
Этот репозиторий содержит базовые плагины для Mrcmd Tool.

## Статус проекта
Проект находится на стадии бета-тестирования.

## Установка плагинов
Инструкция по установке плагинов находится [здесь](https://github.com/mondegor/mrcmd#readme).

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
- `redis` - хранилище данных Redis `Docker` (https://redis.io/docs/);

### Другие плагины
- `go-migrate` - Миграция БД `Docker` (https://github.com/golang-migrate/migrate#readme);
- `keycloak` - Сервис аутентификации `Docker` (https://www.keycloak.org/documentation);
- `minio` - S3 хранилище `Docker` (https://min.io/docs/);
- `nginx` - сервер Nginx `Docker` (https://docs.nginx.com/);
- `plantuml` - PlantUML `Docker` (https://plantuml.com/starting);
- `sentry` - Sentry - мониторинг ошибок `Docker` (https://github.com/getsentry/sentry#readme);
- `shellcheck` - Статический анализатор shell скриптов `Docker` (https://www.shellcheck.net/);
- `ssh` - Набор команд для генерации `SSH` ключей и регистрации их в `SSH Agent`;
- `vendor` - Загрузчик данных из zip архивов и git репозиториев;