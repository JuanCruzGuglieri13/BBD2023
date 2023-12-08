use('supplies')
db.sales.findOne()

use('supplies')
db.storeObjectives.findOne()

/**
 * Buscar las ventas realizadas en "London", 
 * "Austin" o "San Diego"; a un customer con
 *  edad mayor-igual a 18 años que tengan productos
 *  que hayan salido al menos 1000 y estén etiquetados
 *  (tags) como de tipo "school" o "kids" (pueden tener más
 *  etiquetas).
Mostrar el id de la venta con el nombre "sale", la fecha
 (“saleDate"), el storeLocation, y el "email del cliente.
  No mostrar resultados anidados. 
 */

use('supplies')
db.sales.aggregate([
    {
        $match: {
            $and: [
                {
                    $or: [
                        { "storeLocation": { $eq: "London" } },
                        { "storeLocation": { $eq: "Austin" } },
                        { "storeLocation": { $eq: "San Diego" } }
                    ]
                },
                { "customer.age": { $gte: 18 } },
                {
                    "items": {
                        $elemMatch: {
                            $and: [
                                { "price": { $gte: 1000.0 } },
                                {
                                    $or: [
                                        { "tags": { $eq: "school" } },
                                        { "tags": { $eq: "kids" } }
                                    ]
                                }
                            ]
                        }
                    }
                }
            ]
        }
    }, {
        $project: {
            "_id": 0,
            "sale": { $toString: "$_id" },
            "sale Date": { $dateToString: { format: "%Y-%m-%d", date: "$saleDate" } },
            "storeLocation": 1,
            "customer email": "$customer.email"
        }
    }
])


/**2
 * Buscar las ventas de las tiendas localizadas en Seattle,
 *  donde el método de compra sea ‘In store’ o ‘Phone’ y
 *  se hayan realizado entre 1 de febrero de 2014 y 31 de
 *  enero de 2015 (ambas fechas inclusive). Listar el email
 *  y la satisfacción del cliente, y el monto total facturado,
 *  donde el monto de cada item se calcula como 'price * quantity'.
 *  Mostrar el resultado ordenados por satisfacción (descendente),
 *  frente a empate de satisfacción ordenar por email (alfabético). 
 */

use('supplies')
db.sales.aggregate([
    {
        $match: {
            $and: [
                { "storeLocation": { $eq: "Seattle" } },
                {
                    $or: [
                        { "purchaseMethod": { $eq: "In store" } },
                        { "purchaseMethod": { $eq: "Phone" } },
                    ]
                }, {
                    "saleDate": {
                        $gte: new Date("2014-02-01T00:00:00.000Z")
                    }
                }, {
                    "saleDate": {
                        $lte: new Date("2015-01-31T23:59:59.999Z")
                    }
                }
            ]
        }
    }, {
        $unwind: "$items"
    }, {
        $group: {
            _id: "$_id",
            customer_email: { $first: "$customer.email" },
            satisfaccion: { $first: "$customer.satisfaction" },
            monto_total: {
                $sum: { $multiply: ["$items.price", "$items.quantity"] }
            }
        }
    },
    {
        $project: {
            "_id": 0,
            "customer_email": 1,
            "satisfaccion": 1,
            "monto_total": { $toString: "$monto_total" }
        }
    }, {
        $sort: {
            satisfaccion: -1,
            customer_email: 1
        }
    }
])


/**
 * 3)Crear la vista salesInvoiced que calcula el monto mínimo, 
 * monto máximo, monto total y monto promedio facturado por año
 *  y mes.  Mostrar el resultado en orden cronológico. 
 * No se debe mostrar campos anidados en el resultado.
 */


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

/**
 * 4)Mostrar el storeLocation, la venta promedio de ese local,
 *  el objetivo a cumplir de ventas (dentro de la colección 
 * storeObjectives) y la diferencia entre el promedio y el
 *  objetivo de todos los locales.
 */

use('supplies')
db.sales.findOne()
use('supplies')
db.storeObjectives.findOne()


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

/**
 * 5)Especificar reglas de validación en la colección sales utilizando JSON Schema. 
    a)Las reglas se deben aplicar sobre los campos: saleDate, storeLocation, purchaseMethod,
     y  customer ( y todos sus campos anidados ). Inferir los tipos y otras restricciones que
      considere adecuados para especificar las reglas a partir de los documentos de la colección. 
    b)Para testear las reglas de validación crear un caso de 
    falla en la regla de validación y un caso de éxito 
    (Indicar si es caso de falla o éxito)

 */
use('supplies')
db.sales.find()

use('supplies')
db.runCommand({
    collMod: "sales",
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["SaleDate", "storeLocation", "purchaseMethod", "customer"],
            properties: {
                SaleDate: { bsonType: "date" },
                storeLocation: {
                    enum: ["Denver", "London", "New York",
                        "Austin", "San Diego", "Seattle"]
                },
                purchaseMethod: {
                    enum: ["Online", "Phone", "In store"],
                },
                customer: {
                    bsonType: "object",
                    properties: {
                        gender: {
                            enum: ["M", "F"]
                        },
                        age: { bsonType: "int" },
                        email: {
                            bsonType: "string",
                        },
                        satisfaction: {
                            bsonType: "int",
                            maximum: 10,
                            minimum: 1
                        }
                    }
                }
            }
        }
    }
})

use('supplies')
db.getCollectionInfos({ "name": "sales" })

/*escenario de correcto*/
use('supplies')
db.sales.insert({
    "SaleDate": new Date(),
    "storeLocation": "Denver",
    "purchaseMethod": "Online",
    "customer": {
        "gender": "M",
        "age": 20,
        "email": "maria44@gmail.com",
        "satisfaction": 6
    }
})

/*escenario de fallla el purchaseMethod es invalido*/
use('supplies')
db.sales.insert({
    "SaleDate": new Date(),
    "storeLocation": "Denver",
    "purchaseMethod": "Door to door",
    "customer": {
        "gender": "M",
        "age": 20,
        "email": "maria44@gmail.com",
        "satisfaction": 6
    }
})