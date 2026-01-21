import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wahab/screens/home/home.dart';
import 'package:wahab/screens/add/add.dart';
import 'package:wahab/screens/detail/detail.dart';
import 'package:wahab/screens/sign/login_or_register.dart';
import 'package:wahab/screens/update/update.dart';
import 'package:wahab/services/product_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:wahab/model/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print(
              'Auth state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, user: ${snapshot.data?.email}');
          if (snapshot.hasError) {
            print('Auth error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            final GoRouter router = GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const Home(),
                ),
                GoRoute(
                  path: '/add',
                  builder: (context, state) {
                    final extra = state.extra;
                    return Add(initialProduct: extra as Product?);
                  },
                ),
                GoRoute(
                  path: '/detail',
                  builder: (context, state) =>
                      Detail(product: state.extra as Product),
                ),
                GoRoute(
                  path: '/update',
                  builder: (context, state) =>
                      Update(product: state.extra as Product),
                ),
              ],
            );
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              routerConfig: router,
            );
          } else {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: LoginOrRegister(),
            );
          }
        },
      ),
    );
  }
}
