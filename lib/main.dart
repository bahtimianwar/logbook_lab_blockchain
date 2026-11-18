import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/main_shell.dart';
import 'services/blockchain_service.dart';
import 'state/logbook_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final service = BlockchainService();
  await service.init();
  await service.pulihAkun(); // hanya berhasil kalau pernah memilih "ingat"

  final controller = LogbookController(service);
  controller.muat();

  runApp(LogbookApp(service: service, controller: controller));
}

class LogbookApp extends StatelessWidget {
  final BlockchainService service;
  final LogbookController controller;

  const LogbookApp({
    super.key,
    required this.service,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      home: MainShell(service: service, controller: controller),
    );
  }
}
