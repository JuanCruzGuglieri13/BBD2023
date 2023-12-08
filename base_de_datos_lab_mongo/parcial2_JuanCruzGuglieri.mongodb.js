//PARCIAL 2 BDD
// Juan Cruz Guglieri

//1
/* Buscar las ventas realizadas en "London", "Austin" o "San Diego"; a un 
customer con edad mayor-igual a 18 años que tengan productos que hayan salido
al menos 1000 y estén etiquetados (tags) como de tipo "school" o "kids" (pueden
tener más etiquetas).
Mostrar el id de la venta con el nombre "sale", la fecha (“saleDate"), el 
storeLocation, y el "email del cliente. No mostrar resultados anidados.*/

use("supplies")
db.sales.findOne()

use("supplies")
db.sales.aggregate(
	{ $match: {
		"storeLocation": { $in : ["London", "Austin", "San Diego"]},
		"customer.age" : {$gte: 18},
		"items" : { $elemMatch: {
			"price": {$gte: 1000.0},
			"tags": {$in: ["school", "kids"]}
		}} 
	}},
	{ $project:	{
		"_id": 0,
		"sale": { $toString: "$_id"},
		"saleDate": { $dateToString: { format:  "%Y-%m-%d", date: "$saleDate" }},
		"storeLocation": 1,
		"customer email": "$customer.email"
	}}
)



use("supplies")
db.sales.find()

use("supplies")
db.sales.aggregate(
    { $match: {
		"storeLocation": {$in: ["London", "Austin", "San Diego"]},
    	"customer.age": {$gte: 18},
		"items": {
			$elemMatch: {
				$and: [
					{"price" : { $gte: 1000.0 }}, 
					{"tags": {$in : ["school", "kids"]}}
				]
			}
		}
	}},
    { $project: { 
		"_id": 0,
		"sale": { $toString: "$_id"},
        "saleDate": { $dateToString: { format:  "%Y-%m-%d", date: "$saleDate" }},
        "storeLocation": 1,
        "customer email": "$customer.email",
    }}
)
  

//2
/*Buscar las ventas de las tiendas localizadas en Seattle, donde el método de 
compra sea ‘In store’ o ‘Phone’ y se hayan realizado entre 1 de febrero de 2014
y 31 de enero de 2015 (ambas fechas inclusive). Listar el email y la 
satisfacción del cliente, y el monto total facturado, donde el monto de cada 
item se calcula como 'price * quantity'. Mostrar el resultado ordenados por 
satisfacción (descendente), frente a empate de satisfacción ordenar por email 
(alfabético).*/


use("supplies")
db.sales.aggregate(
	{ $match: {
		"storeLocation": "Seattle",
		"purchaseMethod": {$in: ["In store", "Phone"]},
		"saleDate": {$gte: ISODate("2014-02-01"), $lte: ISODate("2015-01-31")}
	}},
	{ $unwind: "$items"},
	{ $group: {
		_id: "$_id",
		customer_email: { $first: "$customer.email"},
		satisfaction: {$first: "$customer.satisfaction"},
		total_price: {$sum: {$multiply: ["$items.price", "$items.quantity"]}}
	}},
	{ $project: {
		"_id": 0,
		"customer_email": 1,
		"satisfaction": 1,
		"total_price": {$toString: "total_price"},
	}},
	{ $sort: {
		satisfaction: -1,
		customer_email: 1
	}}
)

//3
/*Crear la vista salesInvoiced que calcula el monto mínimo, monto máximo, monto 
total y monto promedio facturado por año y mes.  Mostrar el resultado en orden 
cronológico. No se debe mostrar campos anidados en el resultado.*/

use('supplies')
db.sales.findOne()


use('supplies')
db.sales.aggregate(
	{ $unwind: "$items" },
	{ $group: {
		_id: "$_id",
		date: { $first: "$saleDate"},
		total: { $sum: { $multiply: ["$items.price", "$items.quantity"] } }
	}},
	{ $group: {
		_id: { $dateToString: { format: "%Y-%m", date: "$date"}},
		monto_min: { $min: "$total" },
		monto_max: { $max: "$total" },
		monto_tot: { $sum: "$total" },
		monto_avg: { $avg: "$total" },
	}},
	{ $project: {
		_id: 0,
		fecha: "$_id",
		monto_minimo: { $toString: "$monto_min" },
		monto_maximo: { $toString: "$monto_max" },
		monto_total: { $toString: "$monto_tot" },
		monto_promedio: { $toString: "$monto_avg" }
	}},
	{ $sort: {"fecha": 1}}
)


use('supplies')
db.createView("salesInvoiced", "sales", [
    {
        $unwind: "$items"
    }, {
        $group: {
            _id: "$_id",
            total_venta: {
                $sum: { $multiply: ["$items.price", "$items.quantity"] }
            },
            saleDate: { $first: "$saleDate" }
        }
    },
    {
        $group: {
            _id: { $dateToString: { format: "%Y-%m", date: "$saleDate" } },
            monto_maximo: {
                $max: "$total_venta"
            },
            monto_minimo: {
                $min: "$total_venta"
            },
            monto_total: {
                $sum: "$total_venta"
            },
            monto_promedio: {
                $avg: "$total_venta"
            },

        }
    }, {
        $project: {
            "_id": 0,
            "Año_mes": { $toString: "$_id" },
            "monto maximo": { $toString: "$monto_maximo" },
            "monto minimo": { $toString: "$monto_minimo" },
            "monto total": { $toString: "$monto_total" },
            "monto promedio": { $toString: "$monto_promedio" },
        }
    }, {
        $sort: {
            "Año_mes": 1
        }
    }
])

use('supplies')
db.salesInvoiced.find()

/*Mostrar el storeLocation, la venta promedio de ese local, el objetivo a 
cumplir de ventas (dentro de la colección storeObjectives) y la diferencia 
entre el promedio y el objetivo de todos los locales.*/

use('supplies')
db.sales.aggregate([
    {
        $unwind: "$items"
    }, {
        $group: {
            _id: "$_id",
            storeLocation: { $first: "$storeLocation" },
            monto_total: {
                $sum: { $multiply: ["$items.price", "$items.quantity"] }
            }
        }
    }, {
        $group: {
            _id: "$storeLocation",
            venta_promedio: {
                $avg: "$monto_total"
            }
        }
    },
    {
        $lookup: {
            from: "storeObjectives",
            localField: "_id",
            foreignField: "_id",
            as: "storeObjective"
        }
    }, {
        $unwind: "$storeObjective"
    }, {
        $project: {
            "_id": 0,
            "storeLocation": "$_id",
            "venta promedio": {
                $toDouble: "$venta_promedio"
            },
            "storeObjective": "$storeObjective.objective",
            "dif_prom": { $subtract: ["$storeObjective.objective", { $toDouble: "$venta_promedio" }] }
        }
    }
])

//5
/*Especificar reglas de validación en la colección sales utilizando JSON Schema. 
Las reglas se deben aplicar sobre los campos: saleDate, storeLocation, 
purchaseMethod, y  customer ( y todos sus campos anidados ). Inferir los tipos
y otras restricciones que considere adecuados para especificar las reglas a 
partir de los documentos de la colección. 
Para testear las reglas de validación crear un caso de falla en la regla de 
validación y un caso de éxito (Indicar si es caso de falla o éxito)
*/

db.runCommand({
	"collMod": "sales",
	"validator": {
		$jsonSchema: {
			bsonType: "object",
			required: [
				"saleDate",
				"storeLocation",
				"purchaseMethod",
				"customer"
			],
			properties: {
				saleDate: {
					bsonType: "date",
					description: "saleDate is a required date"
				},
				storeLocation: {
					enum: ["Denver", "London", "New York",
                        "Austin", "San Diego", "Seattle"],
					description: "storeLocation is a required string"
				},
				purchaseMethod: {
					enum: ["Online", "Phone", "In store"],
					description: "purchaseMethod is a required enum of 3 values"
				},
				customer: {
					bsonType: "array",
					minItems: 1,
					items: {
						bsonType: "object",
						required: [
							"gender",
							"age",
							"email",
							"satisfaction"
						],
						additionalProperties: false,
						description: "items must have the 4 stated fields.",
						properties: {
							gender: {
								enum: ["M", "F", "X"],
								description: "gender is a required enum of 3 elems"
							},
							age: {
								bsonType: "int",
								minimum: 18,
								description: "age is a required int above 18"
							},
							email: {
								bsonType: "string",
								pattern: "^(.*)@(.*)",
								description: "email is a required string with pattern"
							},
							satisfaction: {
								bsonType: "int",
								minimum: 1,
								maximum: 5,
								description: "satisfaction is a required int between 1-5"
							}
						}
					}
				}
			}
		}
	}
})

use('supplies')
db.getCollectionInfos({ "name": "sales" })


//Caso de falla en validacion

db.sales.insertOne({
	saleDate: new Date(),
	storeLocation: "Obispo Salguero",
	purchaseMethod: "Online",
	customer: [{
		gender: "M",
		age: 15,
		email: "aaa@a.com",
		satisfaction: 2,
		nationality: "Moldavia"
	}]
})

/*Acá falla en customer, age no debe ser menor a 18 y por otro lado tambien 
falla en additionalProperties, donde establece que no puede tener mas campos
que los establecidos
*/

//Caso de exito en validacion

db.sales.insertOne({
	saleDate: new Date(),
	storeLocation: "Obispo Oro",
	purchaseMethod: "Phone",
	customer: [{
		gender: "F",
		age: 30,
		email: "bbb@b.com",
		satisfaction: 5
	}]
})