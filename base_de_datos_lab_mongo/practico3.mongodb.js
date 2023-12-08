/*Especificar en la colección users las siguientes reglas de validación: El 
campo name (requerido) debe ser un string con un máximo de 30 caracteres, 
email (requerido) debe ser un string que matchee con la expresión regular: 
"^(.*)@(.*)\\.(.{2,4})$" , password (requerido) debe ser un string con al menos
50 caracteres.*/

db.runCommand({
    collMod: "users",
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["name", "email", "password"],
        properties: {
          name: {
            bsonType: "string",
            maxLength: 30,
            description: "Name must be a string with a maximum of 30 characters"
          },
          email: {
            bsonType: "string",
            pattern: "^(.*)@(.*)\\.(.{2,4})$",
            description: "Email must match the specified pattern"
          },
          password: {
            bsonType: "string",
            minLength: 50,
            description: "Password must be a string with a minimum of 50 characters"
          }
        }
      }
    },
    validationLevel: "moderate",
    validationAction: "error"
  })

/*Obtener metadata de la colección users que garantice que las reglas de 
validación fueron correctamente aplicadas.*/

db.users.getCollectionInfos()

//$ se utiliza como un operador o para referenciar campos, mientras que $$ se 
//usa para referenciar variables definidas en el contexto de agregación


/*Especificar en la colección theaters las siguientes reglas de validación: El campo theaterId (requerido) debe ser un int y location (requerido) debe ser un object con:
un campo address (requerido) que sea un object con campos street1, city, state y zipcode todos de tipo string y requeridos
un campo geo (no requerido) que sea un object con un campo type, con valores posibles “Point” o null y coordinates que debe ser una lista de 2 doubles
Por último, estas reglas de validación no deben prohibir la inserción o actualización de documentos que no las cumplan sino que solamente deben advertir.*/

db.runCommand({
    collMod: "theaters",
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["theaterId", "location"],
        properties: {
          theaterId: {
            bsonType: "int",
            description: "Theater ID must be an integer"
          },
          location: {
            bsonType: "object",
            required: ["address"],
            properties: {
              address: {
                bsonType: "object",
                required: ["street1", "city", "state", "zipcode"],
                properties: {
                  street1: {
                    bsonType: "string",
                    description: "Street1 must be a string"
                  },
                  city: {
                    bsonType: "string",
                    description: "City must be a string"
                  },
                  state: {
                    bsonType: "string",
                    description: "State must be a string"
                  },
                  zipcode: {
                    bsonType: "string",
                    description: "Zipcode must be a string"
                  }
                }
              },
              geo: {
                bsonType: "object",
                properties: {
                  type: {
                    enum: ["Point", null],
                    description: "Type must be 'Point' or null"
                  },
                  coordinates: {
                    bsonType: ["array"],
                    minItems: 2,
                    maxItems: 2,
                    items: {
                      bsonType: "double",
                      description: "Coordinates must be an array of 2 doubles"
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    validationLevel: "moderate",
    validationAction: "warn"
  })
  


  