/****************** Exercise 1 : DVD Rentals *****************/
-- 1) Nous voulons encourager les familles et les enfants à profiter de nos films.

-- Récupérez tous les films classés G ou PG, qui ne sont pas actuellement loués 
-- (ils ont été rendus/n'ont jamais été empruntés.

SELECT DISTINCT(inventory.film_id), film.*
FROM film
	INNER JOIN inventory ON inventory.film_id = film.film_id
WHERE film.rating='G' OR film.rating = 'PG'
	AND film.film_id NOT IN (SELECT rental.inventory_id FROM rental);

/*
	1) Créez une nouvelle table qui représentera une liste d'attente pour les films pour enfants. 
	Cela permettra à un enfant d'ajouter son nom à la liste jusqu'à ce que le DVD soit disponible (a été retourné).
	Une fois que l'enfant prend le DVD, son nom doit être retiré de la liste d'attente (idéalement en utilisant 
	des déclencheurs, mais nous ne les connaissons pas encore. 
	Supposons que notre programme Python gère cela). Quelles références de table doivent être incluses ?
*/
CREATE TABLE waiting_list(
						id SERIAL PRIMARY KEY,
						complete_name VARCHAR NOT NULL,
						inventory_id INTEGER NOT NULL,
						takes BOOLEAN DEFAULT FALSE,
	CONSTRAINT fk_inventory
						FOREIGN KEY(inventory_id)
						REFERENCES inventory(inventory_id)
						ON UPDATE CASCADE 
						ON DELETE RESTRICT
	);

CREATE OR REPLACE FUNCTION fn_waiting_list() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL AS 'BEGIN IF NEW.takes THEN
		DELETE FROM waiting_list WHERE id = NEW.id; 
	END IF;
   
   RETURN NULL; END; '

CREATE TRIGGER tr_waiting_list
   AFTER UPDATE
   ON waiting_list
   FOR EACH ROW
       EXECUTE PROCEDURE fn_waiting_list();
       

-- 3) Récupérez le nombre de personnes qui attendent le DVD de chaque enfant. 
-- Testez cela en ajoutant des lignes au tableau que vous avez créé à la question 2 ci-dessus..

INSERT INTO waiting_list(complete_name, inventory_id)
VALUES('Enfant 1', 1),
		('Enfant 2', 2),
		('Enfant 3', 3),
		('Enfant 4', 4),
		('Enfant 5', 5);
		
UPDATE waiting_list
	SET takes = TRUE 
WHERE id IN (1, 3, 5);