import 'dart:core';
import 'package:despachos_app/constants/text_constants.dart';
import 'package:despachos_app/screen/screens.dart';
import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class MenuPermisosScreen extends StatefulWidget {
  const MenuPermisosScreen({Key? key}) : super(key: key);

  static String routeName = 'menuPermisos';

  @override
  State<MenuPermisosScreen> createState() => _MenuPermisosState();
}

class _MenuPermisosState extends State<MenuPermisosScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
    final listado = provider.secundario;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
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
                TextConstants.appName,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, verticalDirection: VerticalDirection.down, children: <Widget>[
                provider.isLoadingSecundario
                    ? const Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Center(child: CircularProgressIndicator.adaptive()),
                      ])
                    : listado.isEmpty
                        ? const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Center(child: Text('No hay datos disponibles'))])
                        : ListaMenu(lista: listado),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ListaMenu extends StatelessWidget {
  const ListaMenu({super.key, required this.lista});

  final List<BEMenu> lista;
  static const String superBultos = 'Armar Super Bultos', cargas = 'Consolidar Cargas', reapeturas = 'Reapeturas', despachos = 'Despachar Guías';
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: lista.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: MaterialButton(
                minWidth: 300.0,
                height: 100.0,
                onPressed: () {
                  if (lista[index].nombre == superBultos) {
                    Provider.of<SuperBultoProvider>(context, listen: false).obtenerListadoSuperBultoEncabezado(context, Preferences.usuario);

                    Navigator.pushNamed(context, SuperBultosScreen.routeName);

                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SuperBultosScreen()),
                    );*/

                    Preferences.nombre = lista[index].nombre;
                  } else if (lista[index].nombre == cargas) {
                    Provider.of<ConsolidacionCargasProvider>(context, listen: false).obtenerCargaEncabezado(Preferences.usuario, context);

                    Navigator.pushNamed(context, ConsolidacionCargasScreen.routeName);

                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ConsolidacionCargasScreen()),
                    );*/

                    Preferences.nombre = lista[index].nombre;
                  } else if (lista[index].nombre == reapeturas) {
                    Provider.of<ReaperturaProvider>(context, listen: false).cargarProcesos();

                    Navigator.pushNamed(context, ReaperturaScreen.routeName);

                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReaperturaScreen()),
                    );*/

                    Preferences.nombre = lista[index].nombre;
                  } else if (lista[index].nombre == despachos) {
                    Navigator.pushNamed(context, DespachoGuias.routeName);
                    Preferences.nombre = despachos;
                  }
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                color: AppColors.primaryColor,
                child: Text(
                  lista[index].nombre,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
