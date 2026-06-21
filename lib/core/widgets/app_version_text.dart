import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionText extends StatefulWidget {
  const AppVersionText({Key? key}) : super(key: key);

  @override
  State<AppVersionText> createState() => _AppVersionTextState();
}

class _AppVersionTextState extends State<AppVersionText> {
  String _versionString = "Cargando versión...";

  @override
  void initState() {
    super.initState();
    _initVersionInfo();
  }

  Future<void> _initVersionInfo() async {
    try {
      // Aquí el paquete lee los metadatos reales del dispositivo
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        // Ejemplo de lo que mostrará: Versión 1.0.0 (1)
        _versionString =
            "Versión ${packageInfo.version} (${packageInfo.buildNumber})";
      });
    } catch (e) {
      setState(() {
        _versionString = "Versión indiferenciada";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _versionString,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
