import 'package:bands_app/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  
          children: <Widget>[ 
            Text('ServerStatus: ${socketService.serverStatus}')
          ]
        ),
     ),
     floatingActionButton: FloatingActionButton(  
       child: const Icon(Icons.message),
       onPressed: () {
        Map<String, dynamic> msg = { 'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'};
        socketService.socket.emit('mensaje', msg );
       },
     ),
   );
  }
}