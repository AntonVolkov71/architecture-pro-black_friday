# Шардирование

## Описание
- Применили шардирование, репликацию, кеширование к БД и горизонтальное масштабирование согласно схемы
  -![3_cashe.jpg](schemas/3_cashe.jpg)

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

### Проверка кеширования 
- Открой в браузер
  - открой Devtools/Network
  - вставь в поисковую строку http://localhost:8080/helloDoc/users
    - выполни несколько запросов
      - первый запрос будет гораздо дольше чем последующие
