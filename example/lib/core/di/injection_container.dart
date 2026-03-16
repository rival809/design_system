import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../theme/theme_notifier.dart';
import '../../features/user_registration/data/datasources/user_remote_datasource.dart';
import '../../features/user_registration/data/repositories/user_repository_impl.dart';
import '../../features/user_registration/domain/repositories/user_repository.dart';
import '../../features/user_registration/domain/usecases/create_user_usecase.dart';
import '../../features/user_registration/domain/usecases/get_users_usecase.dart';
import '../../features/user_registration/presentation/bloc/registration_bloc.dart';
import '../../features/user_registration/presentation/cubit/user_list_cubit.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Register all dependencies. Call once from [main].
Future<void> initDependencies() async {
  // ── Core ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeNotifier>(ThemeNotifier.new);
  sl.registerLazySingleton<DioClient>(DioClient.new);

  // ── Data Sources ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(sl()));

  // ── Repositories ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // ── Use Cases ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));

  // ── BLoC / Cubit (factory = fresh instance per widget) ─────────────────────
  sl.registerFactory(() => RegistrationBloc(createUserUseCase: sl()));
  sl.registerFactory(() => UserListCubit(getUsersUseCase: sl()));
}
