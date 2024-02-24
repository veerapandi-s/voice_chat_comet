// ignore_for_file: use_build_context_synchronously

import 'package:comet/voice_chat.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Chat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Comet Sample'),
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
  TextEditingController uidController = TextEditingController();
  TextEditingController sesionIdController = TextEditingController();
  bool isPresenter = false;
  bool isUIkit = false;

  void activateChat() async {
    if (uidController.text.isEmpty) {
      const snackBar = SnackBar(
        content: Text('UID is Empty'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }

    if (sesionIdController.text.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Session Id is Empty'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }
    String uid = uidController.text;

    var status = await Permission.microphone.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      const snackBar = SnackBar(
        content: Text('Micro Phone permission is needed is Empty'),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoicChat(
          uid: uid,
          sessionId: sesionIdController.text,
          isPresenter: isPresenter,
          isUIkit: isUIkit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: uidController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'User ID',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter User ID';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: sesionIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Room ID',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Row(
                    children: [
                      const Text("UI KIT"),
                      Checkbox(
                          value: isUIkit,
                          onChanged: (bool? value) {
                            setState(() {
                              isUIkit = value!;
                            });
                          })
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Row(
                    children: [
                      const Text("Presenter"),
                      Checkbox(
                          value: isPresenter,
                          onChanged: (bool? value) {
                            setState(() {
                              isPresenter = value!;
                            });
                          })
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      activateChat();
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
