// Agenda Widget

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'db/linkModal.dart';
import 'entity/link.dart';

class SettingWidget extends StatefulWidget {
  // constructor
  const SettingWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingWidget createState() => _SettingWidget();
}

class _SettingWidget extends State<SettingWidget> {
  TextEditingController urlController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: Colors.red, title: const Text("Paramètres")),
      body: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Importer un calendrier",
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'URL de votre calendrier',
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.red),
              onPressed: updateDatabase,
              child:
                  const Text('Envoyer', style: TextStyle(color: Colors.white)),
            ),
          ])),
    );
  }

  void updateDatabase() async {
    if (urlController.text.isNotEmpty) {
      var link = Link(link: urlController.text);
      print('link : ${urlController.text}');

      await linkModal().insertLink(link);
    }
  }
}
