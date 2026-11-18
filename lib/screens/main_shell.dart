import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/blockchain_service.dart';
import '../state/logbook_controller.dart';
import 'home_screen.dart';
import 'riwayat_screen.dart';
import 'setting_screen.dart';

class MainShell extends StatefulWidget {
  final BlockchainService service;
  final LogbookController controller;

  const MainShell({super.key, required this.service, required this.controller});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  DateTime? _terakhirBack;

  void _tanganiBack() {
    // Dari tab lain, Back kembali ke Beranda dulu.
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }
    final sekarang = DateTime.now();
    if (_terakhirBack != null &&
        sekarang.difference(_terakhirBack!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _terakhirBack = sekarang;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Tekan sekali lagi untuk keluar'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _tanganiBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              controller: widget.controller,
              service: widget.service,
              onBukaSetting: () => setState(() => _index = 2),
            ),
            RiwayatScreen(controller: widget.controller),
            SettingScreen(service: widget.service),
          ],
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final n = widget.controller.data
                .where((p) => p.masihDipinjam)
                .length;
            return NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: n > 0,
                    label: Text('$n'),
                    child: const Icon(Icons.home_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: n > 0,
                    label: Text('$n'),
                    child: const Icon(Icons.home),
                  ),
                  label: 'Beranda',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Setting',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
