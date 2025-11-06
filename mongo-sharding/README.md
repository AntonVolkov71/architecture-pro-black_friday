## Шардирование
- Добавили 
  - сервер конфигурации


// Посмотреть статистику по шардам
db.helloDoc.getShardDistribution()

// Или вручную проверить на каждом шарде
use somedb
db.helloDoc.countDocuments()