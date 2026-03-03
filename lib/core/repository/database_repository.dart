import 'dart:async';
import 'package:events/core/providers/local_image_provider.dart';
import 'package:events/features/events/repository/event_repository.dart';
import 'package:events/objectbox.g.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Store? _databaseStore;

class DatabaseRepository {
  DatabaseRepository._(this.store, this.localImageProvider);

  final Store store;
  final LocalImageProvider localImageProvider;

  static Future<DatabaseRepository> create(LocalImageProvider localImageProvider) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final databaseFile = join(docsDir.path, 'repository');
    if (_databaseStore == null) {
      if (Store.isOpen(databaseFile)) {
        _databaseStore = Store.attach(getObjectBoxModel(), databaseFile);
      } else {
        _databaseStore = await openStore(directory: databaseFile);
      }
    }
    final databaseRepository = DatabaseRepository._(_databaseStore!, localImageProvider);
    return databaseRepository;
  }

  EventRepository getEventRepository() => EventRepository(_databaseStore!.box(), localImageProvider);
}
