import 'package:dart_ping/dart_ping.dart';

main() async {
  var stream = await ping("google.com", times: 5);

  print("Pinging google.com");
  stream.listen((d) {
    print(d.time.inMilliseconds);
  });
}