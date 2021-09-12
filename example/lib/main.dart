import 'package:flutter/material.dart';
import 'package:omni_vision/omni_vision.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _busy = false;
  ValueNotifier<bool> active = ValueNotifier<bool>(false);
  ScrollController logScrollController = ScrollController();
  ValueNotifier<String> currentSessionLog = ValueNotifier<String>("");
  late TextEditingController sessiongLogController;
  GlobalKey<OmniMlVisionState> omniState = GlobalKey<OmniMlVisionState>();

  @override
  void initState() {
    _busy = true;
    sessiongLogController = TextEditingController(text: currentSessionLog.value);
    sessiongLogController.addListener(() {
      if (logScrollController.hasClients) {
        currentSessionLog.value = sessiongLogController.text;
        logScrollController.animateTo(logScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    });
    loadModel().then((value) => setState(() {
          _busy = false;
        }));
    super.initState();
  }

  Future loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
      // useGpuDelegate: true,
    );
  }

  @override
  void dispose() {
    Tflite.close();
    logScrollController.dispose();
    sessiongLogController.dispose();
    if (omniState.currentState != null) omniState.currentState!.dispose();
    super.dispose();
  }

  Future<dynamic> detector(OmniImage image) async {
    return !active.value
        ? Future.value(null)
        : await Tflite.detectObjectOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(), // required
            model: "SSDMobileNet",
            imageHeight: image.height,
            imageWidth: image.width,
            imageMean: 127.5, // defaults to 127.5
            imageStd: 127.5, // defaults to 127.5
            rotation: 90, // defaults to 90, Android only
            numResultsPerClass: 1, // defaults to 5
            threshold: 0.1, // defaults to 0.1
            asynch: true // defaults to true
            );
  }

  @override
  Widget build(BuildContext context) {
    var logScrollController;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _busy
          ? CircularProgressIndicator()
          : Container(
              child: Stack(
                children: [
                  OmniMlVision(
                    onResult: (dynamic result) {
                      final _detected = result != null ? result as List<dynamic> : [];
                      if (_detected.isNotEmpty) {
                        String log = "";
                        _detected.forEach(
                            (element) => log += "${element["detectedClass"]} : ${element["confidenceInClass"]}\n");
                        sessiongLogController.text = "$log\n";
                      }
                    },
                    detector: (OmniImage image) => detector(image),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              active.value = !active.value;
                            },
                            child: ValueListenableBuilder(
                                valueListenable: active,
                                builder: (_, bool _active, widget) {
                                  return Icon(_active ? Icons.camera_alt_rounded : Icons.stop_sharp);
                                }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        child: ValueListenableBuilder(
                            valueListenable: currentSessionLog,
                            builder: (context, _currentSessionLog, child) {
                              return TextField(
                                maxLength: TextField.noMaxLength,
                                style: TextStyle(color: Colors.white70),
                                maxLines: null,
                                readOnly: true,
                                expands: true,
                                scrollController: logScrollController,
                                controller: sessiongLogController,
                                textAlignVertical: TextAlignVertical.bottom,
                                decoration: InputDecoration(
                                    counter: null,
                                    counterText: "",
                                    border: OutlineInputBorder(
                                        //borderRadius: BorderRadius.circular(10.0),
                                        ),
                                    filled: true,
                                    hintStyle: TextStyle(color: Colors.grey[800]),
                                    //hintText: currentSessionId,
                                    fillColor: Colors.black),
                              );
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
