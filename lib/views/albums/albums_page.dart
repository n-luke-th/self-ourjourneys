/// lib/views/albums/albums_page.dart
///
///
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/components/cloud_image.dart';
import 'package:ourjourneys/components/cloud_file_uploader.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  String objectKey = "bmc_qr.png";
  final AuthService _auth = getIt<AuthService>();
  final Logger _logger = getIt<Logger>();

  @override
  initState() {
    super.initState();
    getIdToken();
  }

  void getIdToken() async {
    try {
      final user = _auth.authInstance!.currentUser;
      final idToken = await user!.getIdToken();
      _logger.d("idToken: $idToken");
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Albums".toUpperCase(),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            runAlignment: WrapAlignment.center,
            children: [
              CloudImage(
                objectKey: objectKey,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                shimmerBaseOpacity: 0.3,
                errorWidget: Icon(Icons.error_outline),
              ),
              CloudFileUploader(
                folderPath: "test",
                onUploaded: (results) {
                  _logger.d("on uploaded results: $results");
                },
              )
            ],
          ),
        )));
  }
}
