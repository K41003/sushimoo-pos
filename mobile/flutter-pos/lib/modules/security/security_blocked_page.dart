import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Halaman terminal — tidak ada tombol "lanjutkan", tidak ada navigasi
/// balik. Ditampilkan saat DeviceIntegrityService mendeteksi
/// root/jailbreak/emulator di production dan `hardBlock == true`.
class SecurityBlockedPage extends StatelessWidget {
  const SecurityBlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = Get.arguments as String? ??
        'Perangkat ini tidak memenuhi standar keamanan untuk menjalankan '
            'aplikasi.';

    return PopScope(
      canPop: false, // cegah back-button menutup halaman blocking ini
      child: Scaffold(
        backgroundColor: const Color(0xFF10182B),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.white70, size: 56),
                  const SizedBox(height: 24),
                  const Text(
                    'Akses Ditolak',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
