import 'dart:async';
import 'dart:collection';
import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// The Ably Realtime client library establishes and maintains a persistent
/// connection to Ably enabling low latency broadcasting and receiving of
/// messages and presence state.
///
/// Learn more at the [Realtime Client Library API documentation](https://ably.com/documentation/realtime).
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// A client that extends the functionality of the
/// [RestClient]{@link RestClient} and provides additional realtime-specific
/// features.
/// END CANONICAL DOCSTRING

class Realtime extends PlatformObject {
  /// BEGIN LEGACY DOCSTRING
  /// instantiates with [ClientOptions] and a String [key]
  ///
  /// creates client options from key if [key] is provided
  ///
  /// raises [AssertionError] if both [options] and [key] are null
  /// END LEGACY DOCSTRING
  ///

  /// BEGIN CANONICAL DOCSTRING
  /// Constructs a RealtimeClient object using an Ably
  /// [ClientOptions]{@link ClientOptions} object.
  ///
  /// [ClientOptions] - A [ClientOptions]{@link ClientOptions} object.
  /// END CANONICAL DOCSTRING
  Realtime({
    ClientOptions? options,
    final String? key,
  })  : assert(options != null || key != null),
        options = options ?? ClientOptions(key: key),
        super() {
    _connection = Connection(this);
    _channels = RealtimeChannels(this);
    push = Push(realtime: this);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Create a realtime client from an API key without
  /// configuring other parameters
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Constructs a RealtimeClient object using an Ably API key or token string.
  ///
  /// [keyOrTokenStr] - The Ably API key or token string used to validate the
  /// client.
  /// END CANONICAL DOCSTRING
  factory Realtime.fromKey(String key) =>
      Realtime(options: ClientOptions(key: key));

  @override
  Future<int?> createPlatformInstance() async {
    final handle =
        await invokeWithoutHandle<int>(PlatformMethod.createRealtime, {
      TxTransportKeys.options: options,
    });
    _realtimeInstances[handle] = this;

    if (io.Platform.isAndroid && options.autoConnect) {
      /// BEGIN LEGACY DOCSTRING
      // On Android, clientOptions.autoConnect is set to `false` to prevent
      // the authCallback being called before we get the realtime handle.
      // If this happens, we won't be able to identify which realtime client
      // the authCallback belongs to. Instead, on Android, we set autoConnect
      // to false, and call connect immediately once we get the handle.
      // This is also a specific case where it's required to pass the handle
      // value from external source
      /// END LEGACY DOCSTRING
      await invoke<void>(
        PlatformMethod.connectRealtime,
        null,
        handle,
      );
    }
    return handle;
  }

  /// BEGIN LEGACY DOCSTRING
  // The _connection instance keeps a reference to this platform object.
  /// END LEGACY DOCSTRING
  late final Connection _connection;

  /// BEGIN LEGACY DOCSTRING
  /// Provides access to the underlying Connection object
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A [Connection]{@link Connection} object.
  /// END CANONICAL DOCSTRING
  Connection get connection => _connection;

  /// BEGIN LEGACY DOCSTRING
  /// a custom auth object to perform authentication related operations
  /// based on the [options]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC5
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// An [Auth]{@link Auth} object.
  /// END CANONICAL DOCSTRING
  // Auth? auth;

  /// BEGIN LEGACY DOCSTRING
  /// [ClientOptions] indicating authentication and other settings for this
  /// instance to interact with ably service
  /// END LEGACY DOCSTRING
  late ClientOptions options;

  /// BEGIN LEGACY DOCSTRING
  /// a push object interacting with Push API
  /// viz., subscribing for push notifications, etc
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A [Push]{@link Push} object.
  /// END CANONICAL DOCSTRING
  late Push push;

  late RealtimeChannels _channels;

  /// BEGIN LEGACY DOCSTRING
  /// Provides access to the underlying [RealtimeChannels]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A [Channels]{@link Channels} object.
  /// END CANONICAL DOCSTRING
  RealtimeChannels get channels => _channels;

  /// BEGIN LEGACY DOCSTRING
  /// closes the [connection]
  /// END LEGACY DOCSTRING
  Future<void> close() async => invoke(PlatformMethod.closeRealtime);

  /// BEGIN LEGACY DOCSTRING
  /// connects to [connection]
  /// END LEGACY DOCSTRING
  Future<void> connect() async => invoke<void>(PlatformMethod.connectRealtime);

  /// BEGIN LEGACY DOCSTRING
  /// creates and sends a raw request to ably service
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC19
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Makes a REST request to a provided path. This is provided as a convenience
  /// for developers who wish to use REST API functionality that is either not
  /// documented or is not yet included in the public API, without having to
  /// directly handle features such as authentication, paging, fallback hosts,
  /// MsgPack and JSON support.
  ///
  /// [method] - The request method to use, such as GET, POST.
  /// [path] - 	The request path.
  /// [params] - The parameters to include in the URL query of the request. The
  /// parameters depend on the endpoint being queried. See the REST API
  /// reference for the available parameters of each endpoint:
  /// https://ably.com/docs/api/rest-api
  /// [body] - The JSON body of the request.
  /// [headers] - Additional HTTP headers to include in the request.
  ///
  /// [HttpPaginatedResponse] - An
  /// [HttpPaginatedResponse]{@link HttpPaginatedResponse} response object
  /// returned by the HTTP request, containing an empty or JSON-encodable
  /// object.
  /// END CANONICAL DOCSTRING
  // Future<HttpPaginatedResponse> request({
  //   required String method,
  //   required String path,
  //   Map<String, dynamic>? params,
  //   Object? body,
  //   Map<String, String>? headers,
  // }) {
  //   throw UnimplementedError();
  // }

  /// BEGIN LEGACY DOCSTRING
  /// gets stats based on params as a [PaginatedResult]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC6
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Queries the REST /stats API and retrieves your application's usage
  /// statistics. Returns a [PaginatedResult]{@link PaginatedResult} object,
  /// containing an array of [Stats]{@link Stats} objects. See the Stats docs.
  ///
  /// [start] - The time from which stats are retrieved, specified as
  /// milliseconds since the Unix epoch.
  /// [end] - The time until stats are retrieved, specified as milliseconds
  /// since the Unix epoch.
  /// [direction] - The order for which stats are returned in. Valid values
  /// are backwards which orders stats from most recent to oldest, or forwards
  /// which orders stats from oldest to most recent. The default is backwards.
  /// [limit] - An upper limit on the number of stats returned. The default is
  /// 100, and the maximum is 1000.
  /// [unit] - 	minute, hour, day or month. Based on the unit selected, the
  /// given start or end times are rounded down to the start of the relevant
  /// interval depending on the unit granularity of the query.
  ///
  /// [PaginatedResult] - A [PaginatedResult]{@link PaginatedResult} object
  /// containing an array of [Stats]{@link Stats} objects.
  /// END CANONICAL DOCSTRING
  // Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
  //   throw UnimplementedError();
  // }

  /// BEGIN LEGACY DOCSTRING
  /// returns server time
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC16
  /// END LEGACY DOCSTRING
  Future<DateTime> time() async {
    final time = await invokeRequest<int>(PlatformMethod.realtimeTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// BEGIN LEGACY DOCSTRING
  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH8
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves a [LocalDevice]{@link LocalDevice} object that represents the
  /// current state of the device as a target for push notifications.
  ///
  /// [LocalDevice] - A [LocalDevice]{@link LocalDevice} object.
  /// END CANONICAL DOCSTRING
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}

Map<int?, Realtime> _realtimeInstances = {};

/// BEGIN LEGACY DOCSTRING
/// Returns readonly copy of instances of all [Realtime] clients created.
/// END LEGACY DOCSTRING
Map<int?, Realtime> get realtimeInstances =>
    UnmodifiableMapView(_realtimeInstances);
