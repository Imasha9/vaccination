import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class CallInFlutter extends StatefulWidget {
  const CallInFlutter({super.key});

  @override
  State<CallInFlutter> createState() => _CallInFlutterState();
}

class _CallInFlutterState extends State<CallInFlutter> {
  Uri dialnumber = Uri(scheme: 'tel', path: '1234567890');

  callnumber() async {
    await launchUrl(dialnumber);
  }

  directcall() async {
    await FlutterPhoneDirectCaller.callNumber('1234567890');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("call in flutter"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () async {
                await FlutterPhoneDirectCaller.callNumber('1234567890');
              },
              label: Text("Call"),
              icon: Icon(Icons.phone),
            ),
          ],
        ),
      ),
    );
  }
}
