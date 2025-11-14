#!/bin/bash

function print_color() {
    printf "\e[1;34m[$1]\e[0m\n"
}

### настройка сервера конфигурации
function server_cfg() {
  print_color "server_cfg starting..."

  docker compose exec -T configSrv mongosh --eval "
  rs.initiate({
    _id: 'config_server',
    configsvr: true,
    members: [
      { _id: 0, host: 'configSrv:27017' }
    ]
  })"

  print_color "server_cfg finished"
}

### настройка шарды 1 и его реплики
function shard1() {
  print_color "shard1 starting..."
#{ _id: 1, host: 'shard1_repl1:27028' }
  docker compose exec -T shard1 mongosh --port 27018 --eval "
  rs.initiate({
    _id: 'shard1',
    members: [
      { _id: 0, host: 'shard1:27018' }
    ]
  })"

  print_color "shard1 finished"
}

### настройка шарды 2 и его реплики
function shard2() {
  print_color "shard2 starting..."
#      { _id: 3, host: 'shard2_repl1:27029' }

  docker compose exec -T shard2 mongosh --port 27019 --eval "
  rs.initiate({
    _id: 'shard2',
    members: [
      { _id: 2, host: 'shard2:27019' }
    ]
  })"

  print_color "shard2 finished"
}

## настройка роутера
### привязка шард
function router() {
  print_color "router starting..."
#sh.addShard('shard1/shard1:27018,shard1_repl1:27028');
#  sh.addShard('shard2/shard2:27019,shard2_repl1:27029');
  docker compose exec -T mongos_router mongosh --port 27020 --eval "
  sh.addShard('shard1/shard1:27018');
  sh.addShard('shard2/shard2:27019');
  sh.status();"

  print_color "router finished"
}

### создание БД  "somedb"
### заполнение коллекции "helloDoc"
function db_init() {
  print_color "db_init starting..."

  docker compose exec -T mongos_router mongosh --port 27020 --eval "
  sh.enableSharding('somedb');
  sh.shardCollection('somedb.helloDoc', { age: 1 });
  db = db.getSiblingDB('somedb');
  for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:'ly'+i});
  db.helloDoc.countDocuments();"

  print_color "db_init finished"
}

function check_data_shard1() {
  print_color "check_data_shard1..."

  docker compose exec -T shard1 mongosh --port 27018 --eval "
  db = db.getSiblingDB('somedb');
  db.helloDoc.countDocuments();"

  print_color "check_data_shard1 finished"
}

server_cfg
sleep 5
shard1
sleep 5
shard2
sleep 5
router
sleep 5
db_init
sleep 5
check_data_shard1
