import 'package:events/core/providers/local_image_provider.dart';
import 'package:events/core/providers/remote_image_provider.dart';
import 'package:events/router.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'core/repository/database_repository.dart';
import 'core/services/main_cach_manager.dart';
import 'supabase_config.dart';

const appVersion = '1.0.0';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final router = AppRouter().buildRoutes();
  final remoteImageProvider = RemoteImageProvider(cacheManager: MainCacheManager());
  final localImageProvider = LocalImageProvider.fileSystem(const LocalFileSystem(), remoteImageProvider);
  final databaseRepository = await DatabaseRepository.create(localImageProvider);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: databaseRepository),
        RepositoryProvider.value(value: databaseRepository.getEventRepository()),
        RepositoryProvider.value(value: localImageProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'برنامه ها',
        theme: AppTheme.light(),
        locale: const Locale('fa', 'IR'),
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox()),
      ),
    ),
  );
}
