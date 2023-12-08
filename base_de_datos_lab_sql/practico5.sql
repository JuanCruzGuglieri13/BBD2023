/*	Práctico V: General	*/

USE sakila;

/*1)
Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de 
Películas.
*/
CREATE TABLE directors (
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  numeroPeliculas INT,
);

/*2)
El top 5 de actrices y actores de la tabla `actors` que tienen la mayor 
experiencia (i.e. el mayor número de películas filmadas) son también 
directores de las películas en las que participaron. Basados en esta 
información, inserten, utilizando una subquery los valores correspondientes en 
la tabla `directors`.
*/
INSERT INTO directors (nombre, apellido, numeroPeliculas)
SELECT a.first_name, a.last_name, COUNT(film_id) AS tot FROM film_actor fa
INNER JOIN actor a ON a.actor_id = fa.actor_id 
GROUP BY fa.actor_id 
ORDER BY tot DESC
LIMIT 5;

/*3)
Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de  
acuerdo a si el cliente es "premium" o no. Por defecto ningún cliente será 
premium.
*/
ALTER TABLE customer 
ADD premium_customer ENUM('T','F') DEFAULT 'F'

/*4)
Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` 
de los 10 clientes con mayor dinero gastado en la plataforma.
*/
CREATE VIEW top_customers AS 
SELECT p.customer_id AS id FROM payment p 
GROUP BY  id 
ORDER BY SUM(p.amount) DESC
LIMIT 10;

UPDATE customer c
SET c.premium_customer = 'T'
WHERE c.customer_id  IN (SELECT id FROM top_customers);

/*5)
Listar, ordenados por cantidad de películas (de mayor a menor), los distintos 
ratings de las películas existentes (Hint: rating se refiere en este caso a la 
clasificación según edad: G, PG, R, etc).
*/

WITH conteo_ratings AS (
	SELECT f.rating, COUNT(*) AS tot_films 
	FROM film f
	GROUP BY f.rating
)
SELECT rating, tot_films
FROM conteo_ratings
ORDER BY tot_films;

/*6)
¿Cuáles fueron la primera y última fecha donde hubo pagos?
*/
WITH primer_pago AS (
	SELECT MIN(p.payment_date) AS first_payment
	FROM payment AS p
), ultimo_pago AS (
	SELECT MAX(p.payment_date) AS last_payment 
	FROM payment AS p
)
SELECT first_payment, last_payment
FROM primer_pago 
JOIN ultimo_pago

/*7)
Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el 
nombre del mes de una fecha).
*/

SELECT DATE_FORMAT(p.payment_date, "%Y-%m") AS y_month, AVG(amount) AS prom
FROM payment p
GROUP BY y_month;

/*8)
Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la 
cantidad total de alquileres).
*/

WITH cust_rental AS (
	SELECT r.customer_id, COUNT(*) AS tot_rents FROM rental r
	GROUP BY customer_id),
union_info AS (
	SELECT a.address_id, a.district, c.customer_id FROM address a
	INNER JOIN customer c 
	ON c.address_id  = a.address_id)
SELECT ui.district, SUM(cr.tot_rents) AS sum_tot_rents FROM union_info ui
INNER JOIN cust_rental cr 
ON cr.customer_id = ui.customer_id
GROUP BY ui.district
ORDER BY sum_tot_rents DESC
LIMIT 10

/*9)
Modifique la table `inventory_id` agregando una columna `stock` que sea un 
número entero y representa la cantidad de copias de una misma película que 
tiene determinada tienda. El número por defecto debería ser 5 copias.
*/

ALTER TABLE inventory
ADD stock INT DEFAULT 5 AFTER last_update -- ultima columna

/*10)
Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro 
a la tabla rental, haga un update en la tabla `inventory` restando una copia 
al stock de la película rentada (Hint: revisar que el rental no tiene 
información directa sobre la tienda, sino sobre el cliente, que está asociado 
a una tienda en particular).
*/

CREATE TRIGGER IF NOT EXISTS update_stock
AFTER INSERT ON rental
FOR EACH ROW
	UPDATE inventory SET stock = stock - 1
	WHERE inventory.inventory_id = NEW.inventory_id;

/*11)
Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El 
primero es una clave foránea a la tabla rental y el segundo es un valor 
numérico con dos decimales.
*/

CREATE TABLE fines (
	rental_id INT NOT NULL,
	amount DECIMAL(50,2),
	FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

/*12)
Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y 
cree un registro en la tabla `fines` por cada `rental` cuya devolución 
(return_date) haya tardado más de 3 días (comparación con rental_date). El 
valor de la multa será el número de días de retraso multiplicado por 1.5.
*/

DROP PROCEDURE IF EXISTS check_date_and_fine;

CREATE PROCEDURE check_date_and_fine()
	INSERT INTO fines (rental_id, amount)
	SELECT r.rental_id AS rental_id, 
		(DATEDIFF(r.return_date, r.rental_date)-3)*1.5 AS amount FROM rental r
	WHERE DATEDIFF(r.return_date, r.rental_date) > 3; 


CALL check_date_and_fine();

/*13)
Crear un rol `employee` que tenga acceso de inserción, eliminación y 
actualización a la tabla `rental`.
*/

CREATE ROLE employee;

GRANT INSERT, DELETE, UPDATE
ON rental
TO employee;

/*14)
Revocar el acceso de eliminación a `employee` y crear un rol `administrator` 
que tenga todos los privilegios sobre la BD `sakila`.
*/

REVOKE DELETE
ON rental
FROM employee;

CREATE ROLE administrator;

GRANT ALL
ON sakila.*
TO administrator;

/*15)
Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al 
otro de `administrator`.
*/

CREATE USER IF NOT EXISTS 'fulano'@'localhost';

CREATE USER IF NOT EXISTS 'mengano'@'localhost' IDENTIFIED BY 'password';

GRANT employee TO 'fulano'@'localhost';

GRANT administrator TO 'mengano'@'localhost';