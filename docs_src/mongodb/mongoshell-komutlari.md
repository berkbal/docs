# MongoDB Commands Cheat Sheet

Bir zamanlar bir nedenden ötürü İngilizce olarak aldığım notlar:

| Basic Commands | Purpose |
|--|--|
|use db-name;|switches to that db|
|show dbs;|list all databases that have data in it|
|db;|prints current database that we are in|
|show collections;|lists collections inside the database. Must be used on a database. It lists collections inside the database|
|db.createCollection("STRING")|creates collection to inside the database|
|db.COLLECTION-NAME.drop();|deletes the collection from database.|
|db.dropDatabase();|drops the database that we are currently in. (delete database)|

### Managing Data

|Command|Purpose|
|---|---|
|db.COLLECTION-NAME.insertOne(”JSON FORMAT DATA”);|It inserts a json formatted data to the spesific collection. Data must be formatted as JSON.|
|db.COLLECTION-NAME.insertMany(”JSON FORMAT DATAS”);|It inserts a json formatted datas to the spesific collection. Data can be passed as Javascript array.|
|db.COLLECTION-NAME.updateOne({name: “Berk”}, {$set : {rating : 4.6}});|Updates the value. First it finds the object that its data is “Berk” then sets its rating value to 4.6. $set is an operator from mongoDB.|
|db.COLLECTION-NAME.updateMany({}, {$set: {students: 10000}});|Same logic with updateOne. It updates all objects because we used {} in the first section. It sets students value to 10000 on all objects.|
|db.COLLECTION-NAME.deleteOne({name: “Berk”});|It finds the object that its name value is Berk and deletes it.|

### Search Data

|Command|Purpose|
|--|--|
|db.COLLECTION-NAME.find({}, {name:1, rating:1})|With that usage we can search data inside our documents. It will return only name and rating variables from all of our document. 1 enables, 0 disables it.|
|db.COLLECTION-name.find({status: “A”});|With that usage we can list objects like their status variable is A. Variable names are example.|
|db.COLLECTION-NAME.find();|prints datas from spesified collection.|
|db.COLLECTION-NAME.count();|counts how many documents we have in that collection.|
|db.COLLECTION-NAME.find({});|with that empty object find function prints us to all documents.|
|db.COLLECTION-NAME.find({}).skip(1);|it skips the object 1. On JSON format objects are like arrays. Every object has index number.|
