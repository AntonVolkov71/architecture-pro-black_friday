# Шардирование

## Описание
- Применили шардирование к БД согласно схемы
  - ![sharding.jpg](schemas/sharding.jpg)
  - 
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
### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs