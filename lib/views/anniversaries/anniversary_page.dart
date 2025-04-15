import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';

class AnniversaryPage extends StatefulWidget {
  const AnniversaryPage({super.key});

  @override
  State<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends State<AnniversaryPage> {
  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "Anniversaries",
      body: Text("Anniversary Page"),
    );
  }
}
