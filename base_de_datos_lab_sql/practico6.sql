DELIMITER //

CREATE FUNCTION suma(a INT, b INT)
RETURNS INT
BEGIN
	DECLARE res INT;
	SET res = a + b;
	RETURN res;
END;	 
//

DELIMITER ;


CREATE FUNCTION sumar(a INT, b INT)
RETURNS INT
BEGIN
    DECLARE resultado INT;
    SET resultado = a + b;
    RETURN resultado;
END;


-- 1
/*Devuelva la oficina con mayor número de empleados.*/

WITH suma_empleados AS (
	SELECT e.officeCode, COUNT(*) AS suma 
	FROM employees e 
	GROUP BY e.officeCode
), max_empleados_por_of AS (
	SELECT MAX(sm.suma) AS max_val
	FROM suma_empleados sm
)
SELECT sm.officeCode, sm.suma 
FROM suma_empleados sm, max_empleados_por_of me
WHERE sm.suma = me.max_val

-- 2
/*¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la 
 * mayor cantidad de productos?*/

WITH tot_orders_customers AS (
	SELECT c.customerNumber, COUNT(*) AS tot_orders, c.salesRepEmployeeNumber AS en  
	FROM orders o
	INNER JOIN customers c ON o.customerNumber = c.customerNumber 
	GROUP BY o.customerNumber
), tot_orders_employees AS (
	SELECT e.employeeNumber, SUM(toc.tot_orders) AS sum_orders, e.officeCode 
	FROM employees e 
	INNER JOIN tot_orders_customers toc ON toc.en = e.employeeNumber
	GROUP BY e.employeeNumber
), tot_orders_office AS (
	SELECT o.officeCode, SUM(toe.sum_orders) AS sum_or_per_office
	FROM offices o 
	INNER JOIN tot_orders_employees toe ON toe.officeCode = o.officeCode
	GROUP BY o.officeCode
), avg_orders_office AS (
	SELECT AVG(too.sum_or_per_office) AS promedio_por_oficina 
	FROM tot_orders_office too
), max_orders_office AS (
	SELECT MAX(too.sum_or_per_office) AS max_orden_oficina 
	FROM tot_orders_office too
)
SELECT too.promedio_por_oficina, moo.max_orden_oficina 
FROM avg_orders_office too
JOIN max_orders_office moo

	
	
SELECT c.salesRepEmployeeNumber AS sren, COUNT(c.customerNumber) AS 
FROM customers c 	
GROUP BY c.salesRepEmployeeNumber
HAVING c.salesRepEmployeeNumber IS NOT NULL


SELECT c.customerNumber, COUNT(*) AS tot_orders, c.salesRepEmployeeNumber AS en  
FROM orders o
INNER JOIN customers c ON o.customerNumber = c.customerNumber 
GROUP BY o.customerNumber

SELECT COUNT(*) FROM orders o 

	
-- 3
/*Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.*/

-- 4
/*Crear un procedimiento "Update Credit" en donde se modifique el límite de 
 * crédito de un cliente con un valor pasado por parámetro.*/

-- 5
/*Cree una vista "Premium Customers" que devuelva el top 10 de clientes que 
 * más dinero han gastado en la plataforma. La vista deberá devolver el nombre 
 * del cliente, la ciudad y el total gastado por ese cliente en la plataforma.*/

-- 6
/*Cree una función "employee of the month" que tome un mes y un año y devuelve 
 * el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor 
 * cantidad de órdenes en ese mes.*/

DELIMITER //

CREATE FUNCTION employee_of_the_month(mes INT, año INT)
RETURNS VARCHAR
BEGIN
	DECLARE empleado;
	
END;
//
DELIMITER ;

SELECT o.customerNumber, DATE_FORMAT(o.orderDate, '%y') AS year, DATE_FORMAT(o.orderDate, '%m') AS month, COUNT(*) AS total
FROM orders o
GROUP BY o.customerNumber, o.orderDate 

-- 7
/*Crear una nueva tabla "Product Refillment". Deberá tener una relación varios 
 * a uno con "products" y los campos: `refillmentID`, `productCode`, 
 * `orderDate`, `quantity`.*/

-- 8
/*Definir un trigger "Restock Product" que esté pendiente de los cambios 
 * efectuados en `orderdetails` y cada vez que se agregue una nueva orden 
 * revise la cantidad de productos pedidos (`quantityOrdered`) y compare con 
 * la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un 
 * pedido en la tabla "Product Refillment" por 10 nuevos productos.*/

-- 9
/*Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas 
 * las tablas y accesos de creación de vistas.*/

-- Consultas Adicionales, Las siguientes consultas son más difíciles:
/*Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia en días entre las fechas de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.*/
/*Encontrar el nombre y la cantidad vendida total de los 10 productos más vendidos que, a su vez, representen al menos el 4% del total de productos, contando unidad por unidad, de todas las órdenes donde intervienen. No utilizar LIMIT.*/
