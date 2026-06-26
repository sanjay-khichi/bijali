import 'dart:convert';

import 'package:get/get.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../utils/wasabi_bucket.dart';
import 'dashboard_controller.dart';
class CommentController extends GetxController{

  mongo.Db? dbConnection;
  DashBoardController dashBoardController = Get.find();
  int pageNumber = 0;
  var commentList = <CommentListModel>[].obs;
  List<CommentListModel>  get getCommentList => commentList.value;
  set setCommentList(CommentListModel val){
    commentList.value.add(val);
    commentList.value.sort((a,b)=> b.createdDate!.compareTo(a!.createdDate!));
    commentList.refresh();
  }
  Future<void> fetchComments(String videoId) async {
     commentList.value.clear();
     commentList.refresh();
     dbConnection = await fetchConnection();
     pageNumber = 0;

     final pipeline = [
      {
        '\$lookup': {
          'from': 'users',
          'localField': 'userId',
          'foreignField': 'userId',
          'as': 'owner'
        }
      },
    {
      '\$match': {'videoId': videoId}
    },
    {
    '\$sort': {'createdDate': -1}
    },
     /* {'\$skip': (pageNumber - 1) * 10},*/
    {
    '\$limit': 10
    }
    ];

    // Fetch the first 10 videos from the database.
    try {
      var a = await dbConnection?.collection("comments").aggregateToStream(pipeline);
      a?.forEach((element) {
        print(element);
        setCommentList = CommentListModel.fromJson(element);
      });
      //setCommentList =await  a!.map((event) => CommentListModel.fromJson(event)).toList();
      pageNumber = pageNumber + 1;
    } catch(e){
      throw e;
    }

  }
  Future<void> fetchNextComments(String videoId) async {
    dbConnection = await fetchConnection();
    final pipeline = [
      {
        '\$lookup': {
          'from': 'users',
          'localField': 'userId',
          'foreignField': 'userId',
          'as': 'owner'
        }
      },
      {
        '\$match': {'videoId': videoId}
      },
      {
        '\$sort': {'createdDate': -1}
      },
       {'\$skip': (pageNumber - 1) * 10},
      {
        '\$limit': 10
      }
    ];

    // Fetch the first 10 videos from the database.
     try{
    var a = await  dbConnection?.collection("comments").aggregateToStream(pipeline);
    print("===================");
    a?.forEach((element) {
      print(element);
      setCommentList = CommentListModel.fromJson(element);
    });
    //setCommentList =await  a!.map((event) => CommentListModel.fromJson(event)).toList();
    pageNumber = pageNumber + 1;
    }catch(e){

      throw e;
    }

  }

  addComment(String comment,String userId,String videoId)async{
    dbConnection = await fetchConnection();
    final watchedVideo = <String, dynamic>{
      'userId': userId,
      'videoId': videoId,
      'comment':comment,
      "createdDate":DateTime.now()
    };
    setCommentList = CommentListModel(userId: userId,comment: comment,createdDate:DateTime.now(),videoId: videoId,owner: [Owner(userId: dashBoardController.getMyAccountDetails.userId,userName: dashBoardController.getMyAccountDetails.userName,userProfile:dashBoardController.getMyAccountDetails.userProfile )] ) ;
    await dbConnection!.collection('comments').insert(watchedVideo).then((value) {
          });

  }
}


class CommentListModel {
  mongo.ObjectId? sId;
  String? userId;
  String? videoId;
  String? comment;
  DateTime? createdDate;
  List<Owner>? owner;

  CommentListModel(
      {this.sId,
        this.userId,
        this.videoId,
        this.comment,
        this.createdDate,
        this.owner});

  CommentListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    videoId = json['videoId'];
    comment = json['comment'];
    createdDate = json['createdDate'];
    if (json['owner'] != null) {
      owner = <Owner>[];
      json['owner'].forEach((v) {
        owner!.add(new Owner.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['videoId'] = this.videoId;
    data['comment'] = this.comment;
    data['createdDate'] = this.createdDate;
    if (this.owner != null) {
      data['owner'] = this.owner!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Owner {
  mongo.ObjectId? sId;
  String? userId;
  String? userEmail;
  String? userName;
  String? userProfile;
  String? createDate;
  int? followers;
  int? following;

  Owner(
      {this.sId,
        this.userId,
        this.userEmail,
        this.userName,
        this.userProfile,
        this.createDate,
        this.followers,
        this.following});

  Owner.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    userEmail = json['user_email'];
    userName = json['user_name'];
    userProfile = json['user_profile'];
    createDate = json['create_date'];
    followers = json['followers'];
    following = json['following'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['user_email'] = this.userEmail;
    data['user_name'] = this.userName;
    data['user_profile'] = this.userProfile;
    data['create_date'] = this.createDate;
    data['followers'] = this.followers;
    data['following'] = this.following;
    return data;
  }
}
