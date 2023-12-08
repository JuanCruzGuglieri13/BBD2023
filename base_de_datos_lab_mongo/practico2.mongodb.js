//1
/*Cantidad de cines (theaters) por estado.*/

use("mflix");
db.theaters.aggregate({
  $group: {
    _id: "$location.address.state",
    total: { $count: {} },
  },
});

//2
/*Cantidad de estados con al menos dos cines (theaters) registrados.*/

use("mflix");
db.theaters.aggregate(
  {
    $group: {
      _id: "$location.address.state",
      count: {
        $count: {},
      },
    },
  },
  {
    $match: {
      count: { $gte: 2 },
    },
  },
  {
    $count: "NumOfStates",
  }
);

//3
/*Cantidad de películas dirigidas por "Louis Lumière". Se puede responder sin 
  pipeline de agregación, realizar ambas queries.*/

use("mflix");
db.movies
  .find({ directors: { $elemMatch: { $eq: "Louis Lumière" } } }, {})
  .count();

use("mflix");
db.movies.aggregate(
  { $match: { directors: "Louis Lumière" } },
  {
    $group: {
      _id: "",
      total_movies: { $count: {} },
    },
  }
);

//4
/*Cantidad de películas estrenadas en los años 50 (desde 1950 hasta 1959). Se 
  puede responder sin pipeline de agregación, realizar ambas queries.*/

use("mflix");
db.movies.find({ year: { $gte: 1950, $lte: 1959 } }, {}).count();

use("mflix");
db.movies.aggregate(
  { $match: { year: { $gte: 1950, $lte: 1959 } } },
  {
    $group: {
      _id: "",
      count: { $count: {} },
    },
  }
);

//5
/*Listar los 10 géneros con mayor cantidad de películas (tener en cuenta que 
  las películas pueden tener más de un género). Devolver el género y la 
  cantidad de películas. Hint: unwind puede ser de utilidad*/

use("mflix");
db.movies.aggregate(
  { $unwind: "$genres" },
  {
    $group: {
      _id: "$genres",
      movies_per_genre: { $count: {} },
    },
  },
  { $sort: { movies_per_genre: -1 } },
  { $limit: 10 }
);

//6
/*Top 10 de usuarios con mayor cantidad de comentarios, mostrando Nombre, 
  Email y Cantidad de Comentarios.*/

use("mflix");
db.comments.aggregate(
  {$group: {
    _id: {name: "$name", email: "$email"},
    total_comments: {$count: {}}
  }},
  {$sort: {"total_comments":-1}},
  {$limit: 10}
);

//7
/*Ratings de IMDB promedio, mínimo y máximo por año de las películas 
  estrenadas en los años 80 (desde 1980 hasta 1989), ordenados de mayor a 
  menor por promedio del año.*/

use("mflix")
db.movies.aggregate(
  {$match: {
    "year": {$gte: 1980, $lte: 1989},
    "imdb.rating": {$type: "number"}
  }},
  {$group: {
    _id: "$year",
    rating_prom: {$avg: "$imdb.rating"},
    rating_min: {$min: "$imdb.rating"},
    rating_max: {$max: "$imdb.rating"}
  }},
  {$sort: {"rating_prom":-1}}
)

//8
/*Título, año y cantidad de comentarios de las 10 películas con más 
  comentarios.*/

use("mflix")
db.movies.aggregate(
  {$lookup: {
    from: "comments",
    localField: "_id",
    foreignField: "movie_id",
    as: "comments_info"
  }},
  {$unwind: "$comments_info"},
  {$group: {
    _id: {title: "$title", year: "$year"},
    count_comments: {$count: {}}
  }},
  {$sort: {"count_comments":-1}},
  {$project: {
    "title":1, "year":1, "count_comments":1
  }},
  {$limit: 10}
)


/*Crear una vista con los 5 géneros con mayor cantidad de comentarios, junto con la cantidad de comentarios.*/

use("mflix")
db.movies.find()

use("mflix")
db.comments.aggregate(
  {
    $lookup: {
      from: "movies",
      localField: "movie_id",
      foreignField: "_id",
      as: "movie"
    }
  },
  {
    $unwind: "$movie"
  },
  {
    $group: {
      _id: "$movie.genres",
      tot_comments: {$sum: 1}
    }
  },
  {
    $unwind: "$_id"
  },    
  {
    $group: {
      _id: "$_id",
      total_comments: {$sum: "$tot_comments"}
    }
  },
  {
    $sort: { total_comments: -1 }
  },
  {
    $limit: 5
  }
)

/*Listar los actores (cast) que trabajaron en 2 o más películas dirigidas por "Jules Bass". Devolver el nombre de estos actores junto con la lista de películas (solo título y año) dirigidas por “Jules Bass” en las que trabajaron. 
Hint1: addToSet
Hint2: {'name.2': {$exists: true}} permite filtrar arrays con al menos 2 elementos, entender por qué.
Hint3: Puede que tu solución no use Hint1 ni Hint2 e igualmente sea correcta*/

use("mflix")
db.movies.find()

use("mflix")
db.movies.aggregate(
  {
    $match: {
      "directors": "Jules Bass" // Filtra por películas dirigidas por Jules Bass
    }
  },
  {
    $project: {
      "directors":1
    }
  }
)


/*Listar los usuarios que realizaron comentarios durante el mismo mes de lanzamiento de la película comentada, mostrando Nombre, Email, fecha del comentario, título de la película, fecha de lanzamiento. HINT: usar $lookup con multiple condiciones*/


use("mflix")
db.comments.aggregate(
  {
    $lookup: {
      from: "movies",
      let: { movieId: "$movie_id", commentDate: "$date" },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                { $eq: ["$_id", "$$movieId"] },
                { $expr: { $eq: [{ $month: "$release_date" }, { $month: "$$commentDate" }] } }
              ]
            }
          }
        },
        {
          $project: {
            _id: 1,
            title: 1,
            release_date: 1
          }
        }
      ],
      as: "movie_info"
    }
  },
  {
    $unwind: "$movie_info"
  },
  {
    $project: {
      _id: 0,
      name: 1,
      email: 1,
      comment_date: "$date",
      movie_title: "$movie_info.title",
      release_date: "$movie_info.release_date"
    }
  }
)

use("mflix")
db.users.find()

/*Listar el id y nombre de los restaurantes junto con su puntuación máxima, mínima y la suma total. Se puede asumir que el restaurant_id es único.
/*Resolver con $group y accumulators.
/*Resolver con expresiones sobre arreglos (por ejemplo, $sum) pero sin $group.
/*Resolver como en el punto b) pero usar $reduce para calcular la puntuación total.
/*Resolver con find.
/*Actualizar los datos de los restaurantes añadiendo dos campos nuevos. 
/*"average_score": con la puntuación promedio
/*"grade": con "A" si "average_score" está entre 0 y 13, 
/*  con "B" si "average_score" está entre 14 y 27 
/*  con "C" si "average_score" es mayor o igual a 28    
/*Se debe actualizar con una sola query.
/*HINT1. Se puede usar pipeline de agregación con la operación update
/*HINT2. El operador $switch o $cond pueden ser de ayuda.
*/
