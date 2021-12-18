part of 'get_infor_bloc.dart';

class GetInforState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetInforInitState extends GetInforState {}

class GetInforLoadingState extends GetInforState {}

class GetInforErrorState extends GetInforState {}

class GetInforLoadedState extends GetInforState {
  final InforResponse listInfor;

  GetInforLoadedState({required this.listInfor});

  @override
  List<Object> get props => [listInfor];
}
