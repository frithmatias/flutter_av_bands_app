
class Band {
  
  String id;
  String name;
  int votes;
  
  Band({
    required this.id,
    required this.name,
    required this.votes
  });


  // 3. CREO UN CONSTRUCTOR FACTORY (DEVUELVE LA INSTANCIA PREVIA _singleton O LA CREA) 

  // cuando decimos que un constructor es de tipo FACTORY estamos diciendo que el constructor debe 
  // tener un RETURN, es decir debe retornar una instancia nueva o ya existente de la clase pero NUNCA 
  // una instancia de la clase en si misma, sino una instancia PREVIAMENTE creada o una nueva creada a 
  // partir de OTROS constructores.

  factory Band.fromMap( Map<String, dynamic> obj ){
    return Band(
      id: obj['id'],
      name: obj['name'],
      votes: obj['votes']
    );
  }

}