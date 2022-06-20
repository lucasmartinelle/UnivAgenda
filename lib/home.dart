// Agenda Widget

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends StatelessWidget {
  // constructor
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar:
            AppBar(backgroundColor: Colors.red, title: const Text("Accueil")),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30.0),
                Image.asset("assets/iut-logo.png"),
                const SizedBox(height: 30.0),
                Text(
                    "Créer par Lucas Martinelle, étudiant à l'IUT De Laval (2022)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10.0),
                Text("Version: 1.0.1",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(fontSize: 16))),
              ],
            )));
  }
}
