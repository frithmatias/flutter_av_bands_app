import 'dart:io';

import 'package:bands_app/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [ 
    Band(id: '1', name: 'Metallica', votes: 3),
    Band(id: '2', name: 'Stratovarius', votes: 5),
    Band(id: '3', name: 'Helloween', votes: 4),
    Band(id: '4', name: 'Iron Maiden', votes: 7),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('BandName', style: TextStyle( color: Colors.black87)),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) {
          return _bandTile(bands[index]);
       }
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
  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id), // id único
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) => print(band.id),
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
        // onTap: (){},
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
      bands.add( Band( id: DateTime.now().toString(), name: name, votes: 0));
      setState((){}); // StatefulWidget > setState para actualizar el Widget
    }
    Navigator.pop(context);
  }
}