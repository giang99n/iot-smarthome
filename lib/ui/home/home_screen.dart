import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:iot_demo/network/apis.dart';
import 'package:iot_demo/ui/home/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return  Scaffold(
          //extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Container(
              child: Text(
                'IOT Smart Home',
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(6.5),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(
                      width: 1,
                      color: Colors.blue.withOpacity(0.5),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_outlined,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          body: BuildHomeScreen(),
        );
  }
}

class BuildHomeScreen extends StatefulWidget {
  const BuildHomeScreen({Key? key}) : super(key: key);

  @override
  _BuildHomeScreenState createState() => _BuildHomeScreenState();
}

class _BuildHomeScreenState extends State<BuildHomeScreen>
    with SingleTickerProviderStateMixin {
  String avatar = '';
  TabController? _tabController;
  Api? api ;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: [
          TabBar(
            unselectedLabelColor: Colors.black54,
            labelColor: Colors.blue,
            tabs: const [
              Tab(
                child: Icon(
                  Icons.home,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.person,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.notifications_none,
                  color: Colors.black,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.star_border_outlined,
                  color: Colors.black,
                ),
              ),
            ],
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _home(context),
                ProFileScreen(),
                _notify(context),
                _rank(context)
              ],
              controller: _tabController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _home(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (){

            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(5,10,0,0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: size.width * 0.88,
              height: size.width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      "assets/images/introduce1.jpg",
                      width: size.width * 0.3,
                    ),
                  ),
                  const Text(
                    "Phòng khách",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: (){
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(5,10,0,0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: size.width * 0.88,
              height: size.width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/images/introduce1.jpg",
                      width: size.width * 0.3,
                    ),
                  ),
                  const Text(
                    "Phòng ngủ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );

  }

  Widget _profile(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: const EdgeInsets.only(top: 10), child: Text('profile'));
  }

  Widget _notify(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: const EdgeInsets.only(top: 10), child: Text('notify'));
  }

  Widget _rank(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: const EdgeInsets.only(top: 10), child: Text('rank'));
  }


}
