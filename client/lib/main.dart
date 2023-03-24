import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToPusher();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ...List.generate(
              messages.length,
              (index) => Text(messages[index]),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myPrivateChannel.trigger(
            eventName: 'client-chat',
            data: {"payload": "Hello Flutter"},
          );

          myPresenceChannel.trigger(
            eventName: 'client-presence',
            data: {"payload": "Hello Flutter"},
          );

          _incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Create an instance PusherChannelsOptions
  // The test options can be accessed from test.pusher.com (using only for test purposes)
  final testOptions = const PusherChannelsOptions.fromHost(
    host: '10.0.2.2', // '192.168.0.233', //
    scheme: 'ws',
    key: 'secr3t', //'fbzt346gcffrd\$§\$§§trfdtgsf\$%\$dgdgsdz3546346hxdfhs',
    port: 6001,
  );
  // Create an instance of PusherChannelsClient
  late PusherChannelsClient client;

  // Create instances of Channel
  late PresenceChannel myPresenceChannel;
  late PrivateChannel myPrivateChannel;
  late PublicChannel myPublicChannel;

  late StreamSubscription<ChannelReadEvent> somePrivateChannelEventSubs;
  late StreamSubscription<ChannelReadEvent> somePublicChannelEventSubs;
  late StreamSubscription<ChannelReadEvent> presenceMembersAddedSubs;

  List<Channel> allChannels = [];
  List<StreamSubscription?> allEventSubs = [];

  late StreamSubscription connectionSubs;

  String token =
      "6|AioTiuCYVjtoj7HZiwAFULT9YU6sUNFDuV0Ylm1w"; //"4|pO1Lq0pHa0ySHlpZOPBBGTCUAnLqf3RimlHqgGW6";
  void connectToPusher() async {
    // Enable or disable logs
    PusherChannelsPackageLogger.enableLogs();

    // Create an instance of PusherChannelsClient
    client = PusherChannelsClient.websocket(
      options: testOptions,
      // Connection exceptions are handled here
      connectionErrorHandler: (exception, trace, refresh) async {
        // This method allows you to reconnect if any error is occurred.
        refresh();
      },
    );

    // Create instances of Channel
    myPresenceChannel = client.presenceChannel(
      'presence-presence.channel',
      // Private and Presence channels require users to be authorized.
      // Use EndpointAuthorizableChannelTokenAuthorizationDelegate to authorize through
      // an http endpoint or create your own delegate by implementing EndpointAuthorizableChannelAuthorizationDelegate
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPresenceChannel(
        authorizationEndpoint:
            Uri.parse('http://192.168.0.233:8000/api/broadcasting/auth'),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    myPrivateChannel = client.privateChannel(
      'private-App.User.2', //'private-chat',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint:
            Uri.parse('http://192.168.0.233:8000/api/broadcasting/auth'),
        headers: {"Authorization": "Bearer $token"},
        onAuthFailed: (exception, trace) {
          print(exception);
        },
      ),
    );

    myPublicChannel = client.publicChannel('public-channel');

    // Unlike other SDKs, dart_pusher_channels offers binding to events
    // via Dart streams, so it's recommended to create StreamSubscription for
    // each event you want to subscribe for.

    // Keep in mind: those StreamSubscription instances will contintue receiving events
    // unless it gets canceled or channel gets unsubscribed.
    // The statement means: if you cancel an instance of StreamSubscription - events won't be received,
    // if you unsubscribe from a channel  -
    // the stream won't be closed but prevented from receiving events unless you subscribe to the channel again.

    // Listen for events of the channel with .bind method
    somePrivateChannelEventSubs =
        myPrivateChannel.bind('new-message-event').listen((event) {
      setState(() {
        //final data = event.data;
        messages.add('new-message-event');
      });
      print('Event from the private channel fired!');
    });
    somePublicChannelEventSubs =
        myPublicChannel.bind('public-NewChatMessage').listen((event) {
      print('Event from the public channel fired!');
    });

    // You may use some helpful extension shortcut methods for the predefined channel events.
    // For example, this one binds to events of the channel with name 'pusher:member_added'
    presenceMembersAddedSubs =
        myPresenceChannel.whenMemberAdded().listen((event) {
      print(
        'Member added, now members count is ${myPresenceChannel.state?.members?.membersCount}',
      );
    });

    // Organizing all subscriptions into 1 for readability
    allEventSubs = <StreamSubscription?>[
      presenceMembersAddedSubs,
      somePrivateChannelEventSubs,
      somePublicChannelEventSubs,
    ];
    // Organizing all channels for readibility
    allChannels = <Channel>[
      myPresenceChannel,
      myPrivateChannel,
      myPublicChannel,
    ];

    // Highly recommended to subscribe to the channels when the clients'
    // .onConnectionEstablished Stream fires an event because it enables
    // to resubscribe, for example, when the client reconnects due to
    // a connection error
    connectionSubs = client.onConnectionEstablished.listen((_) {
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
      eventName: 'client-chat',
      data: {'hello': 'Hello'},
    );

    // If you no longer need a channel - unsubscribe from it. Channel instances are reusable
    // so it is possible to subscribe to it later, if needed, using .subscribe method.

    // Somewhere in future
    await Future.delayed(const Duration(seconds: 5));
    //myPresenceChannel.unsubscribe();
    // Somewhere in future
    await Future.delayed(const Duration(seconds: 5));
    //myPresenceChannel.subscribe();

    // If you want to unbind from the event - simply cancel an event subscription.
    // Somewhere in future
    await Future.delayed(const Duration(seconds: 5));
    //await presenceMembersAddedSubs.cancel();
  }

  void _disposeClient() async {
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

  @override
  void dispose() {
    super.dispose();
    _disposeClient();
  }
}
