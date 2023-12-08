/*	PRÁCTICO IV: Consultas anidadas y Agregaciones	*/

--  Parte I - Consultas

/*1)Listar el nombre de la ciudad y el nombre del país de todas las ciudades 
    que pertenezcan a países con una población menor a 10000 habitantes.*/

SELECT cy.Name AS city, co.Name AS country
FROM city AS cy
INNER JOIN country AS co ON cy.CountryCode = co.Code 
WHERE co.Code IN(
	SELECT c.Code 
	FROM country c
	WHERE c.Population <= 10000); 


/*2)Listar todas aquellas ciudades cuya población sea mayor que la población 
    promedio entre todas las ciudades.*/

SELECT cy.Name AS city
FROM city AS cy
WHERE cy.Population > ALL (
	SELECT AVG(c.Population)
	FROM city AS c);


/*3)Listar todas aquellas ciudades no asiáticas cuya población sea igual o 
    mayor a la población total de algún país de Asia.*/

SELECT cy.Name AS city
FROM city AS cy 
INNER JOIN country AS co ON cy.CountryCode = co.Code 
WHERE NOT co.Continent = 'Asia' AND cy.Population >= SOME (
	SELECT c.Population
	FROM country AS c
	WHERE c.Continent = 'Asia');


/*4)Listar aquellos países junto a sus idiomas no oficiales, que superen en 
    porcentaje de hablantes a cada uno de los idiomas oficiales del país.*/

SELECT c.Name AS country, cl.Language
FROM country AS c
INNER JOIN countrylanguage AS cl ON c.Code = cl.CountryCode 
WHERE cl.IsOfficial = 'F' AND cl.Percentage >= ALL (
	SELECT cl2.Percentage
	FROM countrylanguage AS cl2
	WHERE cl.CountryCode = cl2.CountryCode AND cl2.IsOfficial = 'T'); 


/*5)Listar (sin duplicados) aquellas regiones que tengan países con una 
    superficie menor a 1000 km2 y exista (en el país) al menos una ciudad con 
    más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una 
    subquery, intenten encontrar ambas respuestas).*/

-- CON SUBQUERY
SELECT DISTINCT co.Region AS countryRegion
FROM country AS co
WHERE co.SurfaceArea < 1000 AND 100000 <= SOME (
	SELECT ci.Population  
	FROM city AS ci
	WHERE ci.CountryCode = co.Code); 
	
-- SIN SUBQUERY	
SELECT DISTINCT co.Region AS countryRegion
FROM country AS co
INNER JOIN city AS ci ON co.Code = ci.CountryCode 
WHERE co.SurfaceArea < 1000 AND 100000 <= ci.Population; 


/*6)Listar el nombre de cada país con la cantidad de habitantes de su ciudad
    más poblada. (Hint: Hay dos maneras de llegar al mismo resultado. Usando 
    consultas escalares o usando agrupaciones, encontrar ambas).*/

-- CONSULTA ESCALAR
SELECT co.Name AS Country,
	(SELECT MAX(ci.Population) 
	 FROM city AS ci
	 WHERE co.Code = ci.CountryCode) AS mostPoblatedCity 
FROM country AS co;

-- AGRUPACIONES
SELECT co.Name AS Country, MAX(ci.Population) AS mostPoblatedCity
FROM country AS co
INNER JOIN city AS ci ON co.Code = ci.CountryCode
GROUP BY Country;

/*OBS: Al correr las dos formas veo que la primera contempla los NULL, ya que 
hay paises que no tienen ciudad, por lo tanto la primera query me da 239 filas
mientras que la segunda 232*/


/*7)Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de 
    hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.*/

SELECT co.Name AS Country, cl.Language AS nonOfficialLanguage 
FROM country AS co 
INNER JOIN countrylanguage AS cl ON co.Code = cl.CountryCode 
WHERE cl.IsOfficial = 'F' AND cl.Percentage > (
	SELECT AVG(cl2.Percentage)
	FROM countrylanguage AS cl2
	WHERE cl2.CountryCode = co.Code AND cl2.IsOfficial = 'T');


/*8)Listar la cantidad de habitantes por continente ordenado en forma 
    descendente.*/

SELECT ct.Name AS Continent, SUM(cy.Population) AS totPopulation
FROM Continent AS ct
INNER JOIN country AS cy ON cy.Continent = ct.Name
GROUP BY Continent
ORDER BY tot_population DESC;

/*9)Listar el promedio de esperanza de vida (LifeExpectancy) por continente con
    una esperanza de vida entre 40 y 70 años.*/

SELECT ct.Name AS Continent, AVG(cy.LifeExpectancy) AS LifeExpectancy
FROM Continent AS ct
INNER JOIN country AS cy ON cy.Continent = ct.Name 
WHERE 40 <= cy.LifeExpectancy AND cy.LifeExpectancy <= 70
GROUP BY Continent;

/*10)Listar la cantidad máxima, mínima, promedio y suma de habitantes por 
    continente.*/

SELECT ct.Name AS Continent, MAX(cy.Population) AS maxPopulation,
    MIN(cy.Population) AS minPopulation, AVG(cy.Population) AS avgPopulation,
    SUM(cy.Population) AS totPopulation
FROM Continent AS ct
INNER JOIN country AS cy 
WHERE cy.Continent = ct.Name 
GROUP BY Continent;

--      Parte II - Preguntas

/* Si en la consulta 6 se quisiera devolver, además de las columnas ya 
solicitadas, el nombre de la ciudad más poblada. ¿Podría lograrse con 
agrupaciones? ¿y con una subquery escalar?*/
