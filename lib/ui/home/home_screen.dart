import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:iot_demo/blocs/home/home_bloc.dart';
import 'package:iot_demo/models/sensor_sub.dart';
import 'package:iot_demo/network/apis.dart';
import 'package:iot_demo/network/mqtt.dart';
import 'package:iot_demo/ui/home/living_room_screen.dart';
import 'package:iot_demo/ui/home/profile_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_server_client.dart' as mqttServer;
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
            create: (_) => HomeBloc()..add(HomeEventStated())),
      ],
      child:Scaffold(
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
        ),
        body: BuildHomeScreen(),
      )
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
  HomeBloc? homeBloc;
//  var mqtt= MQTT();
  String humidityAir='...';
  String temperature='...';

  String broker           = 'broker.mqttdashboard.com';
  int port                = 1883;
  String clientIdentifier = 'flutter';

  late mqttServer.MqttServerClient client;
  late mqtt.MqttConnectionState connectionState;

  StreamSubscription? subscription;

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);

    }
    print('[MQTT client] onScribe');

  }

  void _connect() async {
    client = mqttServer.MqttServerClient('broker.mqttdashboard.com','');
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect('','');
    } catch (e) {
      print('lỗi rồi, disconnect thôi');
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);

     _subscribeToTopic("demo");

    // const pubTopic = 'lam1';
    // final builder = MqttClientPayloadBuilder();
    // builder.addString('Hello MQTT');
    // client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    // setState(() {
    //   //topics.clear();
    //   connectionState = client.connectionState;
    //   client = null;
    //   subscription!.cancel();
    //   subscription = null;
    // });
    print('[MQTT client] MQTT client disconnected');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    Sensor sensor= Sensor();
    try {
      Map<String,dynamic> results =  json.decode(message);
       sensor = Sensor.fromJson(results);
    } catch (e) {
     print(e);
    }
    setState(() {
      humidityAir = sensor.humidityAir.toString();
      temperature=sensor.temperature.toString();
    });
  }





  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 4, vsync: this);
    _connect();
 //   mqtt.publishTopic('pubTopic', 'message');
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
                  size: 32,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.person,
                  size: 32,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.notifications_none,
                  size: 30,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.settings_outlined,
                  size: 30,
                ),
              ),
            ],
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border( top: BorderSide(color: Colors.blueAccent,width: 0.8),),
              ),
              child: TabBarView(
                children: [
                  _home(context),
                  //ProFileScreen(),
                  _profile(context),
                  _notify(context),
                  _rank(context)
                ],
                controller: _tabController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _home(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding:const EdgeInsets.fromLTRB(0,5,0,10) ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LivingRoomScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(5,10,0,0),
              padding:  const EdgeInsets.fromLTRB(10,0,20,5),
              width: size.width * 0.88,
              height: size.width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent,width: 2),
                borderRadius: BorderRadius.circular(8),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          "assets/images/living-room.png",
                          width: size.width * 0.24,
                        ),
                      ),
                      const Text(
                        "Phòng khách",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget>[
                      Row(
                        children: [
                          Image.asset('assets/images/humidity.png', width: 40,),
                          Text(humidityAir, style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/temperature.png', width: 40,),
                          Text(temperature, style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LivingRoomScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(5,10,0,0),
              padding:  const EdgeInsets.fromLTRB(10,0,20,5),
              width: size.width * 0.88,
              height: size.width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,width: 2),
                borderRadius: BorderRadius.circular(8),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                       'assets/images/bedroom.png',
                          width: size.width * 0.25,
                        ),
                      ),
                      const Text(
                        "Phòng ngủ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget>[
                      Row(
                        children: [
                          Image.asset('assets/images/humidity.png', width: 40,),
                          Text(humidityAir, style: TextStyle(color: Colors.black),),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/temperature.png', width: 40,),
                          Text(temperature, style: TextStyle(color: Colors.black),),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LivingRoomScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(5,10,0,0),
              padding:  const EdgeInsets.fromLTRB(10,0,20,5),
              width: size.width * 0.88,
              height: size.width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,width: 2),
                borderRadius: BorderRadius.circular(8),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          "assets/images/kitchen.png",
                          width: size.width * 0.23,
                        ),
                      ),
                      const Text(
                        "Phòng bếp",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget>[
                      Row(
                        children: [
                          Image.asset('assets/images/humidity.png', width: 40,),
                          Text(humidityAir, style: TextStyle(color: Colors.black),),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/temperature.png', width: 40,),
                          Text(temperature, style: TextStyle(color: Colors.black),),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LivingRoomScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(5,10,0,0),
              padding:  const EdgeInsets.fromLTRB(10,0,20,5),
              width: size.width * 0.88,
              height: size.width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,width: 2),
                borderRadius: BorderRadius.circular(8),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                        "Phòng ngủ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget>[
                      Row(
                        children: [
                          Image.asset('assets/images/humidity.png', width: 40,),
                          Text(humidityAir , style: TextStyle(color: Colors.black),),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/temperature.png', width: 40,),
                          Text(temperature, style: TextStyle(color: Colors.black),),
                        ],
                      ),

                    ],
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


