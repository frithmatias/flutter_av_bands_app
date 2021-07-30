// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as _io;

enum ServerStatus { onLine, offLine, connecting }

class SocketService with ChangeNotifier {
  // ChangeNotifier me va a ayudar a decirle al Provider cuando debe actualizar la UI
  // o algun widget en particular

  ServerStatus _serverStatus = ServerStatus.connecting;
  ServerStatus get serverStatus => _serverStatus;

  late _io.Socket _socket;
  _io.Socket get socket => _socket; // Getter para llamar la instancia socket desde afuera
  Function get emit => _socket.emit; // no es totalmente necesario pero podemos llamar a este getter para emitir

  // Constructor
  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    print('Inicializando la conexión por sockets...');
    _socket = _io.io('http://192.168.1.3:3000',
        _io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build());

    _socket.on('connect', (_) {
      print('connected');
      _serverStatus = ServerStatus.onLine;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      print('disconnected');
      _serverStatus = ServerStatus.offLine;
      notifyListeners();
    });

    // socket.on('mensaje', ( payload ) {
    //   print('Nuevo mensaje:' + payload.toString());
    //   print('nombre: ' + payload['nombre']);
    //   print('mensaje: ' + payload['mensaje']);
    // });



  }
}
