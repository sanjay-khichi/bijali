
import 'package:get/get.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

 Future<double> getSoundInfo()async{
  print("============ringtoneStatus========");
  RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;
  ringerStatus.name;
  print(ringerStatus.name);
  switch(ringerStatus.name){
    case "vibrate":
      return await 0;
    case "silent":
      return await 0;
    case "normal":
      return await 1;
    default:
      return await 1;
  }
  print("============ringtoneStatusResult========");
}

var soundStatus = getSoundInfo().obs;
Future<double> get getSoundStatus => soundStatus.value;
 setSoundStatus(Future<double> val)async{
  soundStatus.value =  val;
  soundStatus.refresh();
}
