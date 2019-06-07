## dart-ping

This tool allows to send pings via Dart program. 
It uses built-in command `ping` and parses output of this commands. 
It properly handles *nix systems and Windows.

## Documentation

`Future<Stream<PingInfo>> ping(String address, {int times = 4, int packetSize = 64, int interval = 1})`
 * `adress` - address of remote host to ping. Can be domain name (google.com) or ip address (127.0.0.1)
 * `times` - how many ping will be sent
 * `packetSize` - size of packet in bytes
 * `interval` - interval between ping
 
 ```dart
var pings = await ping('google.pl');

pings.listen((ping) {
  print(ping.time.inMilliseconds);
});
```