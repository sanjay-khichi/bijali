import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/colors.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/profile_controller.dart';
import '../settings/settings.dart';
import 'profile_video_view.dart';

class ProfileView extends StatefulWidget {
   ProfileView(this.uId,this.isNew, {this.name, this.url}) ;
   String uId;
   String? name,url;
   bool isNew;
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {



  ProfileController videoController = Get.put(ProfileController());
  DashBoardController dashBoardController = Get.find();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  RefreshController _refreshController1 = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    print("===========referesh=====");
    videoController.fetchNextVideo(widget.uId);
    _refreshController.refreshCompleted();
  }
  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    videoController.fetchNextVideo(widget.uId);
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }
  void _onRefresh1() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    print("===========referesh=====");
    videoController.fetchSavedNextVideo(widget.uId);
    _refreshController1.refreshCompleted();
  }
  void _onLoading1() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    videoController.fetchSavedNextVideo(widget.uId);
    if(mounted)
      setState(() {

      });
    _refreshController1.loadComplete();
  }
  @override
  void initState() {
    // TODO: implement initState
    videoController.loadingText.value = "Loading...";
    videoController.savedloadingText.value = "Loading...";
    videoController.fetchVideo(widget.uId);
    if(widget.isNew ==true){
      videoController.fetchSavedVideo(widget.uId);
      myTabs = <Tab>[Tab(icon: SvgPicture.asset("assets/icons/my_coontent.svg")), Tab(icon:  SvgPicture.asset("assets/icons/save.svg",color: ColorConstants.appThemeColor,),),
      ];
    }else{
      myTabs = <Tab>[Tab(icon: SvgPicture.asset("assets/icons/my_coontent.svg")),
      ];
    }
    super.initState();
  }
    List<Tab>? myTabs ;
  @override
  Widget build(BuildContext context) {
    print("====================");
    print(dashBoardController.getMyAccountDetails.toJson());
    return Scaffold(

      body: Column(

        children: [
          SizedBox(height: 50,),
          Column(
           crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2), shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: InkWell(
                  onTap: (){


                  },
                  child:widget.isNew == false? CachedNetworkImage(
                    imageUrl: widget.url!,
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover),
                          ),
                        ),
                    placeholder: (context, url) =>
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: ColorConstants.appThemeColor,
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,

                          ),
                        ),
                    errorWidget: (context, url, error) =>
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: ColorConstants.appThemeColor,
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,

                          ),
                        ),
                  ):Obx((){
                    if(dashBoardController.getMyAccountDetails.userProfile!=null)
                      return CachedNetworkImage(
                        imageUrl: dashBoardController.getMyAccountDetails.userProfile!,
                        imageBuilder: (context, imageProvider) =>
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover),
                              ),
                            ),
                        placeholder: (context, url) =>
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                color: ColorConstants.appThemeColor,
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,

                              ),
                            ),
                        errorWidget: (context, url, error) =>
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                color: ColorConstants.appThemeColor,
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,

                              ),
                            ),
                      );
                    else
                      return SizedBox();
                  }

                  ),
                ),),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                widget.isNew == false? Text(widget.name!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),):  Obx(()=>Text(dashBoardController.getMyAccountDetails.userName==null?"":dashBoardController.getMyAccountDetails.userName!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                  SizedBox(height: 10,),
                  if(widget.uId == FirebaseAuth.instance.currentUser!.uid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(),));
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: ColorConstants.appThemeColor,)
                            ),
                            child: Center(child: Text("Edit",style: TextStyle(color: ColorConstants.appThemeColor),)),

                          ),
                        ),
                      ],
                    )

                ],)
            ],
          ),
          SizedBox(height: 10,),
          Divider(),
          Expanded(
            child: DefaultTabController(length: widget.isNew==true?2:1, child:  DefaultTabController(
              length: myTabs!.length,
              child: Column(children: [
                TabBar(
                  labelColor: ColorConstants.appThemeColor,
                  tabs: myTabs!,
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: TabBarView(

                    children: [
                      Obx((){
                        if(videoController.getController.length==0){
                          if(videoController.getLoadingText == "Loading..."){
                            return Center(child: CircularProgressIndicator(),);
                          }else{
                            return Center(child: Text(videoController.getLoadingText),);
                          }

                        }else{
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: SmartRefresher(
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
                                child: Wrap(
                                    alignment: WrapAlignment.spaceEvenly,
                                    spacing: -5,
                                    runSpacing: 6,
                                    direction: Axis.horizontal,
                                    children:List.generate(videoController.getController.length, (index) {
                                      if(videoController.getController[index].isLoadAds ==true){
                                        return SizedBox();
                                      }else{
                                        return InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileVideoView(videoController.getController[index].userId!,index,true,false),));
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context).size.width * 0.6,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: ColorConstants.appThemeColor)
                                            ),
                                            child: CachedNetworkImage(

                                              imageUrl: videoController.getController[index].thumbnail!,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey.withOpacity(0.5),
                                                height: MediaQuery.of(context).size.width * 0.6,
                                                width: MediaQuery.of(context).size.width * 0.3,

                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        );
                                      }

                                    })
                                ),
                              )
                          );
                        }

                      }),
                      if(widget.isNew==true)
                      Obx((){

                        if(videoController.getSavedController.length==0){
                          if(videoController.getLoadingText == "Loading..."){
                            return Center(child: CircularProgressIndicator(),);
                          }else{
                            return Center(child: Text(videoController.getLoadingText),);
                          }

                        }else{
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: SmartRefresher(
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
                                controller: _refreshController1,
                                onRefresh: _onRefresh1,
                                onLoading: _onLoading1,
                                child: Wrap(
                                    alignment: WrapAlignment.spaceEvenly,
                                    spacing: -5,
                                    runSpacing: 6,
                                    direction: Axis.horizontal,
                                    children:List.generate(videoController.getSavedController.length, (index) {
                                      return InkWell(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileVideoView(videoController.getSavedController[index].userId!,index,true,true),));
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context).size.width * 0.6,
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: ColorConstants.appThemeColor)
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: videoController.getSavedController[index].thumbnail!,
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.withOpacity(0.5),
                                              height: MediaQuery.of(context).size.width * 0.6,
                                              width: MediaQuery.of(context).size.width * 0.3,

                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),
                                      );
                                    })
                                ),
                              )
                          );
                        }

                      }),
                    ],
                  ),
                ),

              ],)
            )),
          ),

        ],
      )
    );
  }

}

