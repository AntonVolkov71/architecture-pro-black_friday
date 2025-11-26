#!/bin/bash

function print_color() {
    printf "\e[1;34m[$1]\e[0m\n"
}

### настройка сервера конфигурации
function server_cfg() {
  print_color "server_cfg starting..."

  docker compose exec -T configSrv mongosh --eval  "
  rs.initiate({
    _id : 'config_server',
    configsvr: true,
    members: [
      { _id : 0, host : 'configSrv:27017' }
    ]
  })"

  print_color "server_cfg finished"
}

### настройка шарды 1
function shard1() {
  print_color "shard1 starting..."
  docker compose exec -T shard1 mongosh --port 27018 --eval "
  rs.initiate({
    _id: 'shard1',
    members: [
      { _id: 0, host: 'shard1:27018', priority: 2 },
      { _id: 1, host: 'shard1_repl1:27028', priority: 1 },
      { _id: 2, host: 'shard1_repl2:27038',  priority: 1 }

    ]
  })"

  print_color "shard1 finished"
}

### настройка шарды 2 и его реплики
function shard2() {
  print_color "shard2 starting..."

  docker compose exec -T shard2 mongosh --port 27019 --eval "
  rs.initiate({
    _id: 'shard2',
    members: [
      { _id: 0, host: 'shard2:27019', priority: 2 },
      { _id: 1, host: 'shard2_repl1:27029',  priority: 1 },
      { _id: 2, host: 'shard2_repl2:27039',  priority: 1 }
    ]
  })"

  print_color "shard2 finished"
}

## настройка роутера
### привязка шард
function router() {
  print_color "router starting..."

  docker compose exec -T mongos_router mongosh --port 27020 --eval "
  sh.addShard('shard1/shard1:27018');
  sh.addShard('shard2/shard2:27019');"

  print_color "router finished"
}

### создание БД  "somedb"
### заполнение коллекции "helloDoc"
function db_init() {
  print_color "db_init starting..."

  docker compose exec -T mongos_router mongosh --port 27020 --eval "
  sh.enableSharding('somedb');
  sh.shardCollection('somedb.helloDoc', { 'name': 'hashed' });
  db = db.getSiblingDB('somedb');
  for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:'ly'+i});
  db.helloDoc.countDocuments();"

  print_color "db_init finished"
}

### проверка разделения информации на БД по шардам
function check_data_shard1() {
  print_color "check_data_shard1..."

  docker compose exec -T shard1 mongosh --port 27018 --eval "
  db = db.getSiblingDB('somedb');
  db.helloDoc.countDocuments();"

  print_color "check_data_shard1 finished"
}

### проверка статуса репликасетов
function check_replica_status() {
  print_color "check_replica_status..."

  docker compose exec -T shard1 mongosh --port 27018 --eval "
  print('=== Shard1 Status ===');
  rs.status().members.forEach(member => {
    print('Host: ' + member.name + ', State: ' + member.stateStr + ', Health: ' + member.health);
  });"

  docker compose exec -T shard2 mongosh --port 27019 --eval "
  print('=== Shard2 Status ===');
  rs.status().members.forEach(member => {
    print('Host: ' + member.name + ', State: ' + member.stateStr + ', Health: ' + member.health);
  });"

  print_color "check_replica_status finished"
}

### проверка кеширования
function redis_cash() {
  print_color "redis_cash..."

  docker compose exec -T redis_1 redis-cli ping

  print_color "redis_cash finished"
}

function timeout() {
  sleep 5
}

server_cfg
timeout

shard1
timeout

shard2
timeout

router
timeout

db_init
timeout

check_data_shard1
timeout

check_replica_status
timeout

redis_cash

