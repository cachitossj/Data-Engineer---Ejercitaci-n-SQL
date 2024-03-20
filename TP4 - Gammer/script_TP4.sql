--  DATA ENGINEER [TRABAJO PRÁCTICO NRO. 4 - MARETTO LEONEL]

/* 
CONSULTAS:

1.- Join entre GAME y CLASS:
Obtener el nombre del juego, su descripción y la descripción de la clase a la que pertenece.

2.- Conteo de comentarios por juego:
Contar cuántos comentarios tiene cada juego.

3.- Promedio de votos por juego:
Calcular el promedio de valoración de cada juego.

4.- Lista de usuarios que han completado juegos:
Mostrar los nombres de los usuarios que han completado al menos un juego.

5.-Unión de comentarios y sugerencias:
Combinar los correos electrónicos de los usuarios que han hecho comentarios con los correos electrónicos de los usuarios que han sugerido juegos.

6.-Juegos sin comentarios:
Mostrar los juegos que no tienen ningún comentario.

7.-Usuarios que han votado y jugado:
Mostrar los nombres de los usuarios que han votado y también han jugado al menos un juego.

8-Clases con la cantidad de juegos asociados:
Mostrar las descripciones de las clases junto con la cantidad de juegos que tienen asociados.

9-Comentarios más recientes por juego:
Mostrar el comentario más reciente para cada juego, junto con su fecha.

10-Eliminar datos antiguos:
Eliminar los comentarios que tengan más de un año de antigüedad.
*/

-- 1. Join entre GAME y CLASS: Obtener el nombre del juego, su descripción y la descripción de la clase a la que pertenece.
SELECT 
    g.name,
    g.description AS game_description,
    c.description AS class_description
FROM
    game AS g
        LEFT JOIN
    class AS c ON g.id_class = c.id_class;

-- 2.- Conteo de comentarios por juego: Contar cuántos comentarios tiene cada juego.
SELECT 
    g.name AS game_name,
    COUNT(c.id_commentary) AS total_comments
FROM
    commentary AS c
        INNER JOIN -- Con LEFT incluiríamos los juegos que no tengan un comentario asociado.
    game AS g ON c.id_game = g.id_game
GROUP BY g.name
ORDER BY total_commentary DESC;

-- 3.- Promedio de votos por juego: Calcular el promedio de valoración de cada juego.
SELECT 
    g.name AS game_name, ROUND(AVG(v.value), 2) AS average_vote
FROM
    vote AS v
        INNER JOIN -- Con LEFT incluiríamos los juegos que no tengan un voto asociado. 
    game AS g ON v.id_game = g.id_game
GROUP BY g.name
ORDER BY average_vote DESC;

-- 4.- Lista de usuarios que han completado juegos: Mostrar cuántos juegos completados tiene cada usuario que ha dejado al menos un comentario en el sistema.
SELECT 
    su.first_name,
    su.last_name,
    COUNT(p.completed) AS games_completed
FROM
    game AS g
        LEFT JOIN
    play AS p ON g.id_game = p.id_game
        LEFT JOIN
    comment AS ct ON p.id_game = ct.id_game
        LEFT JOIN
    system_user AS su ON ct.id_system_user = su.id_system_user
WHERE
    p.completed = 1
GROUP BY su.first_name , su.last_name
HAVING COUNT(p.completed) >= 1
ORDER BY games_completed DESC;

SELECT 
    su.first_name,
    su.last_name,
    COUNT(DISTINCT p.id_game) AS games_completed
FROM
    SYSTEM_USER su
        JOIN
    COMMENTARY c ON su.id_system_user = c.id_system_user
        JOIN
    PLAY p ON c.id_game = p.id_game
WHERE
    p.completed = 1
GROUP BY su.first_name , su.last_name
HAVING COUNT(DISTINCT p.id_game) >= 1
ORDER BY games_completed DESC;


-- 5.-Unión de comentarios y sugerencias: Combinar los correos electrónicos de los usuarios que han hecho comentarios con los correos electrónicos de los usuarios que han sugerido juegos.
SELECT DISTINCT (s.email) 
  FROM suggest AS s
       LEFT JOIN
       commentary AS c ON s.id_system_user = c.id_system_user;

SELECT DISTINCT
    (t.email)
FROM
    (SELECT DISTINCT
        (s.email)
    FROM
        commentary c
    INNER JOIN system_user s ON c.id_system_user = s.id_system_user UNION SELECT DISTINCT
        (su.email)
    FROM
        suggest su) t
ORDER BY t.email DESC;

-- Correos de usuarios que han hecho comentarios
SELECT email
FROM SYSTEM_USER
WHERE id_system_user IN (SELECT id_system_user FROM COMMENT)
UNION
-- Correos de usuarios que han sugerido juegos
SELECT email
FROM SYSTEM_USER
WHERE id_system_user IN (SELECT id_system_user FROM SUGGEST);

SELECT email
FROM (
    SELECT email
    FROM SUGGEST
    UNION
    SELECT email
    FROM SYSTEM_USER
    WHERE id_system_user IN (
        SELECT id_system_user
        FROM COMMENTARY
    )
) AS combined_emails;

-- 6.-Juegos sin comentarios: Mostrar los juegos que no tienen ningún comentario.
SELECT 
    g.name AS game_name
FROM
    game AS g
        LEFT JOIN
    commentary AS c ON g.id_game = c.id_game
WHERE
    c.id_commentary IS NULL;

-- 7.-Usuarios que han votado y jugado: Mostrar los nombres de los usuarios que han votado y también han jugado al menos un juego.
SELECT 
    s.id_system_user, s.first_name, s.last_name
FROM
    system_user AS s
        INNER JOIN
    vote AS v ON s.id_system_user = v.id_system_user
WHERE
    s.id_system_user IN (SELECT 
            id_system_user
        FROM
            play);
            
SELECT su.first_name, su.last_name
FROM SYSTEM_USER su
JOIN VOTE v ON su.id_system_user = v.id_system_user
JOIN PLAY p ON su.id_system_user = p.id_system_user
GROUP BY su.first_name, su.last_name;

-- 8.-Clases con la cantidad de juegos asociados: Mostrar las descripciones de las clases junto con la cantidad de juegos que tienen asociados.
SELECT 
    c.description, COUNT(g.id_game) AS total_games
FROM
    class AS c
        LEFT JOIN
    game AS g ON c.id_class = g.id_class
GROUP BY c.description
ORDER BY total_games DESC;

-- 9.-Comentarios más recientes por juego: Mostrar el comentario más reciente para cada juego, junto con su fecha.
SELECT 
    g.name, MAX(c.last_date) AS last_commentary
FROM
    comment AS c
        LEFT JOIN
    game AS g ON c.id_game = g.id_game
GROUP BY g.name
ORDER BY last_commentary DESC;


SELECT 
    g.name AS game_name,
    c.commentary AS recent_comment,
    c.comment_date AS recent_comment_date
FROM
    game g
        JOIN
    commentary c ON g.id_game = c.id_game
        JOIN
    (SELECT 
        id_game, MAX(comment_date) AS max_comment_date
    FROM
        commentary
    GROUP BY id_game) cm ON c.id_game = cm.id_game
        AND c.comment_date = cm.max_comment_date;
