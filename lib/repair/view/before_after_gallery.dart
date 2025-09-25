

import 'dart:math';

import 'package:flutter/cupertino.dart';

class BeforeAfterGallery extends StatelessWidget {
  final List<String> beforeImages;
  final List<String> afterImages;

  const BeforeAfterGallery({super.key, required this.beforeImages, required this.afterImages});

  @override
  Widget build(BuildContext context) {
    final count = max(beforeImages.length, afterImages.length);
    return Column(
      children: List.generate(count, (index) {
        final before = index < beforeImages.length ? beforeImages[index] : null;
        final after = index < afterImages.length ? afterImages[index] : null;
        return Row(
          children: [
            Expanded(child: before != null ? Image.network(before) : const Placeholder()),
            const SizedBox(width: 8),
            Expanded(child: after != null ? Image.network(after) : const Placeholder()),
          ],
        );
      }),
    );
  }
}
