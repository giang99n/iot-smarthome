part of 'profile_bloc.dart';

abstract class ProFileEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class StartEvent extends ProFileEvents {}

class ProFileEventStated extends ProFileEvents {
  // final String token;
  // ProfileEventStated({required this.token});
}
