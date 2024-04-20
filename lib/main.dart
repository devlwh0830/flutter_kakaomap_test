import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");	// 추가
  AuthRepository.initialize(appKey: '87c4015ad199ea95e5fdc38e47dfdf0b');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '카카오맵 API 테스팅',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '카카오맵 API 테스팅'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var x;
  var y;
  var distance = "?㎞";

  getPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      print('허락됨');
    } else if (status.isDenied) {
      print('거절됨');
      Permission.location.request();   // 현재 거절된 상태니 팝업창 띄워달라는 코드
    }
  }

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Set<Marker> markers = {Marker(
      markerId : "학교위치",
      latLng : LatLng(37.48373557342313,127.0055628030269)
  )};
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:Stack(
        children: [
          KakaoMap(onMapCreated: ((controller) async {
            mapController = controller;
            mapController.setCenter(LatLng(37.48373557342313,127.0055628030269));
          }),
            markers: markers.toList(),
            onMarkerTap: (markerName,xy,number) {
              print(markerName);
              print(xy);
              print(number);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                        '내 집에서 학교까지의 거리 : $distance',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () async {
                    Fluttertoast.showToast(
                        msg: "잠시만 기다려 주세요...",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue.shade400,
                        textColor: Colors.white,
                        fontSize: 15.0,
                    );
                    getPermission();
                    Position position = await getCurrentLocation();
                    mapController.addMarker(markers: [Marker(
                        markerId : "내위치",
                        infoWindowContent: "내위치",
                        latLng : LatLng(position.latitude, position.longitude)
                    )]);
                    var result = await getSchoolDistance(position.longitude.toString(),position.latitude.toString());
                    setState(() {
                      distance = result;
                    });
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                        msg: "완료되었습니다.",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue.shade400,
                        textColor: Colors.white,
                        fontSize: 15.0
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '거리 계산 하기',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
