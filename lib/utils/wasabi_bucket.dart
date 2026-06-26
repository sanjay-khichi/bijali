import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

  final minio = Minio(
    endPoint: 's3.ap-south-1.amazonaws.com',
    //endPoint: 'coontent',
    accessKey: '',
    secretKey: '',
    region: 'ap-south-1'

  );
  fetchConnection() async {
    print("========connection=======");
    //mongodb+srv://gabbar1037:Coontent%402158@65.0.44.39:27017/content?authMechanism=DEFAULT
  // var dbConnection = await mongo.Db.create("mongodb+srv://gabbar1037:Vivek2158@cluster0.kamy8mp.mongodb.net/content");
    var dbConnection = await mongo.Db.create("mongodb://gabbar1037:Coontent%402158@65.0.44.39:27017/content?authSource=admin");
    print("======dbConnection.databaseName======");
    //print(await dbConnection.);
    print(dbConnection.databaseName);
   await dbConnection.open();
  return dbConnection;
  //docdb-2023-05-21-13-49-07.cluster-ce6dpwdb8dgk.ap-south-1.docdb.amazonaws.com
}
  class AddConfig{

    static String get adKey {
      switch (kReleaseMode) {
        case true:

          return 'ca-app-pub-3719084056205826/6798315160';
        case false:
          return 'ca-app-pub-3940256099942544/2247696110';

        default:
          return 'ca-app-pub-3940256099942544/2247696110';
      }
    }

  }

   String url = "https://d2vygn9ts7ygk4.cloudfront.net/";
