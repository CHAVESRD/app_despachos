import 'package:flutter/material.dart';
import '../colors/colors.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        width: double.infinity,
        decoration: _createCardSharp(),
        child: child,
      ),
    );
  }

  BoxDecoration _createCardSharp() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
              color: AppColors.secundaryColor,
              blurRadius: 15,
              offset: Offset(0, 5))
        ]);
  }
}
