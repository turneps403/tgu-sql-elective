## Электив ТГУ "Продвинутые запросы SQL"

### Контрольная точка №1

Список файлов:

1. Изменение структуры БД [create_cashback_feature_tables.sql](/create_cashback_feature_tables.sql)
2. Наполнение первичными данными [populate_cashback_categories.sql](populate_cashback_categories.sql)

### Контрольная точка №2

Список файлов:

1. Создание триггера и триггерной функции [create_cashback_trigger.sql](create_cashback_trigger.sql)
2. Создание хранимой процедуры [cron_cashback_procedure.sql](cron_cashback_procedure.sql)
3. Табличная функция детализированного отчета [report_cacheback_table_func.sql](report_cacheback_table_func.sql)

### Postgres

Все запросы проверялись на образе `postgres:14`

Формат запуска контейнера и volume:

```
# VOLUME
docker volume create postgres_test_vol

# POSTGRES
docker run --rm -d  \
  --name postgres_test \
  -e POSTGRES_PASSWORD=my_super_secret_123456 \
  -e POSTGRES_USER=my_postgres_user \
  -e POSTGRES_DB=rss_feed \
  -v postgres_test_vol:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:14


# SHELL CONNECT
docker exec -it postgres_test psql -U my_postgres_user -d rss_feed -p 5432

# CLEAN UP AT THE END
docker stop postgres_test
docker ps -a
docker volume ls
docker volume prune
```
