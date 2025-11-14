# Шардирование

## Описание
- Применили шардирование и репликацию к БД согласно схемы
  - ![2_replica.jpg](schemas/2_replica.jpg)

## Как запустить
- выполнять из директории/mongo-sharding
```shell
// windows
docker-compose up -d

// если что-то пошло не так 
docker compose down -v

// linuxa 
sudo docker compose up -d 
```

### Настройка БД
- запустите скрипт
  - [mongo-init.sh](scripts/mongo-init.sh)

## Как проверить
### Отключи контейнер shard1 (можно и shard2)
- Откройте в браузере http://localhost:8080
- запросы должны проходить