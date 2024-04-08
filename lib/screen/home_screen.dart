// ignore: unused_import
// ignore_for_file: use_build_context_synchronously

import 'dart:core';
import 'dart:io';
import 'package:despachos_app/screen/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors/colors.dart';
import '../constants/text_constants.dart';
import '../helpers/helpers.dart';
import '../providers/providers.dart';
import '../shared/preferences.dart';
import '../widgets/flexible_space.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String routeName = 'home';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);

    if (provider.resultado.isNotEmpty) {
      ScreenHelper.showInfoDialog(
          context,
          'Sesión expirada',
          '¡Por favor inicie sesión nuevamente!',
          TextConstants.ok,
          Icons.error_outline);
      Preferences.usuario = '';
      Preferences.compania = 0;
      Preferences.nombre = '';
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false);
    }

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('¿Salir de la aplicación?'),
              content: const Text(
                  '¿Estás seguro de que deseas salir de la aplicación?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(
                        false); // Permite que la acción se ejecute normalmente
                  },
                ),
                TextButton(
                  child: const Text('Salir'),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            );
          },
        );

        // En este ejemplo, siempre bloqueamos la acción del botón "Atrás" hasta que el usuario confirme
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const FlexibleSpace(),
            title: const Text(TextConstants.titulo1),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () async {
                    await provider.obtenerMenuPermisosPrincipal(
                        Preferences.compania, Preferences.usuario, 0, 0);
                  },
                  child: const Icon(Icons.sync),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () async {
                    Preferences.usuario = '';
                    Preferences.compania = 0;
                    Preferences.nombre = '';
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: const Icon(Icons.logout_outlined, color: Colors.white),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
              child: provider.isLoadingPrincipal
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Center(child: CircularProgressIndicator.adaptive()),
                        ])
                  : provider.principal.isEmpty
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Center(child: Text('No hay datos disponibles'))
                            ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: provider.principal.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    child: MaterialButton(
                                      minWidth: 300.0,
                                      height: 100.0,
                                      onPressed: () async {
                                        if (provider.principal[index].nombre ==
                                            'Despachos') {
                                          final menuProvider =
                                              Provider.of<MenuProvider>(context,
                                                  listen: false);

                                          await menuProvider
                                              .obtenerMenuPermisosSecundario(
                                                  context,
                                                  Preferences.compania,
                                                  Preferences.usuario,
                                                  1,
                                                  provider
                                                      .principal[index].codigo);

                                          Navigator.pushNamed(context,
                                              MenuPermisosScreen.routeName);
                                          /*Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MenuPermisosScreen()),
                                          );*/
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: AppColors.primaryColor,
                                      child: Text(
                                        provider.principal[index].nombre,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ]),
            ),
          ),
        ),
      ),
    );
  }
}
