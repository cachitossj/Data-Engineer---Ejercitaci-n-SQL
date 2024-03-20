--  DATA ENGINEER [TRABAJO PRÁCTICO NRO. 2 - MARETTO LEONEL]

/*
CONSULTAS:

1. 	● Encuentra todos los juegos de la clase "Aventura" cuyo nivel sea mayoro igual a 5.
	● Muestra el nombre del juego, la descripción y el nivel.
	● Combina los nombres y apellidos de todos los usuarios y empleados, ordenados alfabéticamente por apellido.
    
2.	● Calcula el número total de comentarios por juego.
	● Muestra el nombre del juego y la cantidad de comentarios, ordenados de mayor a menor cantidad de comentarios.

3.	● Encuentra todos los juegos que no hayan sido sugeridos por ningún usuario.
	● Muestra el nombre del juego y la descripción.
    
4.	● Encuentra todos los usuarios que hayan completado al menos 5 juegos.
	● Muestra el nombre completo del usuario y la cantidad de juegos completados.
	● Solo incluye usuarios que hayan completado al menos 5 juegos.

5.	● Encuentra el promedio de votos para cada juego.
	● Muestra el nombre del juego y el promedio de votos, redondeado a dos decimales.
    
6.	● Encuentra todos los juegos que tengan comentarios o sugerencias.
	● Muestra el nombre del juego y si tiene comentarios o sugerencias.

7.	● Encuentra todos los juegos cuya fecha de primer comentario esté entre el 2023-01-01 y el 2023-12-31.
	● Muestra el nombre del juego y la fecha del primer comentario, ordenados por fecha.

8.	● Calcula la cantidad total de comentarios por año.
	● Muestra el año y la cantidad total de comentarios, ordenados cronológicamente.

9.	● Encuentra todos los juegos de la clase "Estrategia" que hayan sido jugados por el usuario con ID 123.
	● Muestra el nombre del juego, la descripción y si fue completado por el usuario.
*/

-- 1. ● Encuentra todos los juegos de la clase "Aventura" cuyo nivel sea mayoro igual a 5.
--    ● Muestra el nombre del juego, la descripción y el nivel.
SELECT 
    g.name AS game_name,
    c.description AS class_description,
    lg.description AS level_description
FROM
    level_game AS lg
        LEFT JOIN
    class AS c ON lg.id_level = c.id_level
		LEFT JOIN 
        game AS g ON c.id_class = g.id_class
WHERE
    c.description = 'Adventure'
        AND lg.id_level >= 5;

-- ● Combina los nombres y apellidos de todos los usuarios y empleados, ordenados alfabéticamente por apellido.
SELECT 
    su.first_name,
    su.last_name,
    g.name AS game_name,
    c.description AS class_description,
    lg.description AS level_description
FROM
    level_game AS lg
        LEFT JOIN
    class AS c ON lg.id_level = c.id_level
        LEFT JOIN
    game AS g ON c.id_class = g.id_class
        LEFT JOIN
    comment AS ct ON g.id_game = ct.id_game
        LEFT JOIN
    system_user AS su ON ct.id_system_user = su.id_system_user
WHERE
    c.description = 'Adventure'
        AND lg.id_level >= 5;


-- 2.	● Calcula el número total de comentarios por juego.
--      ● Muestra el nombre del juego y la cantidad de comentarios, ordenados de mayor a menor cantidad de comentarios.
		SELECT 
    g.name AS game_name, COUNT(c.commentary) AS total_commentary
FROM
    commentary AS c
        LEFT JOIN
    game AS g ON c.id_game = g.id_game
GROUP BY game_name
ORDER BY total_commentary DESC;

-- 3.	● Encuentra todos los juegos que no hayan sido sugeridos por ningún usuario.
-- 	    ● Muestra el nombre del juego y la descripción.
SELECT g.name AS game_name, g.description AS game_description, s.id_suggest, s.email
FROM suggest AS s
LEFT JOIN
game as g ON s.id_game = g.id_game
WHERE s.email IS NULL;

-- 4.	● Encuentra todos los usuarios que hayan completado al menos 5 juegos.
-- 	    ● Muestra el nombre completo del usuario y la cantidad de juegos completados.
-- 	    ● Solo incluye usuarios que hayan completado al menos 5 juegos
SELECT 
    su.first_name,
    su.last_name,
    COUNT(p.completed) AS juegos_completados
FROM
    system_user AS su
LEFT JOIN
    comment AS ct ON su.id_system_user = ct.id_system_user
LEFT JOIN
    play AS p ON ct.id_game = p.id_game
WHERE
    p.completed = 1
GROUP BY su.first_name, su.last_name
HAVING COUNT(p.completed) >= 5
ORDER BY juegos_completados DESC;

-- 5.	● Encuentra el promedio de votos para cada juego.
-- 	    ● Muestra el nombre del juego y el promedio de votos, redondeado a dos decimales.
SELECT 
    g.id_Game, g.name, ROUND(AVG(v.value), 2) AS avg_value
FROM
    game AS g
        LEFT JOIN
    vote AS v ON g.id_GAME = v.id_GAME
GROUP BY g.id_Game;
 
-- 6.	● Encuentra todos los juegos que tengan comentarios o sugerencias.
--      ● Muestra el nombre del juego y si tiene comentarios o sugerencias.
SELECT 
    g.name, c.commentary, s.email
FROM
    game AS g
        INNER JOIN
    commentary AS c ON g.id_game = c.id_game
        INNER JOIN
    suggest AS s ON g.id_game = s.id_game;
    
SELECT 
    g.name AS nombre_juego,
    MAX(CASE WHEN c.id_commentary IS NOT NULL THEN 'Tiene comentarios' ELSE 'No tiene comentarios' END) AS tiene_comentarios,
    MAX(CASE WHEN s.id_suggest IS NOT NULL THEN 'Tiene sugerencias' ELSE 'No tiene sugerencias' END) AS tiene_sugerencias
FROM
    game AS g
LEFT JOIN
    commentary AS c ON g.id_game = c.id_game
LEFT JOIN
    suggest AS s ON g.id_game = s.id_game
GROUP BY g.name;

-- 7.	● Encuentra todos los juegos cuya fecha de primer comentario esté entre el 2023-01-01 y el 2023-12-31.
--      ● Muestra el nombre del juego y la fecha del primer comentario, ordenados por fecha
    SELECT 
    g.name, 
    MIN(c.comment_date) AS fecha_primer_comentario
FROM
    game AS g
LEFT JOIN
    commentary AS c ON g.id_game = c.id_game
GROUP BY g.name
HAVING MIN(c.comment_date) BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY fecha_primer_comentario;
 
 -- 8.	● Calcula la cantidad total de comentarios por año.
--      ● Muestra el año y la cantidad total de comentarios, ordenados cronológicamente.
SELECT 
    STRFTIME('%Y', comment_date) AS year,
    COUNT(id_commentary) AS count_of_comments
FROM
    commentary
GROUP BY year
ORDER BY year ASC;

-- 9.	● Encuentra todos los juegos de la clase "Estrategia" que hayan sido jugados por el usuario con ID 123.
--      ● Muestra el nombre del juego, la descripción y si fue completado por el usuario.
SELECT 
    g.name, g.description, p.completed
FROM
    game AS g
        LEFT JOIN
    play AS p ON g.id_game = p.id_game
WHERE
    p.id_system_user= 123;