import 'package:logger/logger.dart';

class ZLogger extends Logger {
  ZLogger({
    this.tag = '',
    bool? debug = false,
  })  : assert(
          () {
            debug = true;
            return true;
          }(),
          'Pretty printing in debug',
        ),
        super(
          printer: PrettyPrinter(
            methodCount: 0,
            noBoxingByDefault: true,
            printTime: debug ?? false,
            colors: debug ?? false,
            printEmojis: debug ?? false,
          ),
          filter: CustomFilter(),
          output: MultiOutput(
            [
              ConsoleTagOutput(tag),
            ],
          ),
        );

  final String tag;
}

class ConsoleTagOutput extends LogOutput {
  ConsoleTagOutput(this.tag);

  final String tag;

  @override
  void output(OutputEvent event) {
    var shouldLog = false;
    assert(
      () {
        shouldLog = true;
        return true;
      }(),
      'Console log is enabled in debug mode',
    );

    if (!shouldLog) {
      return;
    }
    // ignore: avoid_print
    for (final e in event.lines) {
      final t = tag.isNotEmpty ? '[$tag] ' : '';
      // ignore: avoid_print
      print('$t$e');
    }
  }
}

class CustomFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // in debug mode
    var shouldLog = false;
    assert(
      () {
        shouldLog = true;
        return true;
      }(),
      'Log is enabled in debug mode',
    );

    if (event.level.index >= Level.debug.index) {
      return true;
    }
    return shouldLog;
  }
}
