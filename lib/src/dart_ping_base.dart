import 'dart:async';
import 'dart:io';
import 'dart:convert';

/// Information about ping response
class PingInfo {
  /// Sequential number of response
  int seq;

  /// TTL of ping. Describes how many routers packets visited in process
  int ttl;

  /// Time of ping.
  Duration time;

  PingInfo._new(this.seq, this.ttl, this.time);

  @override
  String toString() => 'SEQ: $seq; TTL: $ttl; Duration: $time';
}

var _regexUnix = RegExp(r"icmp_seq=(\d+) ttl=(\d+) time=((\d+).?(\d+))");
var _regexWindows = RegExp(r"bytes=(\d+) time=(\d+)ms TTL=(\d+)");

StreamTransformer<String, PingInfo> _unixTransformer = StreamTransformer.fromHandlers(handleData: (data, sink) {
  if(data.contains("bytes from")) {
    var match = _regexUnix.firstMatch(data);
    sink.add(PingInfo._new(int.parse(match.group(1)), int.parse(match.group(2)), Duration(milliseconds: int.parse(match.group(4)), microseconds: int.parse(match.group(5)) * 100)));
  }
});

StreamTransformer<String, PingInfo> _windowsTransformer = StreamTransformer.fromHandlers(handleData: (data, sink) {
  if(data.startsWith("Reply from")) {
    var match = _regexWindows.firstMatch(data);
    sink.add(PingInfo._new(int.parse(match.group(1)), int.parse(match.group(3)), Duration(milliseconds: int.parse(match.group(2)))));
  }
});

/// Pings host with [address]. Returns Stream with [PingInfo].
Future<Stream<PingInfo>> ping(String address, {int times, int packetSize = 64, int interval = 1}) async {
  List<String> args = [address, "-s ${packetSize}", "-i $interval"];
  if (times != null) args.add('-c $times');
  // TODO: windows sends 4 packets by default, have it set to infinite
  var process = await Process.start("ping", args);
  var baseStream = process.stdout.transform(utf8.decoder).transform(LineSplitter());

  if(Platform.isWindows)
    return baseStream.transform<PingInfo>(_windowsTransformer);
  else
    return baseStream.transform<PingInfo>(_unixTransformer);
}