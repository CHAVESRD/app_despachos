import 'package:despachos_app/constants/constants.dart';
import 'package:despachos_app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors/colors.dart';
import '../../widgets/widgets.dart';

class ConsolidacionDetalleFaltantesScreen extends StatelessWidget {
  const ConsolidacionDetalleFaltantesScreen({Key? key}) : super(key: key);

  static String routeName = 'consolidacionDetalleFaltantes';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConsolidacionCargasProvider>(context);
    final listado = provider.detalleFaltantes;

    return WillPopScope(
      onWillPop: () async {
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
                TextConstantsConsolidacionCargas.title4,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listado.length,
                    itemBuilder: (context, index) {
                      return Card(
                          elevation: 0,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: AppColors.primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Bulto: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text(listado[index].bulto.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Table(
                                      columnWidths: const {
                                        0: FractionColumnWidth(0.3),
                                        1: FractionColumnWidth(0.7),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.top,
                                      children: [
                                        TableRow(
                                          children: [
                                            TableCell(
                                                child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: const Text('Descripción: ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                            TableCell(
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                    listado[index]
                                                        .descripcion
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                      
                                  Row(children: [
                                    const Text('Cantidad: ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(listado[index].cantidad.toString(),
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                     const Text('OB:', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                     Text(listado[index].ordenBlock) 
                                  ]),
                                ]),
                          ));
                    }),
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
