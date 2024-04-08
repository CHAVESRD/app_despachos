import 'package:flutter/material.dart';

import '../colors/colors.dart';

class FlexibleSpace extends StatelessWidget {
  const FlexibleSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
      ),
    );
  }
}
