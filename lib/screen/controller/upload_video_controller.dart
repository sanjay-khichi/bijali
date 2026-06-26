
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
class UploadVideoController extends GetxController{



}

class ImageAndVideoPath{
  ImageAndVideoPath({this.video,this.image});
  String? video;
  String? image;
}