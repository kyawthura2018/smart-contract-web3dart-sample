import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection;

abstract class DBConnectionService {
  DbCollection collection;
  static Db _db;
  String _collectionName;
  DBConnectionService(String collectionName){
    this._collectionName = collectionName;
  }

  Future getConnection() async {
    var servers = ["127.0.0.1:27017", "127.0.0.1:27018", "127.0.0.1:27019"];

    if (_db == null) {
      var noError = true;
      var i = 0;

      while (noError) {
        try {
          var temp = servers[i];
          print(temp);
          _db = Db('mongodb://$temp/im_ems?replicaSet=devrs');
          await _db.open();
          var result = await _db.isMaster();
          if (result["ismaster"] as bool) noError = false;
        } catch (error) {
          i++;
        }
      }
    }
     collection = _db.collection(_collectionName);
  }

  closeConnection() {
    _db.close();
  }
}
