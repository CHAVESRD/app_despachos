import 'package:flutter/material.dart';

import '../colors/colors.dart';

class FormCircularProgressIndicator extends StatelessWidget {
  const FormCircularProgressIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 25,
      height: 25,
      child: CircularProgressIndicator.adaptive(
          backgroundColor: AppColors.primaryColor,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
    );
  }
}
