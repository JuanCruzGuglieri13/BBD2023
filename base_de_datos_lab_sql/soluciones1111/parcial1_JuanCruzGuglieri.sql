USE olympics;

-- JUAN CRUZ GUGLIERI 44329939

-- DISCLAIMER: no pude usar backticks para todo por tema de tiempo

-- 1)
/*Crear un campo nuevo `total_medals` en la tabla `person` que almacena la 
 * cantidad de medallas ganadas por cada persona. Por defecto, con valor 0.*/

ALTER TABLE `person`
ADD `total_medals` INT DEFAULT 0 AFTER `weight`;

-- 2)
/*Actualizar la columna  `total_medals` de cada persona con el recuento real 
 * de medallas que ganó. Por ejemplo, para Michael Fred Phelps II, luego de la 
 * actualización debería tener como valor de `total_medals` igual a 28.*/
 

DROP VIEW IF EXISTS delete_non_medals; 

CREATE VIEW delete_non_medals AS
	SELECT ce.competitor_id AS c_id, ce.medal_id AS m_id
	FROM competitor_event ce
	WHERE NOT (ce.medal_id = 4);

WITH count_medals AS (
	SELECT dnm.c_id, COUNT(*) AS tot_med   
	FROM delete_non_medals dnm
	GROUP BY dnm.c_id
), total_medals AS (
	SELECT gc.person_id, SUM(tot_med) AS sum_med
	FROM games_competitor gc 
	INNER JOIN count_medals ON count_medals.c_id = gc.id
	GROUP BY gc.person_id
)
UPDATE person p 
SET p.total_medals = total_medals.sum_med
WHERE p.id = total_medals.person_id

-- 3)
/*Devolver todos los medallistas olímpicos de Argentina, es decir, los que 
 * hayan logrado alguna medalla de oro, plata, o bronce, enumerando la 
 * cantidad por tipo de medalla.  Por ejemplo, la query debería retornar casos 
 * como el siguiente:
 (Juan Martín del Potro, Bronze, 1), (Juan Martín del Potro, Silver,1)*/

WITH tot_med AS (	
	SELECT ce.competitor_id, m.id, m.medal_name, COUNT(*) AS count_med 
	FROM medal m
	INNER JOIN competitor_event ce ON ce.medal_id = m.id 
	INNER JOIN games_competitor gc ON ce.competitor_id = gc.id 
	GROUP BY m.id, ce.competitor_id  
	HAVING NOT (m.id = 4)
), sum_med AS (
	SELECT tm.medal_name, gc.person_id, SUM(tm.count_med) AS tot
	FROM games_competitor gc
	INNER JOIN tot_med tm ON gc.id = tm.competitor_id 
	GROUP BY tm.id, gc.person_id
), arg_atl AS (
	SELECT p.id, p.full_name 
	FROM person p 
	INNER JOIN person_region pr ON pr.person_id = p.id
	INNER JOIN noc_region nr ON nr.id = pr.region_id 
	WHERE nr.region_name = 'Argentina'
)
SELECT aa.full_name, sm.medal_name, sm.tot FROM sum_med sm
INNER JOIN arg_atl aa ON sm.person_id = aa.id 

-- 4)
/*Listar el total de medallas ganadas por los deportistas argentinos en cada 
 * deporte.*/

WITH med_per_dep AS (
	SELECT ce.competitor_id, s.sport_name, COUNT(ce.medal_id) AS tot_med
	FROM sport s 
	INNER JOIN event e ON e.sport_id = s.id
	INNER JOIN competitor_event ce ON ce.event_id = e.id
	WHERE NOT ce.medal_id = 4
	GROUP BY ce.competitor_id, s.sport_name 
), game_comp_from_arg AS (
	SELECT gc.id  
	FROM games_competitor gc 
	INNER JOIN person p ON gc.person_id = p.id 
	INNER JOIN person_region pr ON pr.person_id = p.id
	INNER JOIN noc_region nr ON pr.region_id = nr.id 
	WHERE nr.region_name = 'Argentina'
)
SELECT mp.sport_name, SUM(tot_med) AS medallas_de_argentina FROM med_per_dep mp
INNER JOIN game_comp_from_arg arg ON mp.competitor_id = arg.id
GROUP BY mp.sport_name

-- 5)
/*Listar el número total de medallas de oro, plata y bronce ganadas por cada 
 * país (país representado en la tabla `noc_region`), agruparlas los 
 * resultados por pais.*/
 
WITH tot_med_per_person AS (
	SELECT gc.person_id, m.medal_name, m.id, COUNT(m.id) AS tot  
	FROM competitor_event ce 
	INNER JOIN medal m ON ce.medal_id = m.id  
	INNER JOIN games_competitor gc ON ce.competitor_id = gc.id
	WHERE NOT m.id = 4
	GROUP BY m.id, gc.person_id
), person_nat AS (
	SELECT p.id, nr.region_name  
	FROM person p 
	INNER JOIN person_region pr ON p.id = pr.person_id
	INNER JOIN noc_region nr ON pr.region_id = nr.id 
)
SELECT pn.region_name, tm.medal_name, SUM(tm.tot) AS total_med
FROM tot_med_per_person tm
INNER JOIN person_nat pn ON tm.person_id = pn.id
GROUP BY pn.region_name, tm.medal_name
ORDER BY pn.region_name

-- 6) 
/*Listar el país con más y menos medallas ganadas en la historia de las 
 * olimpiadas.*/

WITH tot_med_per_person AS (
	SELECT gc.person_id, COUNT(m.id) AS tot  
	FROM competitor_event ce 
	INNER JOIN medal m ON ce.medal_id = m.id  
	INNER JOIN games_competitor gc ON ce.competitor_id = gc.id
	WHERE NOT m.id = 4
	GROUP BY gc.person_id
), person_nat AS (
	SELECT p.id, nr.region_name  
	FROM person p 
	INNER JOIN person_region pr ON p.id = pr.person_id
	INNER JOIN noc_region nr ON pr.region_id = nr.id 
), sum_med_per_nat AS (
	SELECT pn.region_name, SUM(tm.tot) AS total_med
	FROM tot_med_per_person tm
	INNER JOIN person_nat pn ON tm.person_id = pn.id
	GROUP BY pn.region_name 
), max_nat AS (
	SELECT MAX(sm.total_med) AS max_tot FROM sum_med_per_nat sm
), min_nat AS (
	SELECT MIN(sm.total_med) AS min_tot FROM sum_med_per_nat sm
) 
SELECT * FROM min_nat, max_nat

-- 7)
/*Crear dos triggers:
Un trigger llamado `increase_number_of_medals` que incrementará en 1 el valor 
del campo `total_medals` de la tabla `person`.
Un trigger llamado `decrease_number_of_medals` que decrementará en 1 el valor 
del campo `totals_medals` de la tabla `person`.
El primer trigger se ejecutará luego de un `INSERT` en la tabla 
`competitor_event` y deberá actualizar el valor en la tabla `person` de 
acuerdo al valor introducido (i.e. sólo aumentará en 1 el valor de 
`total_medals` para la persona que ganó una medalla). Análogamente, el segundo 
trigger se ejecutará luego de un `DELETE` en la tabla `competitor_event` y 
sólo actualizará el valor en la persona correspondiente.*/

DELIMITER //

CREATE TRIGGER `increase_number_of_medals`
	AFTER INSERT ON `competitor_event`
	FOR EACH ROW 
BEGIN
	WITH conn AS (
		SELECT DISTINCT gc.person_id
		FROM games_competitor gc
		WHERE NEW.competitor_id = gc.id 
	)
	UPDATE person p
	SET p.total_medals = p.total_medals + 1
	WHERE NOT NEW.medal_id = 4 
	AND p.id = conn.person_id; 
END;
	
CREATE TRIGGER `decrease_number_of_medals`
	BEFORE DELETE ON `competitor_event`
	FOR EACH ROW 
BEGIN
	WITH conn AS (
		SELECT DISTINCT gc.person_id
		FROM games_competitor gc
		WHERE NEW.competitor_id = gc.id 
	)
	UPDATE person p
	SET p.total_medals = p.total_medals - 1
	WHERE NOT NEW.medal_id = 4 
	AND p.id = conn.person_id; 
END;

//
DELIMITER ;

-- 8)
/* Crear un procedimiento  `add_new_medalists` que tomará un `event_id`, y 
 * tres ids de atletas `g_id`, `s_id`, y `b_id` donde se deberá insertar tres 
 * registros en la tabla `competitor_event`  asignando a `g_id` la medalla de 
 * oro, a `s_id` la medalla de plata, y a `b_id` la medalla de bronce.*/

DELIMITER //

CREATE PROCEDURE add_new_medalists(IN event_id INT, IN g_id INT, IN s_id INT, IN b_id INT)
BEGIN
	INSERT INTO `competitor_event` (`event_id`, `competitor_id`, `medal_id`)
	VALUES (event_id, g_id, 1);
	INSERT INTO `competitor_event` (`event_id`, `competitor_id`, `medal_id`)
	VALUES (event_id, s_id, 2);
	INSERT INTO `competitor_event` (`event_id`, `competitor_id`, `medal_id`)
	VALUES (event_id, b_id, 3);
END; //
DELIMITER ;


-- 9)
/* Crear el rol `organizer` y asignarle permisos de eliminación sobre la tabla 
 * `games` y permiso de actualización sobre la columna `games_name`  de la 
 * tabla `games`*/

CREATE ROLE `organizer`;

GRANT DELETE, UPDATE
ON games.games_name
TO `organizer`;