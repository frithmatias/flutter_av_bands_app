// ignore_for_file: avoid_print

import 'dart:io';

import 'package:bands_app/models/band.dart';
import 'package:bands_app/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [ 
    // Band(id: '1', name: 'Metallica', votes: 3),
    // Band(id: '2', name: 'Stratovarius', votes: 5),
    // Band(id: '3', name: 'Helloween', votes: 4),
    // Band(id: '4', name: 'Iron Maiden', votes: 7),
  ];
  


  @override
  void initState() { 
    
    // Pongo el listener en el initState, porque si lo pongo en el build para cuando el widget se termina de dibujar
    // el mensaje 'bands-list' que me envía el backend ya llego.

    final socketService = Provider.of<SocketService>(context, listen: false); 
    // listen: false -> no necesito redibujar nada, porque estoy en el initState, usualmente en el InitState no 
    // necesito redibujar nada en el widget
    socketService.socket.on('bands-list', (payload) => {
      print('Se recibió bands-list: $payload'),
      // necesito pasar por map a payload, pero para hacer eso necesito heredar sus metodos casteandolo a List.
      // pasando por map cada una de las bandas dentro de la lista payload, puedo pasarla luego por el factory 
      // constructor para convertirla en una banda para dart.
      bands = (payload as List).map((band) => Band.fromMap(band)).toList(), // convierto el iterable a lista
      setState((){})
    });
    super.initState();
  }

  // Elimino el listener sobre la lista de bandas
  @override
  void dispose() { 
    final socketService = Provider.of<SocketService>(context, listen: false); 
    socketService.socket.off('bands-list');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar( 
        title: const Text('BandName', style: TextStyle( color: Colors.black87)),
        actions: [ 
          Container(  
            margin: const EdgeInsets.only( right: 10 ),
            child: socketService.serverStatus == ServerStatus.onLine ?  Icon(Icons.bolt, color: Colors.blue[300]) : Icon(Icons.offline_bolt, color: Colors.red[300]), 
          )
        ],
                

        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _charts(),
          Expanded( // Necesito el expanded porque ListView.builder no sabe cuanto espacio deberá ocupar
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) {
                return _bandTile(bands[index], socketService);
              }
            ),
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(  
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  //CTRL+. > Extract Method
  // ListTile _bandTile(Band band) {
  Widget _bandTile(Band band, SocketService socketService) {
    return Dismissible(
      key: Key(band.id), // id único
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) => {
        socketService.emit('delete-band', band.id)
      },
      background: Container( 
        padding: const EdgeInsets.only( left: 8),
        color: Colors.indigo,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white))),
      ),
      child: ListTile(
        leading: CircleAvatar(  
          child: Text( band.name.substring(0,2)),
          backgroundColor: Colors.blue[100]
        ), 
        title: Text( band.name), 
        trailing: Text( band.votes.toString(), style: const TextStyle( fontSize: 20)),
        onTap: (){
          print(band.id);
          socketService.emit('vote-band', band.id);
        },
      ),
    );
  }
      

  addNewBand(){
    // El dialogo de material en IOS no se muestra como si fuera nativo por eso 
    // si la aplicación corre en IOS voy a mostrar showCupertinoDialog

    final textController = TextEditingController();
    if(!Platform.isAndroid){
    // ANDROID
      return showDialog(
        // en un StatefullWidget el context ya esta de forma global
        context: context, 
        // cuando hay un builder significa que hay que regresar un widget
        builder: ( context ) { 
          return AlertDialog(  
            title: const Text('New band name:'), 
            content: TextField(  
            controller: textController
            ),
            actions: [  
              MaterialButton(  
                child: const Text('Add'),
                elevation: 1,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text)
              )
            ],
          );
        }
      );
    }

    // IOS
    showCupertinoDialog(
      context: context, 
      builder: (_) {
        return CupertinoAlertDialog(  
          title: const Text('New band name:'),
          content: CupertinoTextField(  
            controller: textController
          ),
          actions: <Widget> [ 
            CupertinoDialogAction(  
              isDefaultAction: true,
              child: const Text('Add'), 
              onPressed: () => addBandToList( textController.text ),
            ),
            // El CupertinoDialog esta fuera del context y no se cierra con addBandToList 
            // por lo tanto agrego un nuevo Action para cerrarlo
            CupertinoDialogAction(  
              isDefaultAction: true,
              child: const Text('Dismiss'), 
              onPressed: () => Navigator.pop( context ),
            )
          ]
        );
      }
    );
  }


  void addBandToList( String name){
    if(name.length > 1){
      
      // bands.add( Band( id: DateTime.now().toString(), name: name, votes: 0));
      // setState((){}); // StatefulWidget > setState para actualizar el Widget
      // ya no voy a definir mi lista desde flutter sino que me lo va a enviar el backend.
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', name);

    }
    Navigator.pop(context);
  }


  Widget _charts(){
    Map<String, double> dataMap = <String, double>{};
    
    final List<Color> colorList = [
      Colors.blue.shade300,
      Colors.red.shade300,
      Colors.green.shade300,
      Colors.yellow.shade300
    ];

    if (bands.isEmpty) return Container();
    for (var band in bands){
      print(band.name);
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }
    print('returning');
    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 1800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 16,
      centerText: "Heavy Metal",
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 0,
        chartValueBackgroundColor: Colors.white54
      ),
    ); 
  }

}
