/* Ejercicio 1
* Crear la tabla `reviews` que tendrá los reviews hechos por los usuarios de
* distintos juegos, deberá constar con los siguientes campos:
* `user`: Usuario que hizo la review. Debe estar asociado a un usuario existente.
* `game`: Juego al que corresponde la review. Debe estar asociado a un juego existente.
* `rating`: Rating asignado. Es un valor de punto fijo asignado al rating de la review.
* El valor puede estar entre 0 y 5 y puede tener 1 valor decimal. No debe ser nulo.
* `comment`: Es un texto, que puede ser nulo, de un máximo de 250 caracteres.
*
* Un usuario sólo puede hacer 1 review por juego, por lo que deberán asegurar unicidad.
*
* Tener en cuenta a la hora de elegir los tipos de datos que sean lo más
* eficientes posibles.  Además, deberán coordinar con los valores que se
* definen en el archivo `reviews.sql`, que deberán cargar mediante el
* siguiente comando:
*     mysql -h <host> -u <user> -p<password> < reviews.sql
*/

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user` INT NOT NULL,
    `game` INT NOT NULL,
    `rating` DECIMAL(2,1) NOT NULL,
    `comment` VARCHAR(250),
    CONSTRAINT reviewPK PRIMARY KEY (`id`),
    CONSTRAINT userFK FOREIGN KEY (`user`) REFERENCES `user` (`id`),
    CONSTRAINT gameFK FOREIGN KEY (`game`) REFERENCES `game` (`id`),
    CONSTRAINT uniqueUserGame UNIQUE (`user`, `game`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* Ejercicio 2
* Eliminar de la tabla `reviews` todas aquellas filas cuyo campo `comment` sea nulo
* y modificar la tabla `reviews` de manera que no acepte valores nulos en el campo
* `comment`.
*/
DELETE FROM `reviews` WHERE `comment` IS NULL;
ALTER TABLE `reviews` MODIFY `comment` VARCHAR(250) NOT NULL;

/* Ejercicio 3
* Devolver el nombre y el rating promedio del género con mayor rating promedio y
* del género con menor rating promedio. Deberán realizar una sóla consulta para
* dicha tarea.
*/
WITH genres_ratings AS (
    SELECT gg.genre, AVG(rvw.rating) AS avg_rating
    FROM game_genres gg
        INNER JOIN game g ON (gg.game = g.id)
        INNER JOIN reviews rvw ON (g.id = rvw.game)
    GROUP BY gg.genre
), max_min_rating AS (
    SELECT MAX(gr.avg_rating) AS max_rating, MIN(gr.avg_rating) AS min_rating
    FROM genres_ratings gr
), max_genre_rating AS (
    SELECT gr.genre, gr.avg_rating
    FROM genres_ratings gr, max_min_rating mmr
    WHERE gr.avg_rating = mmr.max_rating
), min_genre_rating AS (
    SELECT gr.genre, gr.avg_rating
    FROM genres_ratings gr, max_min_rating mmr
    WHERE gr.avg_rating = mmr.min_rating
)
SELECT gnr.name, mgr.avg_rating
FROM genre gnr
 INNER JOIN max_genre_rating mgr ON (gnr.id = mgr.genre)
UNION
SELECT gnr.name, mgr.avg_rating
FROM genre gnr
 INNER JOIN min_genre_rating mgr ON (gnr.id = mgr.genre);

/* Ejercicio 4
* Agregar una columna a la tabla `user` llamada `number_of_reviews` que deberá
* ser un entero. La columna deberá tener por defecto el valor 0 y no podrá ser
* nula.
*/
ALTER TABLE `user`
    ADD COLUMN `number_of_reviews` INT NOT NULL DEFAULT 0;

/* Ejercicio 5
* Crear un procedimiento `set_user_number_of_reviews` que tomará un nombre de
* usuario y actualizará el valor `number_of_reviews` de acuerdo a la cantidad de
* review hechos por dicho usuario.
*/
DELIMITER $$

CREATE OR REPLACE PROCEDURE set_user_number_of_reviews(
    IN username VARCHAR(100)
)
BEGIN
    UPDATE `user` u
    SET u.number_of_reviews = (
        SELECT COUNT(*)
        FROM reviews r
            INNER JOIN `user` u ON (r.`user` = u.id)
        WHERE u.username = username
    )
    WHERE u.username = username;
END;
$$

DELIMITER ;

/* Ejercicio 6
* Crear dos triggers:
*     a. Un trigger llamado `increase_number_of_reviews` que incrementará en 1 el
*     valor del campo `number_of_reviews` de la tabla `user`.
*     b. Un trigger llamado `decrease_number_of_reviews` que decrementará en 1 el
*     valor del campo `number_of_reviews` de la tabla `user`.
* El primer trigger se ejecutará luego de un `INSERT` en la tabla `reviews` y
* deberá actualizar el valor en la tabla `user` de acuerdo al valor introducido
* (i.e. sólo aumentará en 1 el valor de `number_of_reviews` para el usuario que
* hizo la review). Análogamente, el segundo trigger se ejecutará luego de un
* `DELETE` en la tabla `reviews` y sólo actualizará el valor en `user`
* correspondiente.
*/
DELIMITER $$

CREATE TRIGGER `increase_number_of_reviews`
    AFTER INSERT ON `reviews`
    FOR EACH ROW
BEGIN
    UPDATE `user` u
    SET u.number_of_reviews = u.number_of_reviews + 1
    WHERE u.id = NEW.`user`;
END;
$$

CREATE TRIGGER `decrease_number_of_reviews`
    BEFORE DELETE ON `reviews`
    FOR EACH ROW
BEGIN
    UPDATE `user` u
    SET u.number_of_reviews = u.number_of_reviews - 1
    WHERE u.id = NEW.`user`;
END;
$$

DELIMITER ;

/* Ejercicio 7
* Devolver el nombre y el rating promedio de las 5 compañías desarrolladoras
* (i.e. pertenecientes a la tabla `developers`) con mayor rating promedio, entre
* aquellas compañías que hayan desarrollado un mínimo de 50 juegos.
*/
WITH more_than_50_developed_games AS (
    SELECT d.developer, COUNT(*) AS developed_games
    FROM developers d
    GROUP BY d.developer
    HAVING developed_games >= 50
), developer_rating AS (
    SELECT d.developer, AVG(r.rating) rating
    FROM developers d
        INNER JOIN reviews r ON (r.game = d.game)
    GROUP BY d.developer
)
SELECT c.name, dr.rating
FROM company c
    INNER JOIN developer_rating dr ON (dr.developer = c.id)
    INNER JOIN more_than_50_developed_games mdg ON (mdg.developer = c.id)
ORDER BY rating DESC
LIMIT 5;

/* Ejercicio 8
* Crear el rol `moderator` y asignarle permisos de eliminación sobre la tabla
* `reviews` y permiso de actualización sobre la columna `comment` de la tabla
* `reviews`.
*/
CREATE ROLE moderator;
GRANT DELETE, UPDATE (comment) ON reviews TO moderator;


/* Ejercicio 9
* Actualizar la tabla `user` de manera que `user.number_of_reviews` refleje
* correctamente la cantidad de reviews hechas por el usuario. Hint: Este
* ejercicio se resuelve haciendo uso de `INSERT INTO … ON DUPLICATE KEY UPDATE`.
* Punto Extra: Este ejercicio suma hasta 1 punto, pero no resta.
*/

INSERT INTO `user` (`id`, `username`, `number_of_reviews`)
SELECT * FROM (
    SELECT r.`user`, u.`username`, COUNT(*) AS number_of_reviews
    FROM reviews r INNER JOIN `user` u ON (u.id = r.`user`)
    GROUP BY 1, 2
) AS nr
ON DUPLICATE KEY UPDATE `user`.number_of_reviews = nr.number_of_reviews;
