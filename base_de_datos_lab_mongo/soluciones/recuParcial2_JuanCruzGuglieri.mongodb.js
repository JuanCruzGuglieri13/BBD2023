// Recuperatorio PARCIAL 2 BDD
// Juan Cruz Guglieri

//1)
/*Identificar los tres géneros con el tiempo promedio de duración más alto de 
sus películas. Incluir el nombre del género y el tiempo promedio, y ordenar el 
resultado según el tiempo promedio en orden descendente. Si una película 
pertenece a varios géneros, contar esa película para cada uno de ellos.*/

use("mflix")
db.movies.aggregate(
    { $unwind: "$genres" },
    { $group: {
        _id: "$genres",
        avg_time: { $avg: "$runtime" }
    }},
    { $project: {
        _id: 0,
        genre: {$toString: "$_id"},
        avg_time: 1
    }},
    { $sort: {avg_time:-1}},
    { $limit: 3 }
)

//2)
/*Calcular el número promedio de caracteres en los títulos de las películas 
para cada género. Incluye el nombre del género y el número promedio de 
caracteres, y ordena el resultado en orden descendente según este número. Si 
una película pertenece a varios géneros, contar esa película para cada uno de ellos.*/

use("mflix")
db.movies.aggregate(
    { $unwind: "$genres" },
    { $group: {
        _id: "$genres",
        avg_chars: { $avg: { $strLenCP: { $toString: "$title"} } }
    }},
    { $project: {
        _id: 0,
        genre: { $toString: "$_id" },
        avg_chars: 1
    }},
    { $sort: { avg_chars:-1 } }
)


//3)
/*Identificar a los usuarios que tienen un gusto diverso en películas. 
Considerar la diversidad como la cantidad de películas de años diferentes a las
que un usuario ha comentado. Es decir, si un usuario tiene comentarios en 
Titanic (1997), Forrest Gump (1994) y Pulp Fiction (1994), la diversidad es 2 
porque hay exactamente dos años distintos entre todas las películas. Incluir el 
correo electrónico y la cantidad de años únicos que ha comentado. Ordena el 
resultado por la cantidad de años únicos descendentemente y por email alfabéticamente.*/

use("mflix")
db.comments.aggregate(
    { $lookup: {
        from: "movies",
        localField: "movie_id",
        foreignField: "_id",
        as: "movie"
    }},
    { $group: {
        _id: "$email",
        movie_set: { $addToSet: "$movie.year"}
    }},
    { $project: {
        _id: 0,
        email: "$_id",
        diversidad: { $size: "$movie_set"},
    }},
    { $sort: {
        "diversidad": -1,
        "email": 1
    }}
)

//4)
/* Especificar reglas de validación en la colección theaters utilizando JSON Schema. 
Las reglas se deben aplicar sobre los campos: theaterId y location, (y todos 
sus campos anidados). Inferir los tipos y otras restricciones que considere 
adecuados para especificar las reglas a partir de los documentos de la 
colección. 
Para testear las reglas de validación crear un caso de falla en la regla de 
validación y un caso de éxito (Indicar si es caso de falla o éxito)*/

use("mflix")
db.runCommand({
    "collMod": "theaters",
    "validator": {
        $jsonSchema: {
            bsonType: "object",
            required: [
                "theaterId",
                "location"
            ],
            properties: {
                theaterId: {
                    bsonType: "int",
                    description: "theaterId is a required int",
                },
                location: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        required: [
                            "address",
                            "geo"
                        ],
                        additionalProperties: false,
                        description: "location is a required array",
                        properties: {
                            address: {
                                bsonType: "array",
                                items: {
                                    bsonType: "object",
                                    required: [
                                        "street1",
                                        "city",
                                        "state",
                                        "zipcode"
                                    ],
                                    additionalProperties: false,
                                    description: "address is a required array",
                                    properties: {
                                        street1: {
                                            bsonType: "string",
                                            description: "street1 is a required string"
                                        },
                                        city: {
                                            bsonType: "string",
                                            description: "city is a required string"
                                        },
                                        state: {
                                            bsonType: "string",
                                            maxLength: 2,
                                            description: "state is a required string, max 2 chars"
                                        },
                                        zipcode: {
                                            bsonType: "string",
                                            maxLength: 5,
                                            description: "zipcode is a required string, max 5 chars"
                                        }
                                    }
                                }
                            },
                            geo: {
                                bsonType: "array",
                                items: {
                                    bsonType: "object",
                                    required: [
                                        "type",
                                        "coordinates"
                                    ],
                                    additionalProperties: false,
                                    description: "geo is a required array",
                                    properties: {
                                        type: {
                                            enum: ["Point"],
                                            description: "type is a required enum of 1 element"
                                        },
                                        coordinates: {
                                            bsonType: ["double"],
                                            description: "coordinates is a required array of double"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
})

//Pasa la prueba
db.theaters.insertOne({
    theaterId: 1000,
    location: [{
      address: [{
        street1: "340 W Market",
        city: "Bloomington",
        state: "MN",
        zipcode: "55425"  
      }],
      geo: [{
      	type: "Point",
        coordinates: [
          -93.24565,
          44.85466
        ]
      }]
    }]
})

//No pasa la prueba
db.theaters.insertOne({
    theaterId: 1002,
    location: [{
      address: [{
        street1: "340 W Market",
        city: "Bloomington",
        state: "MN",
        zipcode: "55425"  
      }],
      geo: [{
      	type: "Corner", // acá no se cumple
        coordinates: [
          -93.24565,
          44.85466
        ]
      }]
    }]
})