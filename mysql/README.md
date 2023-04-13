Команды для анализа репликации данных:

Для мастера:
SHOW MASTER STATUS;

Для слейва:
SHOW SLAVE STATUS;

CHANGE MASTER TO MASTER_HOST='db-mysql', MASTER_USER='user_replication', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=1;
Вместо MASTER_LOG_FILE и MASTER_LOG_POS необходимо подставить значения, полученные из SHOW MASTER STATUS на мастере.
Эти параметры вместе называются координатами двоичного журнала.

https://habr.com/ru/post/532216/
https://habr.com/ru/post/521952/
https://vitalyzhakov.github.io/post/mysql-replication-docker/