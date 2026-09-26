import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@JS('triggerPWAInstall')
external JSBoolean? _triggerPWAInstall();

@JS('isAppInstalled')
external JSBoolean? _isAppInstalled();

class PwaInstallService {
  static final ValueNotifier<bool> isInstalledNotifier =
      ValueNotifier<bool>(_checkInitialInstalled());

  static bool _checkInitialInstalled() {
    if (kIsWeb) {
      try {
        return _isAppInstalled()?.toDart ?? false;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  static void refreshStatus() {
    isInstalledNotifier.value = _checkInitialInstalled();
  }

  static void promptInstall(BuildContext context) {
    if (kIsWeb) {
      try {
        final result = _triggerPWAInstall()?.toDart;
        if (result == true) {
          isInstalledNotifier.value = true;
        } else {
          showInstallInstructions(context);
        }
      } catch (_) {
        showInstallInstructions(context);
      }
    } else {
      showInstallInstructions(context);
    }
  }

  static void showInstallInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF0F2B48),
        title: const Row(
          children: [
            Icon(Icons.install_mobile_rounded, color: Color(0xFFE5A93C), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Installer l\'application',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajoutez GREAT MINDS GROUP directement sur votre écran d\'accueil pour y accéder en 1 clic comme une vraie application :',
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              _buildGuideStep(
                icon: Icons.android_rounded,
                title: 'Sur Android / Google Chrome :',
                desc: 'Appuyez sur les 3 points verticaux en haut à droite (⋮) puis sur « Installer l\'application » ou « Ajouter à l\'écran d\'accueil ».',
              ),
              const SizedBox(height: 12),
              _buildGuideStep(
                icon: Icons.apple_rounded,
                title: 'Sur iPhone / Safari :',
                desc: 'Appuyez sur l\'icône Partager en bas (carré avec flèche ⬆️) puis faites défiler et touchez « Sur l\'écran d\'accueil » 📲.',
              ),
              const SizedBox(height: 12),
              _buildGuideStep(
                icon: Icons.computer_rounded,
                title: 'Sur Ordinateur (Chrome / Edge) :',
                desc: 'Cliquez sur la petite icône d\'installation 💻 dans la barre d\'adresse tout à droite.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5A93C),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Compris !', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Widget _buildGuideStep({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE5A93C), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
