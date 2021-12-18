import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/blocs/get_infor/get_infor_bloc.dart';
import 'package:iot_demo/blocs/profile/profile_bloc.dart';
import 'package:iot_demo/configs/colors.dart';
import 'package:iot_demo/models/infor_res.dart';
import 'package:iot_demo/models/user_res.dart';
import 'package:iot_demo/network/apis.dart';
class ProFileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProFileBloc>(
            create: (_) => ProFileBloc()..add(ProFileEventStated())),
        BlocProvider<GetInforBloc>(
            create: (_) => GetInforBloc()..add(GetInforEventStated())),
      ],
      child: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ProFileBloc? profileBloc;
  Api? api;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    InforResponse inforResponse;
    UserResponse userResponse;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: size.height * 0.3,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/giang.jpg",
                            width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.34,
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/giang.jpg'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<ProFileBloc, ProFileState>(
                    builder: (context, state) {
                  if (state is ProFileLoadingState) {
                    return Container(
                        alignment: Alignment.topCenter,
                        height: size.height * 0.18,
                        child: const CircularProgressIndicator());
                  } else if (state is ProFileLoadedState) {
                    userResponse = state.listProfile;
                    Data? listProfileResponse = userResponse.data;
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        listProfileResponse!.name.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
              ),
              Card(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProFileBloc, ProFileState>(
                          builder: (context, state) {
                        if (state is ProFileLoadingState) {
                          return Container(
                              alignment: Alignment.topCenter,
                              height: size.height * 0.18,
                              child: const CircularProgressIndicator());
                        } else if (state is ProFileLoadedState) {
                          userResponse = state.listProfile;
                          Data? listProfileResponse = userResponse.data;
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                children: [
                                   const Padding(
                                     padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                     child: Icon(
                                      Icons.phone,
                                      color: Colors.blue,
                                  ),
                                   ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                    child: Text(
                                      "Điện thoại: " + listProfileResponse!.phone.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle( fontStyle: FontStyle.italic,
                                        fontSize: 15, ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProFileBloc, ProFileState>(
                          builder: (context, state) {
                            if (state is ProFileLoadingState) {
                              return Container(
                                  alignment: Alignment.topCenter,
                                  height: size.height * 0.18,
                                  child: const CircularProgressIndicator());
                            } else if (state is ProFileLoadedState) {
                              userResponse = state.listProfile;
                              Data? listProfileResponse = userResponse.data;
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                      child: Icon(
                                        Icons.email,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                      child: Text(
                                        "Email: " + listProfileResponse!.username.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle( fontStyle: FontStyle.italic,
                                          fontSize: 15, ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<GetInforBloc, GetInforState>(
                          builder: (context, state) {
                            if (state is GetInforLoadingState) {
                              return Container(
                                  alignment: Alignment.topCenter,
                                  height: size.height * 0.18,
                                  child: const CircularProgressIndicator());
                            } else if (state is GetInforLoadedState) {
                               inforResponse = state.listInfor;
                              Data2? listGetInforResponse = inforResponse.data;
                              return Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                          child: Icon(
                                            Icons.badge,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                          child: Text(
                                            "Nghề nghiệp: " + listGetInforResponse!.job.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle( fontStyle: FontStyle.italic,
                                              fontSize: 15, ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(10, 10, 5, 0),
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width*0.8,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                            child: Text(
                                              "Địa chỉ: " + listGetInforResponse!.home!.address.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle( fontStyle: FontStyle.italic,
                                                fontSize: 15, ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(10, 10, 5, 0),
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                                          child: Text(
                                            "Giới thiệu: " + listGetInforResponse!.introduction.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle( fontStyle: FontStyle.italic,
                                              fontSize: 15, ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: SizedBox(
                                      width: size.width * 0.9,
                                      height: size.height*0.055,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                                        child: ElevatedButton(
                                          child: const Text(
                                            "Chỉnh sửa thông tin",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                          },
                                          style: ElevatedButton.styleFrom(
                                              primary: kPrimaryColor,
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
