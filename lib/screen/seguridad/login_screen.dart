// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors/colors.dart';
import '../../constants/constants.dart';
import '../../helpers/helpers.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String routeName = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _btnIngresarHabilitado = true;
  //bool _estaIngresando = false;

  int codigo = 0;
  int compania = 0;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final catalogoProvider = Provider.of<CatalogoProvider>(context);
    final sucursalProvider = Provider.of<SucursalProvider>(context);

    codigo = catalogoProvider.codigoEmpresa;
    compania = sucursalProvider.codigoCompania;

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
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
            title: const Text(
              TextConstants.appName,
              textAlign: TextAlign.center,
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: loginForm.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                CardContainer(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Table(
                            columnWidths: const {
                              0: FractionColumnWidth(
                                  0.32), // asignar un ancho del 30% a la columna 0
                              1: FractionColumnWidth(
                                  0.68), // asignar un ancho del 70% a la columna 1
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                children: [
                                  const TableCell(
                                    child: ListTile(
                                      title: Text(
                                        TextConstants.division,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 15),
                                      width: 15.0,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: catalogoProvider
                                                .isLoadingDivisiones
                                            ? const Center(
                                                child:
                                                    FormCircularProgressIndicator())
                                            : DropdownButton(
                                                isExpanded: true,
                                                value: catalogoProvider
                                                    .codigoDivision,
                                                items: catalogoProvider
                                                    .divisiones
                                                    .map((e) {
                                                  return DropdownMenuItem(
                                                    value: e.codigo,
                                                    child: Text(
                                                        e.nombre.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 14)),
                                                  );
                                                }).toList(),
                                                onChanged: <int>(value) {
                                                  catalogoProvider
                                                      .codigoDivision = value;

                                                  catalogoProvider
                                                      .obtenerEmpresasPorDivision(
                                                          catalogoProvider
                                                              .codigoDivision);
                                                },

                                                icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    color:
                                                        AppColors.primaryColor),
                                                underline: Container(
                                                  height: 2,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                // Deshabilita el menú desplegable
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const TableCell(
                                    child: ListTile(
                                      title: Text(
                                        TextConstants.empresa,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 15),
                                      width: 15.0,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: catalogoProvider
                                                .isLoadingEmpresas
                                            ? const Center(
                                                child:
                                                    FormCircularProgressIndicator())
                                            : DropdownButton(
                                                isExpanded: true,
                                                value: catalogoProvider
                                                    .codigoEmpresa,
                                                items: catalogoProvider.empresas
                                                    .map((e) {
                                                  return DropdownMenuItem(
                                                    value: e.codigo,
                                                    child: Text(
                                                        e.nombre.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 14)),
                                                  );
                                                }).toList(),
                                                onChanged: <int>(value) {
                                                  catalogoProvider
                                                      .codigoEmpresa = value;

                                                  Preferences.conexion =
                                                      catalogoProvider
                                                          .codigoEmpresa;

                                                  codigo = catalogoProvider
                                                      .codigoEmpresa;
                                                },

                                                icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    color:
                                                        AppColors.primaryColor),
                                                underline: Container(
                                                  height: 2,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                // Deshabilita el menú desplegable
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                        Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          width: double.infinity,
                          child: Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: TextFormField(
                                        autocorrect: false,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                        onChanged: (value) =>
                                            loginForm.usuario = value,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: AppColors.primaryColor,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: AppColors.primaryColor,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: AppColors.primaryColor,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          fillColor: AppColors.primaryColor,
                                          labelText: 'Usuario',
                                          labelStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black54),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return TextConstants.requerido;
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        width: double.infinity,
                                        //Control Contraseña
                                        child: TextFormField(
                                          obscureText: true,
                                          autocorrect: false,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                          onChanged: (value) =>
                                              loginForm.clave = value,
                                          decoration: InputDecoration(
                                            hintText: "Contraseña",
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: AppColors.primaryColor,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: AppColors.primaryColor,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: AppColors.primaryColor,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            fillColor: AppColors.primaryColor,
                                            labelText: 'Clave',
                                            labelStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black54),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return TextConstants.requerido;
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                //Botón Ingresar
                                MaterialButton(
                                  onPressed: loginForm.isLoading ||
                                          !_btnIngresarHabilitado
                                      ? null
                                      : () async {
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            //_estaIngresando = true;
                                            _btnIngresarHabilitado = false;
                                          });
                                          if (!loginForm.isValidForm()) {
                                            setState(() {
                                              // _estaIngresando = false;
                                              _btnIngresarHabilitado = true;
                                            });
                                            return;
                                          }
                                          final loginResp = await loginForm
                                              .login(context, codigo);

                                          if (loginResp) {
                                            await sucursalProvider
                                                .consultaCompanias(context);

                                            if (sucursalProvider
                                                .companias.isNotEmpty) {
                                              compania = sucursalProvider
                                                  .codigoCompania;
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          'Selección de compañía',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        scrollable: true,
                                                        content: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 100,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Table(
                                                                    defaultVerticalAlignment:
                                                                        TableCellVerticalAlignment
                                                                            .middle,
                                                                    children: [
                                                                      TableRow(
                                                                        children: [
                                                                          TableCell(
                                                                            child:
                                                                                SizedBox(
                                                                              width: double.infinity,
                                                                              child: sucursalProvider.isLoadingCompanias
                                                                                  ? const Center(child: FormCircularProgressIndicator())
                                                                                  : DropdownButton(
                                                                                      isExpanded: true,
                                                                                      value: compania,
                                                                                      items: sucursalProvider.companias.map((e) {
                                                                                        return DropdownMenuItem(
                                                                                          value: e.codigo,
                                                                                          child: Text(e.nombre.toString(), style: const TextStyle(fontSize: 14)),
                                                                                        );
                                                                                      }).toList(),
                                                                                      onChanged: <int>(value) {
                                                                                        setState(() {
                                                                                          compania = value;
                                                                                        });

                                                                                        sucursalProvider.codigoCompania = value;

                                                                                        Preferences.compania = value;
                                                                                      },

                                                                                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                                                                                      underline: Container(
                                                                                        height: 2,
                                                                                        decoration: const BoxDecoration(
                                                                                          shape: BoxShape.rectangle,
                                                                                          color: AppColors.primaryColor,
                                                                                        ),
                                                                                      ),
                                                                                      // Deshabilita el menú desplegable
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ]),
                                                              ]),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              final menuProvider =
                                                                  Provider.of<
                                                                          MenuProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);

                                                              await menuProvider
                                                                  .obtenerMenuPermisosPrincipal(
                                                                      Preferences
                                                                          .compania,
                                                                      Preferences
                                                                          .usuario,
                                                                      0,
                                                                      0);

                                                              Navigator.of(context).pushAndRemoveUntil(
                                                                  MaterialPageRoute<
                                                                          void>(
                                                                      builder:
                                                                          (context) =>
                                                                              const HomeScreen()),
                                                                  (Route<dynamic>
                                                                          route) =>
                                                                      false);
                                                            },
                                                            child: const Text(
                                                                TextConstants
                                                                    .aceptar),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            ScreenHelper.showInfoDialog(
                                                context,
                                                TextConstants
                                                    .loginIncorrectoTitulo,
                                                TextConstants.loginIncorrecto,
                                                TextConstants.cerrar,
                                                Icons.info);
                                          }
                                          setState(() {
                                            //_estaIngresando = false;
                                            _btnIngresarHabilitado = true;
                                          });
                                        },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledColor: Colors.grey,
                                  elevation: 0,
                                  color: AppColors.primaryColor,
                                  child: Container(
                                      //height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 18),
                                      child: loginForm.isLoading
                                          ? const Text(TextConstants.espere,
                                              style: TextStyle(
                                                  color: Colors.white))
                                          : const Text(
                                              TextConstants.ingresar,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    exit(0);
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledColor: Colors.grey,
                                  elevation: 0,
                                  color: AppColors.primaryColor,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 18),
                                    child: const Text(
                                      TextConstants.cancelar,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                    '${TextConstants.appName} © ${DateTime.now().year} Versión ${_packageInfo.version}')
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
