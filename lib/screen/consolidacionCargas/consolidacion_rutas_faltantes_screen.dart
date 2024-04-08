// ignore_for_file: use_build_context_synchronously

import 'package:despachos_app/models/models.dart';
import 'package:despachos_app/providers/providers.dart';
import 'package:despachos_app/screen/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors/colors.dart';
import '../../constants/consolidacionCargas/text_constants_consolidacion_cargas.dart';

import '../../widgets/widgets.dart';

class ConsolidacionRutasFaltantesScreen extends StatefulWidget {
  const ConsolidacionRutasFaltantesScreen({Key? key}) : super(key: key);

  static String routeName = 'consolidacionRutasFaltantes';

  @override
  State<ConsolidacionRutasFaltantesScreen> createState() =>
      _ConsolidacionRutasFaltantesScreenState();
}

class _ConsolidacionRutasFaltantesScreenState
    extends State<ConsolidacionRutasFaltantesScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConsolidacionCargasProvider>(context);
    final listado = provider.faltantes;

    return WillPopScope(
      onWillPop: () async {
        /*Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ConsolidacionCargasDetalleBultosScreen()),
        );*/
        Navigator.of(context).pop();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const FlexibleSpace(),
            title: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                TextConstantsConsolidacionCargas.title3,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
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
                            : LisConsolidacionDetalle(
                                listFaltantes: listado, prov: provider),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 80.0,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                child:
                    ButtonBar(alignment: MainAxisAlignment.center, children: [
                  MaterialButton(
                    minWidth: 60.0,
                    height: 50.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: AppColors.primaryColor,
                    child: const Text(
                      TextConstantsConsolidacionCargas.regresar,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class LisConsolidacionDetalle extends StatelessWidget {
  const LisConsolidacionDetalle(
      {super.key, required this.listFaltantes, required this.prov});

  final List<BEFaltantes> listFaltantes;
  final ConsolidacionCargasProvider prov;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Scrollbar(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: listFaltantes.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () async {
                  String lista = listFaltantes[index]
                      .bultos
                      .toString()
                      .replaceAll('[', '');
                  String valor = lista.replaceAll("]", "");
                  await prov.obtenerDetalleFacturasBultosFaltantes(
                      context, valor.replaceAll(" ", ""));

                  Navigator.pushNamed(
                      context, ConsolidacionDetalleFaltantesScreen.routeName);

                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ConsolidacionDetalleFaltantesScreen()),
                  );*/
                },
                title: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Factura: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(listFaltantes[index].facturas.toString(),
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Bultos: ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    for (String bulto in listFaltantes[index].bultos)
                      Text(bulto,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
