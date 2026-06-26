import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import '../../../utils/colors.dart';
import '../../../utils/editor/domain/bloc/controller.dart';
import '../../../utils/editor/domain/entities/cover_style.dart';
import '../../../utils/editor/ui/cover/cover_selection.dart';
import '../../../utils/editor/ui/crop/crop_grid.dart';
import '../../../utils/loader.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/upload_video_controller.dart';


class AddPostView extends StatefulWidget {
  const AddPostView({Key? key}) : super(key: key);

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {

  UploadVideoController uploadVideoController = Get.put(UploadVideoController());
  DashBoardController videoController = Get.find();
  VideoEditorController? _controller ;
  VideoEditorController? _tumbainController ;
  FilePickerResult? result;
  void _showDialog() {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // Return an AlertDialog
        return AlertDialog(

          title: Center(child: Text("Alert")),
          content: Text("Please select maximum 30 seconds video"),

          actions: <Widget>[
            // Cancel Button
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  videoController.setCurrentIndex = 0;// Dismiss the dialog
                },
                child: Container(
                  
                  height: 35,
                  width: 70,
                  decoration: BoxDecoration(
                    color: ColorConstants.appThemeColor,
                    borderRadius: BorderRadius.circular(5)
                        
                  ),
                  child: Center(child: Text("Ok",style: TextStyle(color: Colors.white),),),
                  
                ),
              ),
            ),
            // OK Button

          ],
        );
      },
    );
  }
  @override
  void initState() {

    pickVideo();
    super.initState();
  }

  pickVideo(){
    pickFile().then((value) {
      _controller = VideoEditorController.file( File(result!.paths.first!),minDuration: const Duration(seconds: 1), maxDuration: const Duration(seconds: 30)
      );
      _controller!.initialize().then((_) => setState(() {
        print("============result-----------");
        print(_controller!.video.value.duration);
        if(_controller!.video.value.duration.inSeconds>30){
          // Define a function that will show the dialog

          _showDialog();
          print("please select max 30 sec video");
          //
        }
      }));
      _tumbainController = VideoEditorController.file( File(result!.paths.first!),minDuration: const Duration(seconds: 1),
          maxDuration: const Duration(seconds: 30)
      );
      _tumbainController!.initialize().then((_) => setState(() {}));
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    _tumbainController!.dispose();
    super.dispose();
  }

 Future<void> pickFile()async{
     result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowCompression: false,
        allowedExtensions: ["mp4"]);
    if (result == null) {
      return;
    }
    else{
      print('==============picker===========');
     // print(result.paths);
     // return result.paths;
    }
  }


  final double height = 60;


  void _uploadEncodedVideo()async {
    try{
      showLoader(context);
      List<UploadContentPath> content = [];
      final output = "${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch.toString()}.${_controller!.file.path.split(".").last}";
      final inputFile = _controller!.file.path;
      final videoTempPath = await getTemporaryDirectory();
      final thumNailFile =  Uint8List.fromList(_tumbainController!.selectedCoverVal!.thumbData!);
      final f = await getTemporaryDirectory();
      final tempFile1 = File("${f.path}/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
      await tempFile1.writeAsBytes(thumNailFile);
      final outputFile = "${videoTempPath.path}/${output}";
      final String maxBitrate = '1000000';
      final String escapedInputFile = '\"${File(inputFile).path}\"';
     // final String command = '-i $inputFile ''-c:v libx264 -b:v $maxBitrate -maxrate $maxBitrate -bufsize $maxBitrate ''-c:a aac -b:a 128k ''-movflags faststart ''$outputFile';
      final String command = '-i $escapedInputFile -c:v libx264 -b:v $maxBitrate -maxrate $maxBitrate -bufsize $maxBitrate -vf scale=720:-2 -c:a aac -b:a 512k -movflags faststart $outputFile';
      FFmpegKit.execute(command).then((session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          content.add(UploadContentPath(outputFile, output));
          content.add(UploadContentPath(tempFile1!.path, tempFile1!.path.split("/").last));
          videoController.uploadContent(content,context);
        } else if (ReturnCode.isCancel(returnCode)) {
          print("=====not=====encoded=========video====");
          // CANCEL

        } else {
          print("==========error===");
          // ERROR

        }
      });
    }catch(e){
      throw e;
    }

  }







  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(

        appBar: AppBar(
          backgroundColor: ColorConstants.appThemeColor,
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: (){
                if(_controller==null){
                  videoController.setCurrentIndex = 0;
                }else{
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      // Return an AlertDialog
                      return AlertDialog(
                        title: Center(child: Text("Alert")),
                        content: Text("Are you sure you want to exit ?"),

                        actions: <Widget>[
                          // Cancel Button
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                // Dismiss the dialog
                              },
                              child: Container(

                                height: 35,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: ColorConstants.appThemeColor,
                                    borderRadius: BorderRadius.circular(5)

                                ),
                                child: Center(child: Text("Cancel",style: TextStyle(color: Colors.white),),),

                              ),
                            ), SizedBox(width: 10,),InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                videoController.setCurrentIndex = 0;// Dismiss the dialog
                              },
                              child: Container(

                                height: 35,
                                width: 70,
                                decoration: BoxDecoration(
                                    color:ColorConstants.appThemeColor,
                                    borderRadius: BorderRadius.circular(5)

                                ),
                                child: Center(child: Text("Ok",style: TextStyle(color: Colors.white),),),

                              ),
                            ),],),
                          ),

                          // OK Button

                        ],
                      );
                    },
                  );
                }
              },
              child: CircleAvatar(
                child: Center(child: Icon(Icons.arrow_back_ios_sharp)),
              ),
            ),
          ),
          actions: [Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: (){
                print("========upload===");
                _uploadEncodedVideo();
                //_uploadVideo();
                //_exportVideo();
              },
              child: CircleAvatar(
                child: Center(child: Icon(Icons.arrow_forward_ios)),
              ),
            ),
          )],
        ),
        backgroundColor: Colors.black87,
        body: _controller!=null
            ? SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                 SizedBox(height: 20,),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CropGridViewer.preview(
                                  controller: _controller!),
                              AnimatedBuilder(
                                animation: _controller!.video,
                                builder: (_, __) =>
                                    Visibility(
                                      visible: !_controller!.isPlaying,
                                      child: GestureDetector(
                                        onTap: _controller!.video.play,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration:
                                          const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(top: 10),
                          child: _coverSelection(),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _tumbainController!,
            size: height + 10,
            quantity: 10,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

