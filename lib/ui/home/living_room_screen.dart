import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo/blocs/living_room/living_room_bloc.dart';
import 'package:iot_demo/configs/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iot_demo/models/sensor_sub.dart';
import 'package:iot_demo/models/sensors_res.dart';
import 'package:iot_demo/network/apis.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart' as mqttServer;
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:shared_preferences/shared_preferences.dart';

class LivingRoomScreen extends StatelessWidget {
  const LivingRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LivingRoomBloc>(
            create: (_) => LivingRoomBloc()..add(LivingRoomEventStated())),
      ],
      child: Body(),
    );
  }
}
enum Device { lamb1, fan }
class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Duration timer = Duration(hours:0, minutes: 0);

  Api? api;
  bool led1 = false;
  bool led2 = false;
  bool led3 = false;
  bool tivi = false;
  bool auto = false;
  bool airConditioning =false;
  String humidityAir = '...';
  String temperature = '...';


  String broker = 'broker.mqttdashboard.com';
  int port = 1883;
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
    client = mqttServer.MqttServerClient('broker.mqttdashboard.com', '');
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
      await client.connect('', '');
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
    subscription = client.updates.listen(_onMessage);
    _subscribeToTopic("demo");
  }

  void publishTopic(String pubTopic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
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
    Sensor sensor = Sensor();
    try {
      Map<String, dynamic> results = json.decode(message);
      sensor = Sensor.fromJson(results);
    } catch (e) {
      print(e);
    }
    setState(() {
      humidityAir = sensor.humidityAir.toString();
      temperature = sensor.temperature.toString();
    });
  }

  void toggleSwitchLed1(bool value) {
    if (led1 == false) {
      setState(() {
        led1 = true;
      });
      publishTopic('lamb1','{"Status":"1","Timer":"0"}');
    } else {
      setState(() {
        led1 = false;
      });
      publishTopic('lamb1','{"Status":"0","Timer":"0"}');
    }
  }
  void toggleSwitchLed2(bool value) {
    if (led2 == false) {
      setState(() {
        led2 = true;
      });
      publishTopic('lamb2','{"Status":"1","Timer":"0"}');
    } else {
      setState(() {
        led2 = false;
      });
      publishTopic('lamb2','{"Status":"0","Timer":"0"}');
    }
  }
  void toggleAuto(bool value) {
    if (auto == false) {
      setState(() {
        auto = true;
      });
    } else {
      setState(() {
        auto = false;
      });
    }
  }
  void toggleSwitchLed3(bool value) {
    if (led3 == false) {
      setState(() {
        led3 = true;
      });
      publishTopic('lamb3','{"Status":"1","Timer":"0"}');
    } else {
      setState(() {
        led3 = false;
      });
      publishTopic('lamb3','{"Status":"0","Timer":"0"}');
    }
  }
  void toggleSwitchTivi(bool value) {
    if (tivi == false) {
      setState(() {
        tivi = true;
      });
      publishTopic('tivi','{"Status":"1","Timer":"0"}');
    } else {
      setState(() {
        tivi = false;
      });
      publishTopic('tivi','{"Status":"0","Timer":"0"}');
    }
  }
  void toggleSwitchAirConditioning(bool value) {
    if (airConditioning == false) {
      setState(() {
        airConditioning = true;
      });
      publishTopic('airConditioning','{"Status":"1","Timer":"0"}');
    } else {
      setState(() {
        airConditioning = false;
      });
      publishTopic('airConditioning','{"Status":"0","Timer":"0"}');
    }
  }

  void initState() {
    _connect();
   // dateTime = getDateTime();
    super.initState();
  }



  DateTime getDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SensorsResponse sensorsResponse = SensorsResponse();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
          child: Text(
            'Smart Home',
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Colors.blue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                    padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                    width: size.width * 0.6,
                    height: size.height * 0.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nhiệt độ: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              temperature,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),

                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Độ ẩm không khí: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              humidityAir,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align (
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap:  (){
                        //showDialog();
                        showDialog(
                            context: context,
                            builder: (BuildContext context,) {
                              Device? device = Device.lamb1;
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(20.0)), //thi
                                // s right here
                                child: StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setState) {

                                  return Container(
                                    height: size.height*0.65,
                                   // width: size.width*0.85,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                          const Text(
                                            'Hẹn giờ tắt thiết bị ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                                          ),
                                          ListTile(
                                            title: const Text('Hệ thống đèn'),
                                            leading: Radio<Device>(
                                              value: Device.lamb1,
                                              groupValue: device,
                                              onChanged: (Device? value) {
                                                setState(() {
                                                  device = value;
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('Quạt điện'),
                                            leading: Radio<Device>(
                                              value: Device.fan,
                                              groupValue: device,
                                              onChanged: (Device? value) {
                                                setState(() {
                                                  device = value;
                                                });
                                              },
                                            ),
                                          ),
                                      SizedBox(
                                        height: 120,
                                        width: 180,
                                        child: CupertinoTimerPicker(
                                          mode: CupertinoTimerPickerMode.hm,
                                          onTimerDurationChanged: (value) {
                                            setState(() => this.timer = value);
                                          },
                                        // child: CupertinoDatePicker(
                                        //   initialDateTime: dateTime,
                                        //   mode: CupertinoDatePickerMode.time,
                                        //   minuteInterval: 1,
                                        //   use24hFormat: true,
                                        //   onDateTimeChanged: (dateTime) =>
                                        //       setState(() => this.dateTime = dateTime),
                                         ),
                                      ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          SizedBox(
                                            width: 280.0,
                                            child: RaisedButton(
                                              onPressed: () {
                                                var time = timer.inMinutes;
                                                print ('{"Status":"0","Timer":"$time"}');
                                              //  print(timer.inHours);
                                                publishTopic(device.toString().substring(7),'{"Status":"0","Timer":"$time"}');
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Save",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              color: const Color(0xFF1BC0C5),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );}
                                ),
                              );
                            });
                       print('ddddddd');
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                        width: size.width*0.28,
                        height: size.height * 0.06,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50.withOpacity(0.5),
                          border:
                          Border.all(color: Colors.blueAccent, width: 1.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/images/timer.png",
                                  width: 28,
                                ),
                                const Text(
                                  ' Hẹn giờ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                      width: size.width,
                      height: size.height * 0.08,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50.withOpacity(0.5),
                        border:
                            Border.all(color: Colors.blueAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/living-room.png",
                                width: 36,
                              ),
                              const Text(
                                ' Đèn chiếu sáng',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          Transform.scale(
                              scale: 1,
                              child: Switch(
                                onChanged: toggleSwitchLed1,
                                value: led1,
                                activeColor: Colors.blue,
                                activeTrackColor: Colors.yellow,
                                inactiveThumbColor: Colors.redAccent,
                                inactiveTrackColor: Colors.orange,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                      margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                      width: size.width,
                      height: size.height * 0.08,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50.withOpacity(0.5),
                        border:
                        Border.all(color: Colors.blueAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/living-room.png",
                                width: 36,
                              ),
                              Text(
                                ' Đèn nền ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Auto',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Transform.scale(
                                  scale: 1,
                                  child: Switch(
                                    onChanged: toggleAuto,
                                    value: auto,
                                  )),
                            ],
                          ),
                          auto?
                          Transform.scale(
                              scale: 1,
                              child: Switch(
                                onChanged:  null,
                                value: led2,
                              )):
                          Transform.scale(
                              scale: 1,
                              child: Switch(
                                onChanged:  toggleSwitchLed2,
                                value: led2,
                                activeColor: Colors.blue,
                                activeTrackColor: Colors.yellow,
                                inactiveThumbColor: Colors.redAccent,
                                inactiveTrackColor: Colors.orange,
                              ))
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                      margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                      width: size.width,
                      height: size.height * 0.08,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50.withOpacity(0.5),
                        border:
                            Border.all(color: Colors.blueAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/living-room.png",
                                width: 36,
                              ),
                              Text(
                                ' Quạt điện ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          Transform.scale(
                              scale: 1,
                              child: Switch(
                                onChanged: toggleSwitchAirConditioning,
                                value: airConditioning,
                                activeColor: Colors.blue,
                                activeTrackColor: Colors.yellow,
                                inactiveThumbColor: Colors.redAccent,
                                inactiveTrackColor: Colors.orange,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 20, 5),
                      margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                      width: size.width,
                      height: size.height * 0.08,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50.withOpacity(0.5),
                        border:
                            Border.all(color: Colors.blueAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/living-room.png",
                                width: 36,
                              ),
                              Text(
                                ' Khóa Cửa ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          Transform.scale(
                              scale: 1,
                              child: Switch(
                                onChanged: toggleSwitchTivi,
                                value: tivi,
                                activeColor: Colors.blue,
                                activeTrackColor: Colors.yellow,
                                inactiveThumbColor: Colors.redAccent,
                                inactiveTrackColor: Colors.orange,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap:  (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context,) {
                       int t=30;
                       // Future<int> loadData() async {
                       //   final SharedPreferences prefs = await SharedPreferences.getInstance();
                       //    int temp = prefs.getInt('temp') ?? 30;
                       //   setState(() {
                       //     t=temp;
                       //   });
                       //   return temp;
                       // }
                       // Future<int> tempChange(int t) async {
                       //   final SharedPreferences prefs = await SharedPreferences.getInstance();
                       //   setState(() {
                       //     prefs.setInt('temp', t);
                       //   });
                       //   return t;
                       // }
                        bool fan=false;
                        bool pow=false;
                        //Future<int> temp= loadData() ;
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(20.0)),
                          child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {

                                return Container(
                                  height: size.height*0.65,
                                  // width: size.width*0.85,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Text(
                                          'Điều khiển điều hòa',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          width: size.width*0.58,
                                          height: 100,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue.shade50.withOpacity(0.5),
                                            border:
                                            Border.all(color: Colors.blueAccent, width: 1.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/remote_control.png",
                                                    width: 28,
                                                  ),
                                                  Text(pow?'ON':'OFF',  style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            // FutureBuilder<int>(
                                            //     future: temp,
                                            //     builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                            //       switch (snapshot.connectionState) {
                                            //         case ConnectionState.waiting:
                                            //           return const CircularProgressIndicator();
                                            //         default:
                                            //           if (snapshot.hasError) {
                                            //             return Text('Error: ${snapshot.error}');
                                            //           } else {
                                            //             return Text(
                                            //               snapshot.data.toString()
                                            //             );
                                            //           }
                                            //       }
                                            //     }),
                                              Text(t.toString(),  style: const TextStyle(fontSize: 44,fontWeight: FontWeight.bold)),
                                              fan?Image.asset(
                                                "assets/images/fan1.png",
                                                width: 22,
                                              ):Image.asset(
                                                "assets/images/fan0.png",
                                                width: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            ElevatedButton(
                                                child: Text(
                                                    "ON/OFF".toUpperCase(),
                                                    style: const TextStyle(fontSize: 14)
                                                ),
                                                style: ButtonStyle(
                                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                            side: const BorderSide(color: Colors.red)
                                                        )
                                                    )
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    if(pow){
                                                      pow=false;
                                                    }else{
                                                      pow=true;
                                                    }
                                                  });
                                                }
                                            ),
                                            ElevatedButton(
                                                child: Text(
                                                    "Pan".toUpperCase(),
                                                    style: TextStyle(fontSize: 14)
                                                ),
                                                style: ButtonStyle(
                                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                            side: BorderSide(color: Colors.blueGrey)
                                                        )
                                                    )
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    if(fan){
                                                      fan=false;
                                                    }else{
                                                      fan=true;
                                                    }
                                                  });
                                                }
                                            ),
                                            ElevatedButton(
                                                child: Text(
                                                    "+".toUpperCase(),
                                                    style: TextStyle(fontSize: 14)
                                                ),
                                                style: ButtonStyle(
                                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                            side: BorderSide(color: Colors.blueGrey)
                                                        )
                                                    )
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                      //tempChange(t);
                                                    if(t<30){
                                                      t++;
                                                    }

                                                  });
                                                }
                                            ),
                                            ElevatedButton(
                                                child: Text(
                                                    "-".toUpperCase(),
                                                    style: TextStyle(fontSize: 14)
                                                ),
                                                style: ButtonStyle(
                                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                            side: BorderSide(color: Colors.blueGrey)
                                                        )
                                                    )
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    if(t>=10){
                                                      t--;
                                                    }
                                                  });
                                                }
                                            ),

                                          ],
                                        ),






                                      ],
                                    ),
                                  ),
                                );}
                          ),
                        );
                      });
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 10),
                  width: size.width*0.28,
                  height: size.height * 0.06,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50.withOpacity(0.5),
                    border:
                    Border.all(color: Colors.blueAccent, width: 1.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/remote_control.png",
                            width: 28,
                          ),
                          const Text(
                            ' Điều hòa',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                children: const [
                  Text(
                    ' Biểu đồ trong ngày ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red),
                  ),
                ],
              ),
              Column(
                children: [
                  Card(
                    child: BlocBuilder<LivingRoomBloc, LivingRoomState>(
                        builder: (context, state) {
                      if (state is LivingRoomLoadingState) {
                        return Container(
                            alignment: Alignment.topCenter,
                            height: size.height * 0.18,
                            child: const CircularProgressIndicator());
                      } else if (state is LivingRoomLoadedState) {
                        sensorsResponse = state.sensorsResponse;
                        List<Datum>? data = sensorsResponse!.data;
                        final List<FlSpot> dummyData1 = List.generate(data!.length, (index) {
                          return FlSpot(index.toDouble(), data[index].humidityAir!.toDouble());
                        });

                        final List<FlSpot> dummyData2 = List.generate(data!.length, (index) {
                          return FlSpot(index.toDouble(), data[index].temperature!.toDouble());
                        });
                        return Container(
                          height: size.height * 0.4,
                          padding: const EdgeInsets.fromLTRB(0,5,5,0),
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 100,
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTextStyles: (value) => const TextStyle(
                                    color: Color(0xff68737d),
                                    fontSize: 14,
                                  ),
                                  getTitles: (value) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return '24h trước';
                                      // case 10:
                                      //   return '12h trước';
                                      // case 20:
                                      //   return 'Hiện tại';
                                    }
                                    return '';
                                  },
                                  margin: 8,
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dummyData1,
                                  isCurved: true,
                                  barWidth: 3,
                                  colors: [
                                    Colors.blue,
                                  ],
                                ),
                                LineChartBarData(
                                  spots: dummyData2,
                                  isCurved: true,
                                  barWidth: 3,
                                  colors: [
                                    Colors.red,
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:  [
                      Icon(Icons.show_chart, color: Colors.red, size: 30,),
                      Text('Nhiệt độ'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30,0,20,0),
                        child: Row(
                          children:  [
                            Icon(Icons.show_chart, color: Colors.blue,size: 30),
                            Text('Độ ẩm'),
                          ],
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
