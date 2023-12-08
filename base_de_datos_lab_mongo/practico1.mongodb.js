
// 1)
/* Insertar 5 nuevos usuarios en la colección users. Para cada nuevo usuario
 creado, insertar al menos un comentario realizado por el usuario en la 
 colección comments.*/

use("mflix")
db.users.insertMany([
    {"name":"Juan Monaco","email":"JuanM@mail.com","password":"123456"},
    {"name":"Maria Paris","email":"MariaP@mail.com","password":"holahola"},
    {"name":"Lucas Roma","email":"LucasR@mail.com","password":"cafecafe"},
    {"name":"Sofia Perez","email":"SofiaP@mail.com","password":"cafecoca"},
    {"name":"Martin Martinez","email":"MartinMartin@mail.com","password":"agua1234"}
])

use("mflix")
db.comments.insertMany([
    {"name": "Juan Monaco",
    "email": "JuanM@mail.com",
    "movie_id": {
      "$oid": "573a1390f29313caabcd41fa"
    },
    "text": "muy buena peli.",
    "date": {
      "$date": new Date()
    }
   },
   {"name": "Maria Paris",
    "email": "MariaP@mail.com",
    "movie_id": {
      "$oid": "573a1390f29313caabcd41fa"
    },
    "text": "muy mala peli.",
    "date": {
      "$date": new Date()
    }
   },
   {"name": "Lucas Roma",
    "email": "LucasR@mail.com",
    "movie_id": {
      "$oid": "573a1390f29313caabcd41fa"
    },
    "text": "muy regular peli.",
    "date": {
      "$date": new Date()
    }
   },
   {"name": "Sofia Perez",
   "email": "SofiaP@mail.com",
   "movie_id": {
     "$oid": "573a1390f29313caabcd41fa"
   },
   "text": "buena peli.",
   "date": {
     "$date": new Date()
   }
  },
  {"name": "Martin Martinez",
  "email": "MartinMartin@mail.com",
  "movie_id": {
    "$oid": "573a1390f29313caabcd41fa"
  },
  "text": "peli.",
  "date": {
    "$date": new Date()
  }
 }
])


//2 
/* Listar el título, año, actores (cast), directores y rating de las 10 
 películas con mayor rating (“imdb.rating”) de la década del 90. ¿Cuál es el 
 valor del rating de la película que tiene mayor rating? (Hint: Chequear que 
 el valor de “imdb.rating” sea de tipo “double”).*/



use("mflix")
db.movies.find(
    {$and:[{"year":{$gte:1990}}, {"year":{$lt:2000}}, {"imdb.rating":{$ne:""}}]},
    {"title":1,"year":1,"cast":1,"directors":1,"imdb.rating":1}
    ).sort(
        {"imdb.rating":-1}
    ).limit(
        10
    )
    
//3 
/* Listar el nombre, email, texto y fecha de los comentarios que la película 
 con id (movie_id) ObjectId("573a1399f29313caabcee886") recibió entre los años
 2014 y 2016 inclusive. Listar ordenados por fecha. Escribir una nueva 
 consulta (modificando la anterior) para responder ¿Cuántos comentarios 
 recibió?*/ 
use("mflix")
db.comments.find()

use("mflix")
db.comments.find(
  {$and:[{"movie_id": {$eq: ObjectId("573a1399f29313caabcee886")}},  
  {"date": {$gte: new Date("2014-01-01T00:00:00.000Z")}},
  {"date": {$lte: new Date("2016-12-31T23:59:59.999Z")}}]},
  {"name":1,"email":1,"text":1,"date":1}
  ).sort(
    {"date":1}
  )

use("mflix")
db.comments.find(
  {$and:[{"movie_id": {$eq:ObjectId("573a1399f29313caabcee886")}},  
  {"date": {$gte: new Date("2014-01-01T00:00:00.000Z")}},
  {"date": {$lte: new Date("2016-12-31T23:59:59.999Z")}}]},
  {"name":1,"email":1,"text":1,"date":1}
  ).count()

//4
/*Listar el nombre, id de la película, texto y fecha de los 3 comentarios más 
  recientes realizados por el usuario con email patricia_good@fakegmail.com. 
*/

use("mflix")
db.comments.find()

use("mflix")
db.comments.find(
  {"email": {$eq: "patricia_good@fakegmail.com"}},
  {"name":1, "movie_id":1, "text":1, "date":1}
).sort(
  {"date":-1}
).limit(3)

//5
/*Listar el título, idiomas (languages), géneros, fecha de lanzamiento 
  (released) y número de votos (“imdb.votes”) de las películas de géneros Drama 
  y Action (la película puede tener otros géneros adicionales), que solo están
  disponibles en un único idioma y por último tengan un rating (“imdb.rating”) 
  mayor a 9 o bien tengan una duración (runtime) de al menos 180 minutos. 
  Listar ordenados por fecha de lanzamiento y número de votos.
*/

use("mflix")
db.movies.find()

use("mflix") 
db.movies.find( 
  {$and: [
    {"genres": {$in: ["Drama", "Action"]}},
    {"languages": {$size: 1}},
    {$or: [{"imbd.rating": {$gt: 9}}, {"runtime": {$gte: 180}}]}
  ]},
  {"title":1, "languages":1, "genres":1, "released":1, "imdb.votes":1}
).sort({"released":1},{"imdb.votes":-1})

//{$or: [{"genres": {$eq: "Action"}},{"genres": {$eq: "Drama"}}]}

//6
/*Listar el id del teatro (theaterId), estado (“location.address.state”), 
  ciudad (“location.address.city”), y coordenadas (“location.geo.coordinates”) 
  de los teatros que se encuentran en algunos de los estados "CA", "NY", "TX" 
  y el nombre de la ciudades comienza con una ‘F’. Listar ordenados por estado 
  y ciudad.
*/

use("mflix")
db.theaters.find()

use("mflix")
db.theaters.find(
  {$and: [
    {"location.address.state": {$in: ["CA", "NY", "TX"]}},
    {"location.address.city": {$regex: /^F/}}
  ]},
  {"theaterId":1, "location.address.state":1, "location.address.city":1, "location.geo.coordinates":1}
).sort({"location.address.state":1},{"location.address.city":1})

//7
/*Actualizar los valores de los campos texto (text) y fecha (date) del 
  comentario cuyo id es ObjectId("5b72236520a3277c015b3b73") a "mi mejor
  comentario" y fecha actual respectivamente.
*/

use("mflix")
db.comments.updateMany(
  {"_id": ObjectId("5b72236520a3277c015b3b73")},
  {$set: {"text": "mi mejor comentario", "date": new Date()}}
)
  
//8
/*Actualizar el valor de la contraseña del usuario cuyo email es 
  joel.macdonel@fakegmail.com a "some password". La misma consulta debe poder
  insertar un nuevo usuario en caso que el usuario no exista. Ejecute la 
  consulta dos veces. ¿Qué operación se realiza en cada caso? 
  (Hint: usar upserts). 
*/

use("mflix")
db.users.update(
  {"email": "joel.macdonel@fakegmail.com"},
  {$set: {"password": "some password"}},
  {upsert: true}
)

/*
Primera ejecucion:
  {   
    "acknowledged": true,
    "insertedId": {
      "$oid": "653d82796c55009387bf133e"
    },
    "matchedCount": 0,
    "modifiedCount": 0,
    "upsertedCount": 1
  }
Segunda ejecucion:
  {
    "acknowledged": true,
    "insertedId": null,
    "matchedCount": 1,
    "modifiedCount": 0,
    "upsertedCount": 0
  }
Por lo tanto, la primera ejecucion añade el documento porque no lo encontro, y
en la segunda ejecución lo actualiza porque hay un documento que coincide.
*/

//9
/*Remover todos los comentarios realizados por el usuario cuyo email es 
  victor_patel@fakegmail.com durante el año 1980.
 */

use("mflix")
db.comments.deleteMany(
  {$and: [
    {"email": "victor_patel@fakegmail.com"},
    {"date": {$gte: ISODate("1980-01-01")}},
    {"date": {$lte: ISODate("1980-12-31")}}
  ]}
)

/* RESULT:
{
  "acknowledged": true,
  "deletedCount": 21
}
*/

// 2DA PARTE

//10
/*Listar el id del restaurante (restaurant_id) y las calificaciones de los
  restaurantes donde al menos una de sus calificaciones haya sido realizada 
  entre 2014 y 2015 inclusive, y que tenga una puntuación (score) mayor a 70 y 
  menor o igual a 90.
*/

use("restaurantdb")
db.restaurants.find()

use("restaurantdb")
db.restaurants.find(
  {grades: 
    {$elemMatch : {
      date : {$gte: ISODate("2014-01-01"), $lte: ISODate("2015-12-31")},
      score : {$gt: 70, $lte: 90}
    }
  }},
  {"_id":1, "grades.score":1}
)

//11
/*Agregar dos nuevas calificaciones al restaurante cuyo id es "50018608". A 
  continuación se especifican las calificaciones a agregar en una sola 
  consulta.  

{
	"date" : ISODate("2019-10-10T00:00:00Z"),
	"grade" : "A",
	"score" : 18
}

{
	"date" : ISODate("2020-02-25T00:00:00Z"),
	"grade" : "A",
	"score" : 21
}
*/

use("restaurantdb")
db.restaurants.update(
  {"restaurant_id": '50018608'},
  {$addToSet : 
    {grades: [
      {
        "date" : ISODate("2019-10-10T00:00:00Z"),
        "grade" : "A",
        "score" : 18
      }, 
      {
        "date" : ISODate("2020-02-25T00:00:00Z"),
        "grade" : "A",
        "score" : 21
      }]
    }
  }
)

