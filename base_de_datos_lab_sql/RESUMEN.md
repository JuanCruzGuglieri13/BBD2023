# RESUMEN 

## SQL I

### DDL

```sql
CREATE TABLE table_name (
    col_1 type_1,
    col_2 type_2,
    ...,
    col_n D_n,
    integrity-constraint_1,
    ...,
    integrity-constraint_k);
```  
Donde:
table_name -> nombre de la tabla
col_i -> nombre de la columna
type_i -> tipo de datos de una col
integrity-constraint_i -> es una restriccion de integridad  

Tipos de datos
- CHAR(n):  String de tamaño fijo n.
- VARCHAR(n): String de tamaño variable, con largo maximo n.
- INT:  nros. entero (machine-dependent).
- NUMERIC(p,d):  Nro de punto fijo, con precisión de p digitos y d decimales.
- DOUBLE PRECISION: Nro. de punto flotante de doble precisión.
- JSON: Objetos JSON 
- DATE: fechas sin componente de tiempo.
- DATETIME: fechas con componente de tiempo.
- BINARY: datos binarios de longitud fija (VARBINARY long variable)
- ENUM('algo_1', 'algo_2', ..., 'algo_n'): Almacena uno de los valores de una lista predefinida

### Restricciones de integridad

```sql
PRIMARY KEY(col_1,...,col_n)
-- define columna/s como claves primarias

NOT NULL
-- indica que una col no puede tener valores nulos

UNIQUE
-- indica que una col no puede tener valores repetidos

AUTO INCREMENT
-- generacion automatica de ID's
```

```sql
FOREIGN KEY (col_1, ..., col_n) REFERENCES T.(col_i)
-- los valores de las col_1,...,col_n se corresponden a los valores de la col_i de la tabla T 
```

### Actualizacion de tablas

```sql
DROP TABLE table_name;

ALTER TABLE table_name 
ADD COLUMN col1 type1;

ALTER TABLE table_name 
DROP COLUMN col1;

INSERT INTO table_name (col1,...,coln) 
VALUES (val1,...,valn);

DELETE FROM table_name WHERE condition;

UPDATE table_name SET col1 = val1, ..., 
WHERE condition;
```

### Consultas

```sql
SELECT select_expr      -- listado de columnas
FROM table_expr         -- una o mas tablas
[WHERE where_condition] -- predicado
[ORDER BY order_expr] [ASC|DESC]  -- orena segun datos numericos 

SELECT DISTINCT col FROM T;
-- elimina duplicados

SELECT * FROM T;
-- selecciona todas las col de T

SELECT col AS alias FROM T;
-- renombre de tablas

SELECT col*40 AS col_mul_40 FROM T;
-- operaciones en columnas (numericas)
```  

#### FROM
```sql
SELECT * FROM T1, T2;
-- Producto cartesiano T1xT2
SELECT a.col1, b.col3 FROM T1 AS a, T2 AS b 
-- selecciono ciertas columnas de dos tablas 
```  

#### WHERE
```sql
SELECT * FROM T
WHERE condicion;
-- filtra las filas que cumplan la condicion

AND, OR, NOT.
-- logica

LIKE
-- matchings sobre strings
SELECT * FROM T
WHERE nombre LIKE '%lu%' AND apellido LIKE 'P_REZ';
-- % matchea cualquier substring
-- _ matchea cualquier caracter

BETWEEN AND
-- valor_men <=  a <= valor_may 

IS NULL / IS NOT NULL
-- para valores nulos
```

## SQL II

### JOINS
```sql
SELECT ... 
FROM A 
[join op] B ON join_condition
-- ON se puede reemplazar con USING(columnas)

--Donde [join op]:

INNER JOIN
-- En algebra de conjuntos seria la interseccion
LEFT JOIN
-- La interseccion y todo A
RIGHT JOIN
-- LA interseccion y todo B
FULL JOIN
-- La disyuncion de A y B (no el prod cartesiano)
```

### Operaciones de Conjunto
```sql
SELECT ...
[conj op] [ALL]
SELECT ...
-- Todas operan sobre tablas
-- Eliminan automaticamente dup (para retenerlos se usa ALL)

-- Donde [conj op]:
UNION 
-- Devuelve todas las filas que aparecen en cualquiera de las consultas combinadas. 
INTERSECT
-- Devuelve solo las filas que aparecen en ambas consultas.
EXCEPT
-- Devuelve las filas del primer conjunto que no se encuentran en el segundo.

```

## SQL III

### Consultas anidadas

```sql
SELECT ...
FROM ...
WHERE [SUBQUERY]

SELECT ...
FROM [SUBQUERY]
WHERE ...

SELECT ... , [SUBQUERY], ...
FROM ...
WHERE ...
```

### Set Membership
```sql
SELECT ...
FROM ...
WHERE (columns) [IN | NOT IN] (
        [SUBQUERY|ENUMERATION]
    );
```

### Set Comparison

```sql
SELECT ...
FROM ...
WHERE (columns) 
comp [SOME|ALL] [SUBQUERY]
-- SOME o ANY: se utiliza para verificar si una expresión es verdadera para al menos un valor en el conjunto devuelto por la subconsulta.
-- ALL: se utiliza para verificar si una expresión es verdadera para todos los valores en el conjunto devuelto por la subconsulta.

comp := <,<=,>,>=, <>, =
```

### empty relations
```sql
SELECT ...
FROM ...
WHERE EXISTS [SUBQUERY]
-- EXISTS se utiliza en SQL para verificar si una subconsulta (subquery) devuelve algún resultado o al menos una fila. En otras palabras, se usa para determinar si existe al menos un registro que cumple ciertas condiciones especificadas en una subconsulta.
```

### WITH

### AGREGACIONES (FUNCIONES)
