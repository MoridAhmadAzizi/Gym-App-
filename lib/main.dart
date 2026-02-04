import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'objectbox/objectbox.dart';
import 'screens/home.dart';
import 'screens/login_or_register.dart';
import 'services/auth_service.dart';
import 'services/product_repo.dart';
import 'services/profile_repo.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final ob = await ObjectBoxApp.create();
  final client = Supabase.instance.client;

  // Services / Repos
  Get.put<AuthService>(AuthService(client), permanent: true);
  Get.put<ProfileRepo>(ProfileRepo(client), permanent: true);
  Get.put<ProductRepo>(ProductRepo(client: client, objectBox: ob), permanent: true);

  // Controllers
  Get.put<AuthController>(
    AuthController(auth: Get.find<AuthService>(), profiles: Get.find<ProfileRepo>()),
    permanent: true,
  );
  Get.put<ProductController>(
    ProductController(Get.find<ProductRepo>()),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wahab',
      theme: AppTheme.light(),
      locale: const Locale('fa', 'IR'),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox()),
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final ac = Get.find<AuthController>();

    return Obx(() {
      if (ac.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // اگر لاگین نیست => لاگین
      if (!ac.isAuthenticated) {
        return const LoginOrRegister();
      }

      // اگر لاگین هست => هوم
      return const Home();
    });
  }
}
