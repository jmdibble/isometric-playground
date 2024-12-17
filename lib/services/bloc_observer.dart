import 'package:bloc/bloc.dart';
import 'package:isometric_playground/utils/logger.dart';
import 'package:logger/logger.dart';

/// {@template counter_observer}
/// [BlocObserver] for the counter application which
/// observes all state changes.
/// {@endtemplate}
class AppBlocObserver extends BlocObserver {
  /// {@macro counter_observer}
  AppBlocObserver();

  final Logger log = ZLogger(tag: 'AppBlocObserver');

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // if (kDebugMode) {
    //   log.i(
    //     'onChange: ${bloc.runtimeType},'
    //     '\nCurr: ${change.currentState}\nNext: ${change.nextState}',
    //   );
    // }
  }
}
