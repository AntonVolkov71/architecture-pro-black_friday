## Задача
- перегрузка шарды Категория "Электроника"
  - разработать стратегию, как выявлять и устранять такие «горячие» шарды
  - предложить метрики мониторинга для предотвращения в будущем
  - Предложите механизмы автоматического перераспределения данных.


### метрики мониторинга
- часто используемы горячие ключи - 
  - пример, db.collection.aggregate([{$group:{_id:"$category", count:{$sum:1}}}])
- проверка балансировки хранилища
  - пример, db.printShardingStatus(true),  на примере helloDoc из заданий 1-6
```
[
  {
    ns: 'somedb.helloDoc',
    shards: [
      {
        shardName: 'shard1',
        numOrphanedDocs: 0,
        numOwnedDocuments: 492, // количество записей на данной шарде
        ownedSizeBytes: 22632,
        orphanedSizeBytes: 0
      },
      {
        shardName: 'shard2',
        numOrphanedDocs: 0,
        numOwnedDocuments: 508, // количество записей на данной шарде
        ownedSizeBytes: 23368,
        orphanedSizeBytes: 0
      }
    ]
  },
...
```
- выполнение операций
  - пример db.serverStatus().opcounters
```
{
  insert: Long('1000'), // вставка данных
  query: Long('52'), // запросы данных
  update: Long('0'),
  delete: Long('0'),
  getmore: Long('0'),
  command: Long('253')
}

```


### стратегии выявления 
- анализ метрики балансировки хранилища
  - анализ распределения данных между шардами
- мониторинг частоты операций на шардах (метрика выполнение операций), удаление, чтение так же по метрике
  

### Механизмы автоматического перераспределения данных
- ввести подкатегории sub_category коллекции Категории
- разделить данные не только по категории, но и по ценовым дипазонам
  - пример диапазона цен
```
sh.addShardTag("shard1", "electronics_range_price1");
sh.addShardTag("shard2", "electronics_range_price2");

sh.addTagRange(
  "somedb.product",
  { category: "Электроника", price: 0 },
  { category: "Электроника", price: 1000 },
  "electronics_range_price1"
);
sh.addTagRange(
  "somedb.product",
  { category: "Электроника", price: 1000 },
  { category: "Электроника", price: 2000 },
  "electronics_range_price2"
);

... и так далее
```
- включение автобалансировки чанков между шардами sh.startBalancer()