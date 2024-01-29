import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth Printer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothDeviceListEntry(),
    );
  }
}

class BluetoothDeviceListEntry extends StatefulWidget {
  const BluetoothDeviceListEntry({Key? key}) : super(key: key);

  @override
  _BluetoothDeviceListEntryState createState() => _BluetoothDeviceListEntryState();
}

class _BluetoothDeviceListEntryState extends State<BluetoothDeviceListEntry> {
  List<ScanResult> devices = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
  print("Scan results: $results");
  setState(() {
    devices = results;
  });
});

    Future.delayed(const Duration(seconds: 4), () {
      FlutterBluePlus.stopScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Bluetooth Printers'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].device.platformName ?? 'Unknown device'),
            subtitle: Text(devices[index].device.remoteId.toString()),
            onTap: () async {
                if (devices[index].device.platformName == 'PT-210_EDDD') {
    await devices[index].device.connect();

BluetoothCharacteristic? characteristic = null;

// Discover all services
List<BluetoothService> services = await devices[index].device.discoverServices();

for (BluetoothService service in services) {
  if (characteristic != null) {
    break;
  }

  for (BluetoothCharacteristic c in service.characteristics) {
    if (c.properties.write) {
      characteristic = c;
      break;
    }
  }
}

if (characteristic != null) {

// int width = 384; // Example width, should match the printer's capabilities
//   int height = 300; // Example height
//   int mode = 0; // Normal mode
//   int chunkSize = 128;
//   // Uint8List bitmap = createMonochromeBitmap(width, height);
//   Uint8List imageBitmap = await createMonochromeBitmap('/storage/emulated/0/Download/test-01.jpeg', width, height);
//   // Uint8List encodedBitmap = encodeBitmapForEscPos(imageBitmap, width, height);
//   Uint8List encodedBitmap = encodeBitmapForEscPos1(imageBitmap, width, height, mode);
  int bottomMarginLines = 3;

// await writeDataInChunks(characteristic, encodedBitmap, chunkSize);

printReceipt(characteristic);
// Introduce a delay
      await Future.delayed(Duration(milliseconds: 500));
      await characteristic.write(feedLines(bottomMarginLines), withoutResponse: true);
} 
              }      
        });
        },
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}

Future<void> requestPermissions() async {
  await Permission.bluetooth.request();
  await Permission.bluetoothScan.request();
  await Permission.location.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothAdvertise.request();
}
// Future<Uint8List> convertImageToPrinterFormat(String imagePath) async {
//   // Load image file
//   File imgFile = File(imagePath);
//   Uint8List imgBytes = await imgFile.readAsBytes();
//   ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
//   ui.FrameInfo frameInfo = await codec.getNextFrame();

//   // Resize the image to fit the printer's width (assuming 384 pixels)
//   ui.Image resizedImage = await _resizeImage(frameInfo.image, 384);

//   // Convert the resized image to grayscale and then to a monochrome format
//   ByteData? byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
//   Uint8List monochromeBytes = _convertToMonochrome(byteData!, 384, resizedImage.height);

//   return monochromeBytes;
// }
// Future<ui.Image> _resizeImage(ui.Image image, int targetWidth) async {
//   double aspectRatio = image.width / image.height;
//   int targetHeight = (targetWidth / aspectRatio).round();

//   ui.PictureRecorder recorder = ui.PictureRecorder();
//   ui.Canvas canvas = ui.Canvas(recorder);
//   ui.Paint paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
//   canvas.drawImageRect(
//     image,
//     ui.Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
//     ui.Rect.fromLTRB(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
//     paint,
//   );

//   return await recorder.endRecording().toImage(targetWidth, targetHeight);
// }

// Uint8List _convertToMonochrome(ByteData data, int width, int height) {
//   int bytesPerRow = (width / 8).ceil();
//   List<int> bytes = List.filled(bytesPerRow * height, 0);

//   for (int y = 0; y < height; y++) {
//     for (int x = 0; x < width; x++) {
//       int offset = (y * width + x) * 4;
//       int pixelValue = data.getUint8(offset);  // Only need one channel for grayscale
//       int color = pixelValue < 128 ? 1 : 0;  // Threshold

//       int pos = y * bytesPerRow + (x ~/ 8);
//       bytes[pos] |= (color << (7 - (x % 8)));
//     }
//   }

//   return Uint8List.fromList(bytes);
// }

Uint8List encodeBitmapForEscPos(Uint8List bitmap, int width, int height) {
  List<int> commands = [];
  commands.addAll([0x1D, 0x76, 0x30, 0x00]); // GS v 0
  commands.addAll([width ~/ 8 % 256, width ~/ 8 ~/ 256, height % 256, height ~/ 256]); // Width, height

  commands.addAll(bitmap);
  return Uint8List.fromList(commands);
}


Future<void> writeDataInChunks(BluetoothCharacteristic characteristic, Uint8List data, int chunkSize) async {
  for (int i = 0; i < data.length; i += chunkSize) {
    int end = (i + chunkSize > data.length) ? data.length : i + chunkSize;
    await characteristic.write(data.sublist(i, end), withoutResponse: true);
  }
}

Uint8List feedLines(int lines) {
  return Uint8List.fromList([0x1B, 0x64, lines]); // ESC d n
}

Future<Uint8List> createMonochromeBitmap(String imagePath, int width, int height) async {
  // Load the image
  File file = File(imagePath);
  Uint8List fileBytes = await file.readAsBytes();
  img.Image? originalImage = img.decodeImage(fileBytes);
  if (originalImage == null) {
    throw Exception('Unable to decode the image');
  }

  // Resize and convert to grayscale
  img.Image resizedImage = img.copyResize(originalImage, width: width, height: height);
  img.Image grayscaleImage = img.grayscale(resizedImage);

  // Convert to monochrome bitmap
  List<int> monochromeBytes = [];
  for (int y = 0; y < grayscaleImage.height; y++) {
    int byte = 0;
    for (int x = 0; x < grayscaleImage.width; x++) {
      if (x % 8 == 0 && x != 0) {
        monochromeBytes.add(byte);
        byte = 0;
      }
      img.Pixel pixel = grayscaleImage.getPixel(x, y);
      int luma = _calculateLuminance(pixel);
      if (luma < 128) { // Threshold, can be adjusted
        byte |= (1 << (7 - x % 8));
      }
    }
    monochromeBytes.add(byte); // Add remaining byte for the row
  }

  return Uint8List.fromList(monochromeBytes);
}

int _calculateLuminance(img.Pixel pixel) {
  int r = pixel.r.toInt();
  int g = pixel.g.toInt();
  int b = pixel.b.toInt();
  return (r * 0.299 + g * 0.587 + b * 0.114).round();
}

Uint8List encodeBitmapForEscPos1(Uint8List bitmap, int width, int height, int mode) {
  int bytesPerLine = (width + 7) ~/ 8;
  List<int> commands = [
    0x1D, 0x76, 0x30, mode, // GS v 0 m
    bytesPerLine % 256, bytesPerLine ~/ 256, // xL, xH
    height % 256, height ~/ 256, // yL, yH
  ];

  commands.addAll(bitmap);
  return Uint8List.fromList(commands);
}


void printReceipt(BluetoothCharacteristic characteristic) async {
  // Initialize printer
  // await printer.connect();
  // var service = ... // Discover services to find the right characteristic
  // var characteristic = ... // The characteristic to write to

  // Print header (centered, bold, larger text)
  await printText(characteristic, "\x1b\x61\x01"); // Center alignment
  await printText(characteristic, "\x1b\x21\x30"); // Double height, double width, bold
  await printText(characteristic, "Care First PHARMACY\n");

  // Print address (centered, normal text)
  await printText(characteristic, "\x1b\x21\x00"); // Normal text
  await printText(characteristic, "No. 150, NAHTI HANDIYA ROAD, DANKOTUWA\n");
  await printText(characteristic, "Tel: 077 - 9906194 / 077 0729023\n");

  // Print date, user, invoice number (left aligned)
  await printText(characteristic, "\x1b\x61\x00"); // Left alignment
  await printText(characteristic, "Date: 9/11/2023 17:30:48PM\n");
  await printText(characteristic, "User: user    Invoice No: 001\n");
  await printText(characteristic, "--------------------------------\n");

  // Print table headers (left aligned, bold)
  await printText(characteristic, "\x1b\x21\x08"); // Bold text
  await printText(characteristic, "Code  Qty  Unit Price  Disc  Amount\n");

  // Print items (normal text)
  await printText(characteristic, "\x1b\x21\x00"); // Normal text
  await printText(characteristic, "ACE 125MG (PARACETAMOL SUPPO)\n");
  await printText(characteristic, "12793  2  X  102.16  0.00  204.32\n");
  // Repeat for other items...

  // Print totals (bold text)
  await printText(characteristic, "\x1b\x21\x08"); // Bold text
  await printText(characteristic, "Gross Amount:     506.42\n");
  await printText(characteristic, "Discount:          25.32\n");
  await printText(characteristic, "Net Amount:      481.10\n");
  await printText(characteristic, "Cash Amount:    500.00\n");
  await printText(characteristic, "Balance:            18.90\n");

  // Print footer (centered, italic text)
  await printText(characteristic, "\x1b\x61\x01"); // Center alignment
  await printText(characteristic, "\x1b\x21\x04"); // Italic text
  await printText(characteristic, "\"Your Health Is Our First Priority...!\"\n");

  // Cut the paper
  await printText(characteristic, "\x1d\x56\x41\x03"); // Full cut

  // Close the connection
  // await printer.disconnect();
}

Future<void> printText(BluetoothCharacteristic characteristic, String text) async {
  // Convert the text to a Uint8List using the proper encoding
  Uint8List bytes = Uint8List.fromList(utf8.encode(text));
  // Write the text to the printer in chunks
  await writeDataInChunks(characteristic, bytes,128);
}