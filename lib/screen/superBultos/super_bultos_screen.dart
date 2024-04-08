// ignore_for_file: use_build_context_synchronously

import 'dart:core';
import 'package:despachos_app/screen/screens.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

import 'package:intl/intl.dart';

class SuperBultosScreen extends StatefulWidget {
  const SuperBultosScreen({Key? key}) : super(key: key);

  static String routeName = 'superBultos';

  @override
  State<SuperBultosScreen> createState() => _SuperBultosState();
}

class _SuperBultosState extends State<SuperBultosScreen> {
  late bool _isButtonDisabled;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
    initializeDateFormatting('es');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuperBultoProvider>(context);
    final listado = provider.listaSuperBultos;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const FlexibleSpace(),
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              Preferences.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () async {
                  await provider.obtenerListadoSuperBultoEncabezado(
                      context, Preferences.usuario);
                },
                child: const Icon(Icons.sync),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5, right: 5),
                        alignment: Alignment.topRight,
                        height: 20,
                        width: 150,
                        child: Text(
                          Preferences.usuario,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        height: 20,
                        width: 250,
                        child: const Text(
                          'Existentes',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.primaryColor, height: 1),
                  const SizedBox(
                    height: 10,
                  ),
                  provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive())
                      : listado.isEmpty
                          ? const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Center(
                                      child: Text('No hay datos disponibles'))
                                ])
                          : LisSuperBultos(listSuperBultos: listado),
                ],
              ),
            ),
          ]),
        ),
        floatingActionButton: MaterialButton(
          minWidth: 15,
          height: 55,
          onPressed: _isButtonDisabled
              ? null
              : () async {
                  setState(() {
                    _isButtonDisabled = true;
                  });

                  final providerSuperBulto =
                      Provider.of<SuperBultoProvider>(context, listen: false);

                  await providerSuperBulto.insertarSuperBultoEncabezado(
                      context,
                      Preferences.compania,
                      BESuperBultoEncabezado(
                          idSuperBulto: 0,
                          numeroSuperBulto: 0,
                          nombreUsuario: Preferences.usuario,
                          fechaHoraInicio: DateTime.now(),
                          fechaHoraFin: DateTime.now(),
                          nombreCliente: '',
                          nombreSucursal: '',
                          estado: 'A',
                          detalle: []));

                  await providerSuperBulto.obtenerSBEncabezadoNumero(
                      context,
                      int.parse(providerSuperBulto.consecutivo),
                      Preferences.usuario);

                  await providerSuperBulto.obtenerListaSuperBultoDetalle(
                      context,
                      providerSuperBulto.superBultoSeleccionado!.idSuperBulto!,
                      Preferences.usuario);
                  setState(() {
                    _isButtonDisabled = false;

                    Navigator.pushNamed(
                        context, MantenimientoSuperBultosScreen.routeName);

                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const MantenimientoSuperBultosScreen()),
                    );*/
                  });
                },
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          disabledColor: AppColors.primaryColor,
          elevation: 1,
          color: AppColors.primaryColor,
          child: _isButtonDisabled
              ? const FormCircularProgressIndicator()
              : const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class LisSuperBultos extends StatelessWidget {
  const LisSuperBultos({super.key, required this.listSuperBultos});

  final List<BESuperBultoEncabezado> listSuperBultos;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy hh:mm');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: listSuperBultos.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              child: ListTile(
                onTap: () async {
                  final provider =
                      Provider.of<SuperBultoProvider>(context, listen: false);
                  provider.superBultoSeleccionado = listSuperBultos[index];
                  await provider.obtenerListaSuperBultoDetalle(
                      context,
                      listSuperBultos[index].idSuperBulto!,
                      Preferences.usuario);

                  Navigator.pushNamed(
                      context, MantenimientoSuperBultosScreen.routeName);

                  /*Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const MantenimientoSuperBultosScreen()));*/
                },
                shape: RoundedRectangleBorder(
                  side:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Table(
                    columnWidths: const {
                      0: FractionColumnWidth(0.3),
                      1: FractionColumnWidth(0.7),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                              child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text('Super bulto:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          )),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  ' ${listSuperBultos[index].numeroSuperBulto}',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                              child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text('Fecha:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          )),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  ' ${formatoFecha.format(listSuperBultos[index].fechaHoraInicio!).toString()}',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                              child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text('Usuario:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          )),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  ' ${listSuperBultos[index].nombreUsuario}',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                              child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text('Cliente:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          )),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  ' ${listSuperBultos[index].nombreSucursal.toString().isEmpty ? listSuperBultos[index].nombreCliente : listSuperBultos[index].nombreSucursal}',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
