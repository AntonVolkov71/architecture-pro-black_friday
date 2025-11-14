# Шардирование

## Описание
- Применили шардирование к БД согласно схемы
  - ![1_sharding.jpg](schemas/1_sharding.jpg)

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
### Проверка шардинга
- посмотри вывод после выполнения скрипта 
  - поле [check_data_shard1]
    - должно быть меньше или больше половины, то есть часть данных храниться на каждой из шард
