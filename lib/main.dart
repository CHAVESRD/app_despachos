import 'package:despachos_app/shared/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/text_constants.dart';
import 'providers/providers.dart';
import 'router/app_routes.dart';
import 'screen/screens.dart';
import 'package:auto_update/auto_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();

  String initialRoute = await initialization(null);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => LoginFormProvider()),
    ChangeNotifierProvider(create: (_) => DespachoProvider()),
    ChangeNotifierProvider(create: (_) => SuperBultoProvider()),
    ChangeNotifierProvider(create: (_) => ImpresionProvider()),
    ChangeNotifierProvider(create: (_) => ConsolidacionCargasProvider()),
    ChangeNotifierProvider(create: (_) => ReaperturaProvider()),
    ChangeNotifierProvider(create: (_) => CatalogoProvider()),
    ChangeNotifierProvider(create: (_) => SucursalProvider()),
    ChangeNotifierProvider(create: (_) => MenuProvider()),
    ChangeNotifierProvider(create: (_) => ProveedorDespachoGuia())
  ], child: MyApp(initialRoute: initialRoute)));
}

Future<String> initialization(BuildContext? context) async {
  if (Preferences.usuario.isNotEmpty && Preferences.compania != 0) {
    return HomeScreen.routeName;
  }
  return AppRoutes.initialRoute;
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  MyApp({Key? key, required this.initialRoute}) : super(key: key);

  String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<dynamic, dynamic> _urlPaqueteActualizador = {};
  @override
  void initState() {
    super.initState();
    iniciarEstadoPlataforma();
  }

  Future<void> iniciarEstadoPlataforma() async {
    Map<dynamic, dynamic> urlActualizador;
    try{
      urlActualizador = await AutoUpdate.fetchGithub(user, packageName)
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: TextConstants.appName,
      initialRoute: widget.initialRoute,
      routes: AppRoutes.getAppRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
