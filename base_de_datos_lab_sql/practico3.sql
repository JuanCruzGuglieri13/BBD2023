/*  PRÁCTICO III: Joins y Conjuntos  */

--		Parte I - Consultas

--1)
/*Lista el nombre de la ciudad, nombre del país, región y forma de gobierno
de las 10 ciudades más pobladas del mundo.*/

SELECT city.Name, country.Name, country.Region, country.GovernmentFrom
FROM city
INNER JOIN country ON city.CountryCode = country.Code
ORDER BY country.Population DESC
LIMIT 10;

-- OBS: city INNER JOIN country == country INNER JOIN city. 

--2)
/*Listar los 10 países con menor población del mundo, junto a sus ciudades 
capitales (Hint: puede que uno de estos países no tenga ciudad capital 
asignada, en este caso deberá mostrar "NULL").*/

SELECT co.Name AS Country_name, ci.Name AS City_name
FROM country AS co
LEFT JOIN city AS ci ON co.Capital = ci.Id
ORDER BY co.Population ASC
LIMIT 10;

-- OBS: Si lo hago con INNER JOIN me tira los paises con menor Population
-- pero si un pais no tiene capital, lo omite y me tira el siguiente que
-- si tenga capital.

--3)
/*Listar el nombre, continente y todos los lenguajes oficiales de cada país.
(Hint: habrá más de una fila por país si tiene varios idiomas oficiales).*/

SELECT cy.Name AS Country, ct.Name AS Continent, cl.language
FROM country cy 
INNER JOIN Continent ct ON cy.Continent = ct.Name
INNER JOIN countrylanguage cl ON cy.Code = cl.CountryCode
AND cl.IsOfficial = 'T'; 

--4)
/*Listar el nombre del país y nombre de capital, de los 20 países con mayor
 superficie del mundo.*/
 
SELECT co.Name AS Country, ci.Name AS Capital
FROM country AS co
INNER JOIN city AS ci ON co.Capital = ci.Id
ORDER BY co.SurfaceArea DESC 
LIMIT 20;

--5)
/*Listar las ciudades junto a sus idiomas oficiales (ordenado por la población
 de la ciudad) y el porcentaje de hablantes del idioma.*/

SELECT ci.Name AS city, cl.language, cl.Percentaje  
FROM city ci 
INNER JOIN country co ON ci.CountryCode = co.Code 
INNER JOIN countrylanguage cl ON co.Code = cl.CountryCode 
AND cl.IsOfficial = 'T'
ORDER BY ci.Population DESC;

--6)
/*Listar los 10 países con mayor población y los 10 países con menor población 
 (que tengan al menos 100 habitantes) en la misma consulta.*/

(SELECT c.Name AS Country, c.Population 
FROM country c 
ORDER BY c.Population DESC
LIMIT 10)
UNION
(SELECT c.Name AS Country, c.Population 
FROM country c
WHERE c.Population >= 100
ORDER BY c.Population ASC
LIMIT 10);

--7)
/*Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés 
 (hint: no debería haber filas duplicadas).*/
 
(SELECT c.Name AS country  
FROM country AS c
INNER JOIN countrylanguage AS cl ON cl.CountryCode = c.Code
AND cl.language = 'English' 
AND cl.IsOfficial = 'T')
INTERSECT
(SELECT c.Name AS country  
FROM country AS c
INNER JOIN countrylanguage AS cl ON cl.CountryCode = c.Code
AND cl.language = 'French' 
AND cl.IsOfficial = 'T');

-- OBS: uso la tabla countrylanguage dos veces (con condiciones diferentes),
-- el primer inner me genera una tabla con todos los paises con ingles como
-- oficial y ademas otro inner para excluir aquellos que no hablen frances.

--8)
/*Listar aquellos países que tengan hablantes del Inglés pero no del Español en
 su población.*/
 
(SELECT c.Name AS country  
FROM country AS c
INNER JOIN countrylanguage AS cl ON cl.CountryCode = c.Code
AND cl.language = 'English')
EXCEPT 
(SELECT c.Name AS country  
FROM country AS c
INNER JOIN countrylanguage AS cl ON cl.CountryCode = c.Code
AND cl.language = 'Spanish');


--		Parte II - Preguntas

--1)
/*¿Devuelven los mismos valores las siguientes consultas? ¿Por qué?*/ 

SELECT city.Name, country.Name
FROM city
INNER JOIN country ON city.CountryCode = country.Code AND country.Name = 'Argentina';

SELECT city.Name, country.Name
FROM city
INNER JOIN country ON city.CountryCode = country.Code
WHERE country.Name = 'Argentina';

-- RTA
/* Si, devuelven los mismos valores, la diferencia es en el orden por asi
 decirlo; En el primer caso la tabla se construye por las condiciones que la
 ciudad sea compatible con el pais, y al mismo tiempo en esa seleccion el 
 nombre del país sea Argentina. En el segundo caso, se arma la tabla a través 
 de la relacion de la ciudad con el país, y luego, esa tabla es filtrada por 
 los paises que se llaman 'Argentina'. 
 */

--2)
/*¿Y si en vez de INNER JOIN fuera un LEFT JOIN?*/

-- RTA
/* En la segunda query, los valores no cambiarian, en la primer si, ya que 
 todas las ciudades se incluirán en el resultado final, incluso si no tienen 
 una correspondencia en la columna de los paises. Si una ciudad no tiene un 
 país correspondiente llamado 'Argentina', la columna country.Name mostrará 
 NULL en el resultado 
 */

