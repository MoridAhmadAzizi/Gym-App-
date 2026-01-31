import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wahab/objectbox/objectbox.dart';
import 'package:wahab/screens/home/home.dart';
import 'package:wahab/screens/add/add.dart';
import 'package:wahab/screens/detail/detail.dart';
import 'package:wahab/screens/sign/login_or_register.dart';
import 'package:wahab/screens/update/update.dart';
import 'package:wahab/services/product_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wahab/services/product_repo.dart';
import 'firebase_options.dart';
import 'package:wahab/model/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final ob = await ObjectBoxApp.create();
  Get.put<ObjectBoxApp>(ob);

  Get.put(ProductRepo());
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
          // تابع کمکی برای ایجاد MaterialApp با RTL
          MaterialApp createRtlMaterialApp({Widget? home, GoRouter? router}) {
            if (router != null) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Wahab',
                routerConfig: router,
                theme: ThemeData(
                  fontFamily: 'Vazirmatn',
                ),
                // تنظیمات RTL
                locale: const Locale('fa', 'IR'),
                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  );
                },
              );
            } else {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Wahab',
                home: home,
                theme: ThemeData(
                  fontFamily: 'Vazirmatn',
                ),
                // تنظیمات RTL
                locale: const Locale('fa', 'IR'),
                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  );
                },
              );
            }
          }

          if (snapshot.hasError) {
            return createRtlMaterialApp(
              home: const Scaffold(
                body: Center(
                  child: Text('خطا در ارتباط با سرور'),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return createRtlMaterialApp(
              home: const Scaffold(
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
                    final p = state.extra as Product?;
                    return Add(initialProduct: p);
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
            return createRtlMaterialApp(router: router);
          } else {
            return createRtlMaterialApp(
              home: const LoginOrRegister(),
            );
          }
        },
      ),
    );
  }
}
