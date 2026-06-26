import 'package:mongo_dart/mongo_dart.dart';

class VideoModel {
  String? video;
  String? thumbnail;
  int? views;
  int? likes;
  String? createDate;
  String? key;
  String? id;
  String? url;
  String? userName;
  String? userEmail;
  String? userProfile;
  String? userId;
  bool? isLiked;
  bool? isWatched;
  bool? isSaved;
  bool? isLoadAds;

  VideoModel({this.video, this.key,this.id,this.url,this.createDate,this.likes,this.thumbnail,this.views,this.userName,this.userEmail,this.userProfile,this.isLiked,this.userId,this.isWatched,this.isSaved,this.isLoadAds});

  VideoModel.fromJson(Map<String, dynamic> json) {
    video = json['video'];
    key = json['key'];
    id = json['id'];
    url = json['url'];
    createDate = json['createDate'];
    likes = json['likes'];
    thumbnail = json['thumbnail'];
    views = json['views'];
    userName = json['userName'];
    userEmail = json['userEmail'];
    userProfile = json['userProfile'];
    userId = json['userId'];
    isLiked = json['isLiked'];
    isWatched = json['isWatched'];
    isSaved = json['isSaved'];
    isLoadAds = json['isLoadAds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['video'] = this.video;
    data['key'] = this.key;
    data['id'] = this.id;
    data['url'] = this.url;
    data['userName'] = this.userName;
    data['userEmail'] = this.userEmail;
    data['userProfile'] = this.userProfile;
    data['userId'] = this.userId;
    data['isLiked'] = this.isLiked;
    data['isWatched'] = this.isWatched;
    data['isSaved'] = this.isSaved;
    data['isLoadAds'] = this.isLoadAds;
    return data;
  }
}

class Owner {
  ObjectId? sId;
  String? userId;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userProfile;
  String? createDate;
  int? followers;
  int? following;
  int? userType;

  Owner(
      {this.sId,
        this.userId,
        this.userName,
        this.userProfile,
        this.createDate,
        this.followers,
        this.following,
        this.userEmail,
        this.userPhone,
        this.userType
      });

  Owner.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
    userProfile = json['user_profile'];
    createDate = json['create_date'];
    followers = json['followers'];
    following = json['following'];
    userType = json['user_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['user_name'] = this.userName;
    data['user_email'] = this.userEmail;
    data['user_phone'] = this.userPhone;
    data['user_profile'] = this.userProfile;
    data['create_date'] = this.createDate;
    data['followers'] = this.followers;
    data['following'] = this.following;
    data['user_type'] = this.userType;
    return data;
  }
}



class LikedVideoModel {
  ObjectId? sId;
  String? userId;
  String? videoId;

  LikedVideoModel({this.sId, this.userId, this.videoId});

  LikedVideoModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    videoId = json['videoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['videoId'] = this.videoId;
    return data;
  }
}
