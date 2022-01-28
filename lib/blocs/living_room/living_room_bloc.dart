
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:iot_demo/models/infor_res.dart';
import 'package:iot_demo/models/sensors_res.dart';
import 'package:iot_demo/network/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'living_room_event.dart';
part 'living_room_state.dart';

class LivingRoomBloc extends Bloc<LivingRoomEvents, LivingRoomState> {
  LivingRoomBloc() : super(LivingRoomLoadingState());

  @override
  Stream<LivingRoomState> mapEventToState(LivingRoomEvents event) async* {
    var formatter = DateFormat('yyyy-MM-dd');
    var now = DateTime.now();
    String currentDate = formatter.format(now);

    var yesterday = DateTime.now().subtract(Duration(days:1));
    String yesterdayDate = formatter.format(yesterday);

    final apiRepository = Api();
    if (event is StartEvent) {
      yield LivingRoomInitState();
    } else if (event is LivingRoomEventStated) {
      yield LivingRoomLoadingState();
      var data = await apiRepository.getSensors(currentDate,yesterdayDate);
      if (data != null) {
        if (data!.code ==  200) {
          yield LivingRoomLoadedState(sensorsResponse: data);
        }
      } else {
        yield LivingRoomErrorState();
      }
    }
  }
}
