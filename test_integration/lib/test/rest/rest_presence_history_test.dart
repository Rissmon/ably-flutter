import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/data.dart';
import '../../utils/rest.dart';

Future<Map<String, dynamic>> testRestPresenceHistory({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await provision('sandbox-');
  final logMessages = <List<String>>[];

  final options = ClientOptions.fromKey(appKey.toString())
    ..environment = 'sandbox'
    ..clientId = 'someClientId'
    ..logLevel = LogLevel.verbose
    ..logHandler =
        ({msg, exception}) => logMessages.add([msg, exception.toString()]);

  final rest = Rest(options: options);
  final channel = rest.channels.get('test');

  final historyInitial = await getPresenceHistory(channel);

  // creating presence history on channel
  final realtimePresence =
      Realtime(options: options).channels.get('test').presence;
  // single client enters channel
  await realtimePresence.enter(messagesToPublish.first[1]);
  // updates, multiple times with different messages
  for (var i = 1; i < messagesToPublish.length - 1; i++) {
    await realtimePresence.update(messagesToPublish[i][1]);
  }
  // leaves channel
  await realtimePresence.leave(messagesToPublish.last[1]);

  final historyDefault = await getPresenceHistory(channel);
  await Future.delayed(const Duration(seconds: 2));

  final historyLimit4 = await getPresenceHistory(
    channel,
    RestHistoryParams(limit: 4),
  );
  await Future.delayed(const Duration(seconds: 2));

  final historyLimit2 = await getPresenceHistory(
    channel,
    RestHistoryParams(limit: 2),
  );
  await Future.delayed(const Duration(seconds: 2));

  final historyForwards = await getPresenceHistory(
    channel,
    RestHistoryParams(direction: 'forwards'),
  );
  await Future.delayed(const Duration(seconds: 2));

  final time1 = DateTime.now();
  //TODO(tiholic) iOS fails without this delay
  // - timestamp on message retrieved from history
  // is earlier than expected when ran in CI
  await Future.delayed(const Duration(seconds: 2));
  await realtimePresence.enter('enter-start-time');
  // TODO(tiholic) understand why tests fail without this delay
  await Future.delayed(const Duration(seconds: 2));

  final time2 = DateTime.now();
  await Future.delayed(const Duration(seconds: 2));
  await realtimePresence.leave('leave-end-time');
  await Future.delayed(const Duration(seconds: 2));

  final historyWithStart = await getPresenceHistory(
    channel,
    RestHistoryParams(start: time1),
  );
  final historyWithStartAndEnd = await getPresenceHistory(
    channel,
    RestHistoryParams(start: time1, end: time2),
  );
  final historyAll = await getPresenceHistory(channel);

  return {
    'handle': await rest.handle,
    'historyInitial': historyInitial,
    'historyDefault': historyDefault,
    'historyLimit4': historyLimit4,
    'historyLimit2': historyLimit2,
    'historyForwards': historyForwards,
    'historyWithStart': historyWithStart,
    'historyWithStartAndEnd': historyWithStartAndEnd,
    'historyAll': historyAll,
    'log': logMessages,
  };
}
