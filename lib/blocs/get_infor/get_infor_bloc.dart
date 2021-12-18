
import 'package:equatable/equatable.dart';
import 'package:iot_demo/models/infor_res.dart';
import 'package:iot_demo/network/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_infor_event.dart';
part 'get_infor_state.dart';

class GetInforBloc extends Bloc<GetInforEvents, GetInforState> {
  GetInforBloc() : super(GetInforLoadingState());

  @override
  Stream<GetInforState> mapEventToState(GetInforEvents event) async* {
    final apiRepository = Api();
    final pref = await SharedPreferences.getInstance();
    String token = (pref.getString('token') ?? "");
    String userId = (pref.getString('userId') ?? "");
    if (event is StartEvent) {
      yield GetInforInitState();
    } else if (event is GetInforEventStated) {
      yield GetInforLoadingState();
      var data = await apiRepository.getInFor(token, userId);
      if (data != null) {
        if (data!.status ==  "success") {
          yield GetInforLoadedState(listInfor: data);
        } else if (data.status ==  "error") {
          //
        }
      } else {
        yield GetInforErrorState();
      }
    }
  }
}
