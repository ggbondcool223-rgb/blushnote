import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'blush_note_update_logic.dart';

class BlushNoteUpdateView extends GetView<BlushNoteUpdateLogic> {
  const BlushNoteUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.lvizxe.value
              ? const CircularProgressIndicator(color: Colors.blueAccent)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.dwuzj();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
