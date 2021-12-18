import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:iot_demo/network/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_events.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  Api apiRepository;

  LoginBloc(LoginState initialState, this.apiRepository) : super(initialState);

  @override
  Stream<LoginState> mapEventToState(LoginEvents event) async* {
    final pref = await SharedPreferences.getInstance();
    if (event is StartEvent) {
      yield LoginInitState();
    } else if (event is LoginButtonPressed) {
      yield LoginLoadingState();
      var data = await apiRepository.login(event.email, event.password);
      print(data.toString());
      if (data != null) {
        if (data!.status == "success") {
          await pref.remove('errorLogin');
          pref.setString('token', data!.data!.session!.id.toString() ?? "");
          pref.setString('userId', data!.data!.session!.userId.toString() ?? "");
          pref.setString('avatar', data!.data!.user!.avatar.toString()??'');
          yield LoginSuccessState();
        } else if (data!.status == "error") {
          print("login error");
          yield LoginErrorState(
              message: data.error ??
                  "đăng nhập thất bại");
        }
      } else {
        yield LoginErrorState(
            message:pref.getString('errorLogin') ?? "đăng nhập thất bại");
      }
    }
  }
}
