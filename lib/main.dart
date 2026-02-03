import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wahab/app_theme.dart';
import 'package:wahab/model/product.dart';
import 'package:wahab/objectbox/objectbox.dart';
import 'package:wahab/screens/add/add.dart';
import 'package:wahab/screens/detail/detail.dart';
import 'package:wahab/screens/home/home.dart';
import 'package:wahab/screens/sign/login_or_register.dart';
import 'package:wahab/screens/sign/otp_page.dart';
import 'package:wahab/screens/admin/users_page.dart';
import 'package:wahab/services/auth_cubit.dart';
import 'package:wahab/services/auth_services.dart';
import 'package:wahab/services/product_cubit.dart';
import 'package:wahab/services/product_repo.dart';
import 'package:wahab/services/profile_repo.dart';
import 'package:wahab/services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final ob = await ObjectBoxApp.create();
  final client = Supabase.instance.client;

  final productRepo = ProductRepo(client: client, objectBox: ob);
  final authService = AuthService(client);
  final profileRepo = ProfileRepo(client);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: productRepo),
        RepositoryProvider.value(value: authService),
        RepositoryProvider.value(value: profileRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(auth: authService, profiles: profileRepo)),
          BlocProvider(create: (_) => ProductCubit(productRepo)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialApp buildApp({Widget? home, GoRouter? router}) {
      if (router != null) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Wahab',
          routerConfig: router,
          theme: AppTheme.light(),
          locale: const Locale('fa', 'IR'),
          builder: (context, child) {
            return Directionality(textDirection: TextDirection.rtl, child: child!);
          },
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wahab',
        home: home,
        theme: AppTheme.light(),
        locale: const Locale('fa', 'IR'),
        builder: (context, child) {
          return Directionality(textDirection: TextDirection.rtl, child: child!);
        },
      );
    }

    return BlocBuilder<AuthCubit, AppAuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return buildApp(
            home: const Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (!state.isAuthenticated) {
          final router = GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, __) => const LoginOrRegister()),
              GoRoute(
                path: '/otp',
                builder: (context, s) {
                  final email = (s.extra as String?) ?? '';
                  return OtpPage(email: email);
                },
              ),
            ],
          );
          return buildApp(router: router);
        }

        final router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, __) => const Home()),
            GoRoute(
              path: '/add',
              builder: (context, state) {
                final p = state.extra as Product?;
                return Add(initialProduct: p);
              },
            ),
            GoRoute(
              path: '/detail',
              builder: (context, state) => Detail(product: state.extra as Product),
            ),
            GoRoute(
              path: '/users',
              builder: (context, state) => const UsersPage(),
            ),
          ],
        );

        return buildApp(router: router);
      },
    );
  }
}
