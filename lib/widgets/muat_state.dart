import 'package:flutter/material.dart';

import '../state/logbook_controller.dart';

/// Membungkus loading state dan error state supaya tidak ditulis ulang di tiap menu.
class MuatState extends StatelessWidget {
  final LogbookController controller;
  final WidgetBuilder builder;

  const MuatState({super.key, required this.controller, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.loading && controller.data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error != null && controller.data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gagal memuat data:\n${controller.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.muat,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.error != null) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.errorContainer,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Gagal memperbarui: ${controller.error}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(child: builder(context)),
            ],
          );
        }
        return builder(context);
      },
    );
  }
}
