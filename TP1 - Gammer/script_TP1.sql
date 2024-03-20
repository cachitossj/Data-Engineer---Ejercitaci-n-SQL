--  DATA ENGINEER [TRABAJO PRÁCTICO NRO. 1 - MARETTO LEONEL]

/* 
INSTRUCCIONES:

1. Escribe las consultas en SQL para responder a las preguntas planteadas.
2. Asegúrate de que las consultas sean correctas y eficientes.
3. Comprueba los resultados de las consultas para asegurarte de que sean los
esperados.

CONSULTAS:

1. Obtener la lista de juegos de la clase "Aventura" con su descripción y nivel.
2. Encontrar los nombres de los usuarios que han completado el juego con ID 5.
3.Mostrar los comentarios realizados después del 1 de enero de 2024, ordenados por fecha ascendente.
4. Calcular la cantidad de juegos en cada clase.
5. Obtener el nombre del juego con la calificación más alta.
6. Encontrar los usuarios que han jugado más de 3 juegos diferentes.
7. Mostrar la lista de juegos con una calificación de 4 o 5, junto con el nombre del usuario que los sugirió (si existe).
8. Calcular el promedio de las calificaciones de los juegos de la clase "Rol".
9. Encontrar los usuarios que no han realizado ningún comentario.
10. Mostrar la lista de juegos, junto con la cantidad de usuarios que los han jugado.
*/
-- 1. Obtener la lista de juegos de la clase "Aventura" con su descripción y nivel. 
SELECT 
    g.name AS game_name,
    g.description AS game_description,
    lg.description AS level_description
FROM
    game g
LEFT JOIN
    level_game lg ON g.id_level = lg.id_level
WHERE
    g.id_class IN (SELECT id_class FROM class WHERE description = 'Adventure');

-- 2. Encontrar los nombres de los usuarios que han completado el juego con ID 5. 
SELECT 
    su.first_name, su.last_name
FROM
    system_user AS su
        JOIN
    play AS p ON su.id_system_user = p.id_system_user
WHERE
    p.completed = 1 AND p.id_game = 5;

-- 3.Mostrar los comentarios realizados después del 1 de enero de 2024, ordenados por fecha ascendente. 
SELECT 
    c.commentary AS comments
FROM
    commentary AS c
WHERE
    c.comment_date > '2024-01-01'
ORDER BY c.comment_date ASC;

-- 4. Calcular la cantidad de juegos en cada clase. 
SELECT 
    c.description, COUNT(g.id_game) AS total_games
FROM
    class AS c
        LEFT JOIN
    game AS g ON g.id_class = c.id_class
GROUP BY c.description
ORDER BY COUNT(g.id_game) DESC;

-- 5. Obtener el nombre del juego con la calificación más alta. 
SELECT 
    g.name, g.id_game, v.value 
FROM
    game AS g
        LEFT JOIN
    vote AS v ON g.id_game = v.id_game
ORDER BY v.value DESC
LIMIT 1;

-- 6. Encontrar los usuarios que han jugado más de 3 juegos diferentes. 
SELECT 
    p.id_system_user, su.first_name, su.last_name, COUNT(p.completed) AS total_games_payed
FROM
    play AS p
        INNER JOIN
    system_user AS su ON p.id_system_user = su.id_system_user
GROUP BY p.id_system_user , su.first_name, su.last_name
HAVING total_games_payed > 3
ORDER BY total_games_payed DESC;

-- 7. Mostrar la lista de juegos con una calificación de 4 o 5, junto con el nombre del usuario que los sugirió (si existe). 
SELECT 
    su.first_name, su.last_name, g.id_game, g.name AS game_name, v.value
FROM
    game AS g
        LEFT JOIN
    vote AS v ON g.id_game = v.id_game
        LEFT JOIN
    system_user AS su ON v.id_game = su.id_system_user
WHERE
    v.value BETWEEN 4 AND 5
ORDER BY v.value DESC;

-- 8. Calcular el promedio de las calificaciones de los juegos de la clase "Rol".
SELECT 
    c.id_class,
    c.description,
    ROUND(AVG(v.value), 2) AS average_vote
FROM
    game AS g
        LEFT JOIN
    vote AS v ON g.id_game = v.id_game
        LEFT JOIN
    class AS c ON g.id_class = c.id_class
GROUP BY c.id_class , c.description
HAVING c.description = 'Rol';

-- #Podemos observar que no existe una Categoría de VideoJuegos llamada "Rol":
SELECT 
    c.id_class,
    c.description,
    ROUND(AVG(v.value), 2) AS average_vote
FROM
    game AS g
        LEFT JOIN
    vote AS v ON g.id_game = v.id_game
        LEFT JOIN
    class AS c ON g.id_class = c.id_class
GROUP BY c.id_class , c.description
ORDER BY average_vote DESC;

-- 9. Encontrar los usuarios que no han realizado ningún comentario. 
    SELECT 
    su.id_system_user, su.first_name, su.last_name
FROM
    system_user AS su
LEFT JOIN
    commentary AS c ON su.id_system_user = c.id_system_user
WHERE
    c.id_commentary IS NULL;

-- 10. Mostrar la lista de juegos, junto con la cantidad de usuarios que los han jugado.
SELECT 
    g.name, COUNT(p.completed) AS times_played
FROM
    game AS g
        LEFT JOIN
    play AS p ON g.id_game = p.id_game
GROUP BY g.name
ORDER BY times_played DESC;
