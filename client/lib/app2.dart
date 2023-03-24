import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

void connectToPusher() async {
  // Enable or disable logs
  PusherChannelsPackageLogger.enableLogs();
  // Create an instance PusherChannelsOptions
  // The test options can be accessed from test.pusher.com (using only for test purposes)
  const testOptions = PusherChannelsOptions.fromHost(
    host: '10.0.2.2', // '192.168.0.233', //
    scheme: 'ws',
    key: 'fbzt346gcffrd\$§\$§§trfdtgsf\$%\$dgdgsdz3546346hxdfhs',
    port: 6001,
  );
  // Create an instance of PusherChannelsClient
  final client = PusherChannelsClient.websocket(
    options: testOptions,
    // Connection exceptions are handled here
    connectionErrorHandler: (exception, trace, refresh) async {
      // This method allows you to reconnect if any error is occurred.
      refresh();
    },
  );

  // Create instances of Channel
  PresenceChannel myPresenceChannel = client.presenceChannel(
    'presence-channel',
    // Private and Presence channels require users to be authorized.
    // Use EndpointAuthorizableChannelTokenAuthorizationDelegate to authorize through
    // an http endpoint or create your own delegate by implementing EndpointAuthorizableChannelAuthorizationDelegate
    authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate
        .forPresenceChannel(
      authorizationEndpoint: Uri.parse('https://test.pusher.com/pusher/auth'),
      headers: const {},
    ),
  );
  PrivateChannel myPrivateChannel = client.privateChannel(
    'private-channel',
    authorizationDelegate:
        EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
      authorizationEndpoint: Uri.parse('https://test.pusher.com/pusher/auth'),
      headers: const {},
    ),
  );
  PublicChannel myPublicChannel = client.publicChannel(
    'chat', //'public-channel',
  );

  // Unlike other SDKs, dart_pusher_channels offers binding to events
  // via Dart streams, so it's recommended to create StreamSubscription for
  // each event you want to subscribe for.

  // Keep in mind: those StreamSubscription instances will contintue receiving events
  // unless it gets canceled or channel gets unsubscribed.
  // The statement means: if you cancel an instance of StreamSubscription - events won't be received,
  // if you unsubscribe from a channel  -
  // the stream won't be closed but prevented from receiving events unless you subscribe to the channel again.

  // Listen for events of the channel with .bind method
  StreamSubscription<ChannelReadEvent> somePrivateChannelEventSubs =
      myPrivateChannel.bind('private-MyEvent').listen((event) {
    print('Event from the private channel fired!');
  });
  StreamSubscription<ChannelReadEvent> somePublicChannelEventSubs =
      myPublicChannel.bind('public-MyEvent').listen((event) {
    print('Event from the public channel fired!');
  });

  // You may use some helpful extension shortcut methods for the predefined channel events.
  // For example, this one binds to events of the channel with name 'pusher:member_added'
  StreamSubscription<ChannelReadEvent> presenceMembersAddedSubs =
      myPresenceChannel.whenMemberAdded().listen((event) {
    print(
      'Member added, now members count is ${myPresenceChannel.state?.members?.membersCount}',
    );
  });

  // Organizing all subscriptions into 1 for readability
  final allEventSubs = <StreamSubscription?>[
    presenceMembersAddedSubs,
    somePrivateChannelEventSubs,
    somePublicChannelEventSubs,
  ];
  // Organizing all channels for readibility
  final allChannels = <Channel>[
    myPresenceChannel,
    myPrivateChannel,
    myPublicChannel,
  ];

  // Highly recommended to subscribe to the channels when the clients'
  // .onConnectionEstablished Stream fires an event because it enables
  // to resubscribe, for example, when the client reconnects due to
  // a connection error
  final StreamSubscription connectionSubs =
      client.onConnectionEstablished.listen((_) {
    for (final channel in allChannels) {
      // Subscribes to the channel if didn't unsubscribe from it intentionally
      channel.subscribeIfNotUnsubscribed();
    }
  });

  // Connect with the client
  unawaited(client.connect());

  // You can trigger events from Private and Presence Channels

  // Somewhere in future
  await Future.delayed(
    const Duration(seconds: 5),
  );

  myPresenceChannel.trigger(
    eventName: 'client-event',
    data: {'hello': 'Hello'},
  );

  // If you no longer need a channel - unsubscribe from it. Channel instances are reusable
  // so it is possible to subscribe to it later, if needed, using .subscribe method.

  // Somewhere in future
  await Future.delayed(const Duration(seconds: 5));
  myPresenceChannel.unsubscribe();
  // Somewhere in future
  await Future.delayed(const Duration(seconds: 5));
  myPresenceChannel.subscribe();

  // If you want to unbind from the event - simply cancel an event subscription.
  // Somewhere in future
  await Future.delayed(const Duration(seconds: 5));
  await presenceMembersAddedSubs.cancel();

  // If you no longer need the client - cancel the connection subscription and dispose it.

  // Somewhere in future
  await Future.delayed(const Duration(seconds: 5));
  await connectionSubs.cancel();
  // Consider canceling the event subscriptions to
  for (final subscription in allEventSubs) {
    subscription?.cancel();
  }
  client.dispose();
}
