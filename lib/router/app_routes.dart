import 'package:flutter/material.dart';

import '../screen/screens.dart';

class AppRoutes {
  static final initialRoute = LoginScreen.routeName;

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};

    appRoutes.addAll({
      LoginScreen.routeName: (BuildContext context) => const LoginScreen(),
      HomeScreen.routeName: (BuildContext context) => const HomeScreen(),
      MenuPermisosScreen.routeName: (BuildContext context) =>
          const MenuPermisosScreen(),
      SuperBultosScreen.routeName: (BuildContext context) =>
          const SuperBultosScreen(),
      MantenimientoSuperBultosScreen.routeName: (BuildContext context) =>
          const MantenimientoSuperBultosScreen(),
      ConsolidacionCargasScreen.routeName: (BuildContext context) =>
          const ConsolidacionCargasScreen(),
      ConsolidacionCargasDetalleFacturasScreen.routeName:
          (BuildContext context) =>
              const ConsolidacionCargasDetalleFacturasScreen(),
      ConsolidacionCargasDetalleBultosScreen.routeName:
          (BuildContext context) =>
              const ConsolidacionCargasDetalleBultosScreen(),
      ConsolidacionRutasFaltantesScreen.routeName: (BuildContext context) =>
          const ConsolidacionRutasFaltantesScreen(),
      ConsolidacionDetalleFaltantesScreen.routeName: (BuildContext context) =>
          const ConsolidacionDetalleFaltantesScreen(),
      ReaperturaScreen.routeName: (BuildContext context) =>
          const ReaperturaScreen(),
          DespachoGuias.routeName: (BuildContext context) => const DespachoGuias()
    });

    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const LoginScreen());
  }
}
