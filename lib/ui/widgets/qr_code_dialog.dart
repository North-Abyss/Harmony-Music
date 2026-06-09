import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';

void showQrCodeDialog(BuildContext context, String url, String title) {
  Get.dialog(
    AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: SizedBox(
        width: 250,
        height: 250,
        child: Center(
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('close'.tr),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
