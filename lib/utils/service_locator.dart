import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/location/location_cubit.dart';
import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
import 'package:ride_sharing_app/cubits/notification/notification_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
import 'package:ride_sharing_app/services/auth_service.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';
import 'package:ride_sharing_app/services/notification_service.dart';
import 'package:ride_sharing_app/services/openstreetmap_service.dart';

final getIt = GetIt.instance;
void setupDependencies() {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<DatabaseReference>(
    () => FirebaseDatabase.instance.ref(),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(auth: 

       getIt<FirebaseAuth>(),
      database:
       getIt<DatabaseReference>(),
    ),
  );

  getIt.registerLazySingleton<DatabaseService>(
    () => DatabaseService(database:  getIt<DatabaseReference>()),
  );

  getIt.registerLazySingleton<OpenStreetMapService>(
    () => OpenStreetMapService(),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authService: getIt<AuthService>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  getIt.registerFactory<LocationCubit>(
    () => LocationCubit(dbService: getIt<DatabaseService>()),
  );

  getIt.registerFactory<MapCubit>(
    () => MapCubit(mapService: getIt<OpenStreetMapService>()),
  );

  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(notificationService: getIt<NotificationService>()),
  );

  getIt.registerFactory<RideCubitWithNotifications>(
    () => RideCubitWithNotifications(
      databaseService: getIt<DatabaseService>(),
      notificationCubit: getIt<NotificationCubit>(),
    ),
  );

}
