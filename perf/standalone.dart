library angular;

import '../lib/parser/parser_library.dart';
import 'package:perf_api/perf_api.dart';

class _NoOpProfiler extends Profiler {
  void markTime(String name, [String extraData]) { }

  int startTimer(String name, [String extraData]) => null;

  void stopTimer(idOrName) { }
}


main() {
  print('start');
  var profiler = new _NoOpProfiler();
  var lexer = new Lexer();
  var backend = new ParserBackend();
  var parser = new DynamicParser(profiler, lexer, backend);
  var fn = parser('a.b');
  var scope = {
    "a": {
      "b": "foo"
    }
  };
  var eval = fn.eval;
  print(measure(() => eval(scope)));
  print('end');
}


measure(body) {
  var count = 0;
  var stopwatch = new Stopwatch();
  stopwatch.start();
  do {
// 1
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

// 2
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

// 3
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

// 4
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

// 5
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

// 6
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    count += 50;
  } while(stopwatch.elapsedMicroseconds < 1000000);
  stopwatch.stop();
  var rate = count / stopwatch.elapsedMicroseconds;
  return rate * 1000000;
}
