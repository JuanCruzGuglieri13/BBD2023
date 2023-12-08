/*	PRÁCTICO II: DDL Y DML	*/


--		Parte I - DDL

/* 
1) Asegurarse de crear la base de datos inicialmente:
	- mysql -u root -h localhost
	- create database world;
	- use world;
	
2) Se debe generar los esquemas correspondientes al diagrama mostrado con las 
   respectivas restricciones.
*/

CREATE TABLE country (
	Code CHAR(3) PRIMARY KEY,
	Name VARCHAR(255),
	Continent VARCHAR(255),
	Region VARCHAR(255),
	SurfaceArea FLOAT,
	IndepYear INT,
	Population INT,
	LifeExpectancy FLOAT,
	GNP FLOAT,
	GNPOld FLOAT,
	LocalName VARCHAR(255),
	GovernmentFrom VARCHAR(255),
	HeadOfState VARCHAR(255),
	Capital INT,
	Code2 CHAR(2)
);

CREATE TABLE city (
	Id INT PRIMARY KEY,
	Name VARCHAR(255),
	CountryCode CHAR(3),
	District VARCHAR(255),
	Population INT,
	FOREIGN KEY (CountryCode) REFERENCES country(Code)
);

CREATE TABLE countrylanguage (
	CountryCode CHAR(3),
	Languaje VARCHAR(255),
	IsOfficial CHAR(1),
	Percentaje FLOAT,
	FOREIGN KEY (countryCode) REFERENCES country(Code)
);

/*
3) Descargar el conjunto de datos de la base de datos e insertarlos.

4) Crear una tabla "Continent"  que tenga los siguientes atributos:
	a) Nombre del continente.       (Clave Primaria)
	b) Área (en km2).
	c) Porcentaje de masa terrestre.
	d) Ciudad más poblada (Opcional: referencia uno-a-uno a la tabla "city").
*/

CREATE TABLE Continent (
	Name VARCHAR(255) PRIMARY KEY,
	Area INT,
	PercentTotalMass FLOAT,
	MostPopularCity VARCHAR(255),
	FOREIGN KEY (MostPopularCity) REFERENCES city(Name)
);

/*
5) Inserte los siguientes valores en la tabla "Continent":
*/
INSERT INTO `Continent` VALUES ('Africa',30370000,20.4,'Cairo, Egypt');
INSERT INTO `Continent` VALUES ('Antarctica',14000000,9.2,'McMurdo Station');
INSERT INTO `Continent` VALUES ('Asia',44579000,29.5,'Mumbai, India');
INSERT INTO `Continent` VALUES ('Europe',10180000,6.8,'Istambul, Turquia');
INSERT INTO `Continent` VALUES ('North America',24709000,16.5,'Ciudad de México, Mexico');
INSERT INTO `Continent` VALUES ('Oceania',8600000,5.9,'Sydney, Australia');
INSERT INTO `Continent` VALUES ('South America',17840000,12.0,'São Paulo, Brazil');

/*
6) Modificar la tabla "country" de manera que el campo "Continent" pase a ser 
una clave externa (o foreign key) a la tabla Continent.*
*/
ALTER TABLE country
ADD FOREIGN KEY (Continent) REFERENCES Continent(Name);


-- Parte II - Consultas
--1) Devuelva una lista de los nombres y las regiones a las que pertenece cada 
--   país ordenada alfabéticamente.
SELECT Name, Region FROM country
ORDER BY Name;

--2) Liste el nombre y la población de las 10 ciudades más pobladas del mundo.
SELECT Name, Population FROM country
ORDER BY Population DESC
LIMIT 10;

--3) Liste el nombre, región, superficie y forma de gobierno de los 10 países 
--   con menor superficie.
SELECT Name, Region, surfaceArea, GovernmentFrom 
FROM country
ORDER BY surfaceArea
LIMIT 10; 

--4) Liste todos los países que no tienen independencia (hint: ver que define 
--   la independencia de un país en la BD).
SELECT Name FROM country
WHERE IndepYear IS NULL;

--5) Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas 
--   declarados oficiales.
SELECT Languaje, Percentaje FROM countrylanguage
WHERE isOfficial = 'T';

-- ADICIONALES

--6) Actualizar el valor de porcentaje del idioma inglés en el país con código
--   'AIA' a 100.0
UPDATE countrylanguage
SET Percentaje = 100.0
WHERE CountryCode = 'AIA';

--7) Listar las ciudades que pertenecen a Córdoba (District) dentro de 
--   Argentina.
SELECT Name FROM city
WHERE District = 'Cordoba' AND CountryCode = 'ARG';

--8) Eliminar todas las ciudades que pertenezcan a Córdoba fuera de Argentina.
DELETE FROM city 
WHERE District = 'Cordoba' AND 
NOT CountryCode = 'ARG';

--9) Listar los países cuyo Jefe de Estado se llame John.
SELECT HeadOfState FROM country 
WHERE HeadOfState REGEXP 'john.'; 

--10) Listar los países cuya población esté entre 35 M y 45 M ordenados por 
--    población de forma descendente.
SELECT Name, Continent FROM country
WHERE 35000000 <= Population AND Population <= 45000000
ORDER BY Population DESC; 

