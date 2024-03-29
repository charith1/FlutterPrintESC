// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

//   bool _connected = false;
//   BluetoothDevice? _device;
//   String tips = 'no device connect';

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initBluetooth() async {
//     bluetoothPrint.startScan(timeout: Duration(seconds: 4));

//     bool isConnected=await bluetoothPrint.isConnected??false;

//     bluetoothPrint.state.listen((state) {
//       print('******************* cur device status: $state');

//       switch (state) {
//         case BluetoothPrint.CONNECTED:
//           setState(() {
//             _connected = true;
//             tips = 'connect success';
//           });
//           break;
//         case BluetoothPrint.DISCONNECTED:
//           setState(() {
//             _connected = false;
//             tips = 'disconnect success';
//           });
//           break;
//         default:
//           break;
//       }
//     });

//     if (!mounted) return;

//     if(isConnected) {
//       setState(() {
//         _connected=true;
//       });
//     }
//   }

//     Future<bool> isAssetImageValid(String assetPath) async {
//     try {
//       final ByteData data = await rootBundle.load(assetPath);
//       if (data.lengthInBytes <= 0) {
//         return false;
//       }
//       return true;
//     } catch (e) {
//       // If there's an error (e.g., file not found), return false
//       return false;
//     }
//   }

// Future<String> assetImageToBase64(String assetPath) async {
//   // Load the image asset as byte data
//   requestPermissions();
//   ByteData data = await rootBundle.load(assetPath);
//   Uint8List bytes = data.buffer.asUint8List();

//   // Encode the byte array to a Base64 string
//   String base64String = base64Encode(bytes);
//   // save to a new file in the temp directory
//   File file = await writeToFile(bytes, 'test.png');
//   return base64String;
// }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('BluetoothPrint example app'),
//           ),
//           body: RefreshIndicator(
//             onRefresh: () =>
//                 bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                         child: Text(tips),
//                       ),
//                     ],
//                   ),
//                   Divider(),
//                   StreamBuilder<List<BluetoothDevice>>(
//                     stream: bluetoothPrint.scanResults,
//                     initialData: [],
//                     builder: (c, snapshot) => Column(
//                       children: snapshot.data!.map((d) => ListTile(
//                         title: Text(d.name??''),
//                         subtitle: Text(d.address??''),
//                         onTap: () async {
//                           setState(() {
//                             _device = d;
//                           });
//                         },
//                         trailing: _device!=null && _device!.address == d.address?Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ):null,
//                       )).toList(),
//                     ),
//                   ),
//                   Divider(),
//                   Container(
//                     padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
//                     child: Column(
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             OutlinedButton(
//                               child: Text('connect'),
//                               onPressed:  _connected?null:() async {
//                                 if(_device!=null && _device!.address !=null){
//                                   setState(() {
//                                     tips = 'connecting...';
//                                   });
//                                   await bluetoothPrint.connect(_device!);
//                                 }else{
//                                   setState(() {
//                                     tips = 'please select device';
//                                   });
//                                   print('please select device');
//                                 }
//                               },
//                             ),
//                             SizedBox(width: 10.0),
//                             OutlinedButton(
//                               child: Text('disconnect'),
//                               onPressed:  _connected?() async {
//                                 setState(() {
//                                   tips = 'disconnecting...';
//                                 });
//                                 await bluetoothPrint.disconnect();
//                               }:null,
//                             ),
//                           ],
//                         ),
//                         Divider(),
//                         OutlinedButton(
//                           child: Text('print receipt(esc)'),
//                           onPressed:  _connected?() async {
//                             Map<String, dynamic> config = Map();

//                             List<LineText> list = [];

//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '打印单据头', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
//                             list.add(LineText(linefeed: 1));

//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '----------------------明细---------------------', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '物资名称规格型号', weight: 1, align: LineText.ALIGN_LEFT, x: 0,relativeX: 0, linefeed: 0));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '单位', weight: 1, align: LineText.ALIGN_LEFT, x: 350, relativeX: 0, linefeed: 0));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '数量', weight: 1, align: LineText.ALIGN_LEFT, x: 500, relativeX: 0, linefeed: 1));

//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '混凝土C30', align: LineText.ALIGN_LEFT, x: 0,relativeX: 0, linefeed: 0));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '吨', align: LineText.ALIGN_LEFT, x: 350, relativeX: 0, linefeed: 0));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '12.0', align: LineText.ALIGN_LEFT, x: 500, relativeX: 0, linefeed: 1));

//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
//                             list.add(LineText(linefeed: 1));

//                             if (await isAssetImageValid("assets/images/bluetooth_print.png")) {
//                               ByteData data = await rootBundle.load("assets/images/bluetooth_print.png");
//                               List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//                               String base64Image = base64Encode(imageBytes);
//                               list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));
//                             } else {
//                               return;
//                             }


//                             // ByteData data = await rootBundle.load("assets/images/bluetooth_print.png");
//                             // List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//                             // String base64Image = base64Encode(imageBytes);
//                             // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

//                             await bluetoothPrint.printReceipt(config, list);
//                           }:null,
//                         ),
//                         OutlinedButton(
//                           child: Text('print label(tsc)'),
//                           onPressed:  _connected?() async {
//                             Map<String, dynamic> config = Map();
//                             config['width'] = 40; // 标签宽度，单位mm
//                             config['height'] = 70; // 标签高度，单位mm
//                             config['gap'] = 2; // 标签间隔，单位mm

//                             // x、y坐标位置，单位dpi，1mm=8dpi
//                             List<LineText> list = [];
//                             list.add(LineText(type: LineText.TYPE_TEXT, x:10, y:10, content: 'A Title'));
//                             list.add(LineText(type: LineText.TYPE_TEXT, x:10, y:40, content: 'this is content'));
//                             list.add(LineText(type: LineText.TYPE_QRCODE, x:10, y:70, content: 'qrcode i\n'));
//                             list.add(LineText(type: LineText.TYPE_BARCODE, x:10, y:190, content: 'qrcode i\n'));

//                             // List<LineText> list1 = [];
//                             // if (await isAssetImageValid("assets/images/guide3.png")) {
//                             //   ByteData data = await rootBundle.load("assets/images/guide3.png");
//                             //   List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//                             //   String base64Image = base64Encode(imageBytes);
//                             //   list.add(LineText(type: LineText.TYPE_IMAGE, x:10, y:10, content: base64Image,));
//                             // } else {
//                             //   return;
//                             // }
//                             // ByteData data = await rootBundle.load("assets/images/guide3.png");
//                             // List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//                             // String base64Image = base64Encode(imageBytes);
//                             // list1.add(LineText(type: LineText.TYPE_IMAGE, x:10, y:10, content: base64Image,));

//                             // assetImageToBase64("assets/images/guide3.png").then((value) {
//                             //   list.add(LineText(type: LineText.TYPE_IMAGE, x:10, y:10, content: value,));
//                             // });

//                             // await bluetoothPrint.printLabel(config, list);

//                             print("Starting image conversion...");
// assetImageToBase64("assets/images/guide3.png").then((value) {
//   print("Image conversion complete. Adding to list...");
//   list.add(LineText(type: LineText.TYPE_IMAGE, x:10, y:10, content: value,));
//   print("Image added to list. Starting print...");
// }).then((_) {
//   return bluetoothPrint.printLabel(config, list);
// }).then((_) {
//   print("Print complete.");
// }).catchError((error) {
//   print("An error occurred: $error");
// });
//                             // await bluetoothPrint.printLabel(config, list1);
//                           }:null,
//                         ),
//                         OutlinedButton(
//                           child: Text('print selftest'),
//                           onPressed:  _connected?() async {
//                             await bluetoothPrint.printTest();
//                           }:null,
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         floatingActionButton: StreamBuilder<bool>(
//           stream: bluetoothPrint.isScanning,
//           initialData: false,
//           builder: (c, snapshot) {
//             if (snapshot.data == true) {
//               return FloatingActionButton(
//                 child: Icon(Icons.stop),
//                 onPressed: () => bluetoothPrint.stopScan(),
//                 backgroundColor: Colors.red,
//               );
//             } else {
//               return FloatingActionButton(
//                   child: Icon(Icons.search),
//                   onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
//             }
//           },
//         ),
//       ),
//     );
//   }
  
//   writeToFile(Uint8List bytes, String s) {
//     // get the path to the document directory.
//     String path = '/storage/emulated/0/Download/$s';
//     print(path);
//     // write the file
//     return File(path).writeAsBytes(bytes);
//   }
// }

// Future<void> requestPermissions() async {
//   await Permission.storage.request();
// }