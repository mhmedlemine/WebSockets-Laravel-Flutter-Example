// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:pusher_client/pusher_client.dart';

// class WebSocketsApp extends StatefulWidget {
//   const WebSocketsApp({super.key});

//   @override
//   WebSocketsAppState createState() => WebSocketsAppState();
// }

// class WebSocketsAppState extends State<WebSocketsApp> {
//   late PusherClient pusher;
//   late Channel channel;
//   String msg = '';

//   @override
//   void initState() {
//     super.initState();

//     String token = getToken();

//     pusher = PusherClient(
//       "app-key",
//       PusherOptions(
//         // if local on android use 10.0.2.2
//         host: '10.0.2.2',
//         encrypted: false,
//         // auth: PusherAuth(
//         //   'http://192.168.0.233/auth',
//         //   headers: {
//         //     'Authorization': 'Bearer $token',
//         //   },
//         // ),
//       ),
//       enableLogging: true,
//       autoConnect: false,
//     );

//     pusher.connect().then((value) => null).catchError((err) {
//       print(err);
//     });
//     channel = pusher.subscribe("chat");

//     pusher.onConnectionStateChange((state) {
//       log("previousState: ${state?.previousState}, currentState: ${state?.currentState}");
//     });

//     pusher.onConnectionError((error) {
//       log("error: ${error?.message}");
//     });

//     channel.bind('status-update', (event) {
//       log('${event?.data}');
//     });

//     channel.bind('order-filled', (event) {
//       log('Order Filled Event ${event?.data?.toString()}');
//     });
//   }

//   String getToken() => "super-secret-token";

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Example Pusher App'),
//         ),
//         body: Center(
//             child: Column(
//           children: [
//             Text(msg),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               child: const Text('Unsubscribe Chat'),
//               onPressed: () {
//                 pusher.unsubscribe('chat');
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Unbind Status Update'),
//               onPressed: () {
//                 channel.unbind('status-update');
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Unbind Order Filled'),
//               onPressed: () {
//                 channel.unbind('order-filled');
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Bind Status Update'),
//               onPressed: () {
//                 channel.bind('status-update', (PusherEvent? event) {
//                   log("Status Update Event ${event?.data.toString()}");
//                 });
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Trigger Client Typing'),
//               onPressed: () {
//                 channel.trigger('client-istyping', {'name': 'Bob'});
//               },
//             ),
//           ],
//         )),
//       ),
//     );
//   }
// }
