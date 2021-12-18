part of 'get_infor_bloc.dart';

abstract class GetInforEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class StartEvent extends GetInforEvents {}

class GetInforEventStated extends GetInforEvents {
  // final String token;
  // ProfileEventStated({required this.token});
}
