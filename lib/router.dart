import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/events/ui/event_screen.dart';

class AppRouter {
  RouterConfig<Object> buildRoutes() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          // builder: (context, state) => LoginPage(onTap: () {}),
          builder: (context, state) => const EventScreen(),
        ),
      ],
    );
  }
}
