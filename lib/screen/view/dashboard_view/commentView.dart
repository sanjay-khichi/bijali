import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/colors.dart';
import '../../controller/comment_controller.dart';


class CommentListScreen extends StatefulWidget {
  CommentListScreen({this.videoId,this.userId});
  String? videoId,userId;
  @override
  _CommentListScreenState createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {

  TextEditingController commentController = TextEditingController();
  CommentController controller = Get.put(CommentController());
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    controller.fetchNextComments(widget.videoId!);
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.appThemeColor,
        elevation: 0,
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(()=>SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext? context,LoadStatus? mode){
                  Widget body ;
                  if(mode==LoadStatus.idle){
                    body =  Text("pull up load");
                  }
                  else if(mode==LoadStatus.loading){
                    body =  CupertinoActivityIndicator();
                  }
                  else if(mode == LoadStatus.failed){
                    body = Text("Load Failed!Click retry!");
                  }
                  else if(mode == LoadStatus.canLoading){
                    body = Text("release to load more");
                  }
                  else{
                    body = Text("No more Data");
                  }
                  return Container(
                    height: 55.0,
                    child: Center(child:body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                itemCount: controller.getCommentList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(top: 10,left: 10),
                        child: CachedNetworkImage(imageUrl: controller.getCommentList[index].owner!.isEmpty?"Anonymous":controller.getCommentList[index].owner!.first.userProfile!,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(controller.getCommentList[index].owner!.isEmpty?"Anonymous":controller.getCommentList[index].owner!.first.userName!),
                          subtitle:Text(controller.getCommentList[index].comment!) ,
                        ),
                      )
                    ],);
                },
              ),
            )),
          ),
          Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your comment',

                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      controller.addComment(commentController.text,widget.userId!,widget.videoId!);
                      FocusScope.of(context).unfocus();
                      commentController.clear();
                    });

                  },

                ),
              ],
            ),
          )
        ],
      ),

    );
  }
}
