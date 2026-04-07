-- SPRINT 3 - Tasca S3.01. Manipulació de taules

#ANÁLISIS GENERAL bbdd:
USE transactions;
DESCRIBE company;
DESCRIBE transaction;
DESCRIBE credit_card;
DESCRIBE data_user;

# Para ver documentación sobre la creación de la tabla:
SHOW CREATE TABLE company;
SHOW CREATE TABLE transaction;
 
# Vistas rápidas de contenido:
SELECT * FROM company;
SELECT * FROM transaction;
SELECT * FROM credit_card;
SELECT * FROM data_user;

						
                        ## NIVELL 1 ##

## Exercici 1 ##

-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".


# PASO 1 -- Creación de la tabla para poder subir los datos (sin especificaciones ni constraints concretas)
CREATE TABLE credit_card(  
			id VARCHAR(100),  
            iban VARCHAR(50),
            pan VARCHAR(50),
            pin INT,
            cvv INT,
            expiring_date VARCHAR(20)
            );

# PASO 2 --  Mostrar caracterísitcas de la nueva tabla creada:
DESCRIBE credit_card;
-- Insertar datos y visualizar resultado
SELECT * FROM credit_card;

# PASO 3 --  Cambiar tipo de dato para la tabla creada:
-- 3.1 FECHA TIPO DATE: Da error en un primer momento, después de modificar el formato, lo permite
ALTER TABLE credit_card
MODIFY expiring_date DATE;

-- Desactivar seguridad pese a que no es una buena práctica [la guía buenas prácticas lo desaconseja].
SET SQL_SAFE_UPDATES = 0;

-- FECHA: cadena de texto - modificar a formato estándar ISO:YYYY-MM-DD 
UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%Y') 
WHERE expiring_date IS NOT NULL;  -- Necesita una condición para ejecutarse -> En cuya fila no haya un NULL. 

SET SQL_SAFE_UPDATES = 1;

-- Ahora si me permite realizar el cambio de tipo de dato a fecha:
ALTER TABLE credit_card
MODIFY expiring_date DATE;

-- 3.2 PAN - Quitar espacios adicionales para dar uniformidad a los valores de la columna:
-- En este proceso también se han tenido que deshabilitar la seguridad y volver a habilitarla después de hacer el cambio.

UPDATE credit_card            
SET pan = REPLACE(pan, " ", "") 
WHERE pan LIKE "% %"; -- limitado a las filas que lo necesitan, (donde haya espacio)


# PASO 4 -- RELACIONES ENTRE LAS TABLAS:
-- 4.1 Asignar PK a id de credit_card para hacer única cada tarjeta y modificar la longitud del tipo de dato.

ALTER TABLE credit_card
MODIFY id varchar(50),  -- cambio de longitud
ADD PRIMARY KEY (id);   

-- 4.2 Unir tabla credit_card con transaction mediante FK:

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card  -- nombre asignado a la FK
FOREIGN KEY (credit_card_id)   -- nombre de la columna en transaction
REFERENCES credit_card(id);    -- nombre de la PK en la tabla credit_card


## Exercici 2 ##

-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. 
-- Recorda mostrar que el canvi es va realitzar.

-- 2.1 Visualización del error:
SELECT *
FROM credit_card
WHERE id = "CcU-2938";

-- 2.2 Modificación del registro:
UPDATE credit_card
SET iban = "TR323456312213576817699999" 
WHERE id = "CcU-2938"; -- En este id

-- 2.3 Comprobación del cambio:
SELECT id, iban
FROM credit_card
WHERE id = "CcU-2938";


## Exercici 3 ##

-- En la taula "transaction" ingressa una nova transacció amb la següent informació:
-- Id 108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id	CcU-9999
-- company_id	b-9999
-- user_id	9999
-- lat	829.999
-- longitude -117.999
-- amount 111.11
-- declined	0

-- 3.1 Actualizar tabla con información de nueva transacción:
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
-- error 1452 porque no está actualizada la info en las tablas dimensiones. Primero tiene que estar en las otras tablas antes que en transaction.

-- 3.1.1 Añadir la información en las tablas de dimensiones:
-- company
INSERT INTO company (id)
VALUES ("b-9999");
-- comprobar:
SELECT *
from company
WHERE id = "b-9999";

-- credit_card
INSERT INTO credit_card (id)
VALUES ("CcU-9999");
-- comprobar:
SELECT * 
FROM credit_card
WHERE id = "CcU-9999";

-- 3.2 Actualizar en tabla transaction:
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
-- comprobar:
SELECT *
FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";


## Exercici 4 ##

-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card
DROP COLUMN pan;
-- Comprobación:
SELECT *
FROM credit_card;


                              ## NIVELL 2 ##
                              
## Exercici 1 ##

-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";
-- comprobar:
SELECT * 
FROM transaction
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

## Exercici 2 ##

-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

-- 2.1 Creación de la vista:
CREATE VIEW `VistaMarketing` AS
SELECT 
	c.company_name AS Company_name,
    c.phone AS Telephone, 
    c.country AS Country, 
    ROUND(AVG(t.amount),2) AS Average_purchase_amount
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE declined = 0
GROUP BY t.company_id, c.company_name, c.phone, c.country
ORDER BY AVG(amount) DESC;

-- 2.2 Usar la vista:
SELECT * 
FROM VistaMarketing;

## Exercici 3 ##

-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT *
FROM VistaMarketing
WHERE country = "Germany";

							
                            ## NIVELL 3 ##
                            
## Exercici 1 ##:

-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting.
-- Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

# PASO 1 - Nueva tabla:data_user -- Hacer la tabla mediante "estructura_dades_user" i "dades_introduir_user"
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- 1.1 Hacer modificaciones en la tabla nueva de user:

-- Renombrar tabla:
 RENAME TABLE user TO data_user;
 
-- Cambiar el tipo de dato del id:
ALTER TABLE data_user
MODIFY COLUMN id INT;

-- Cambiar nombre de columna email:
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

-- Comprobación:
SHOW COLUMNs FROM data_user;
DESCRIBE data_user;
SELECT * FROM data_user;

# PASO 2 -  Relacionar la tabla de data_user con transaction:

-- Para ello es necesario establecer la FK en transaction:
ALTER TABLE transaction
ADD CONSTRAINT fk_user_id
FOREIGN KEY(user_id)
REFERENCES data_user(id);
-- Error 1452
-- El user_id 9999 que había puesto en el ejercicio anterior no está actualizado en la tabla data_user.


-- 2.1 Poner el id 9999 en data_user
INSERT INTO data_user (id)
VALUES ("9999");

-- 2.2 volver a definir la FK en transacion y mostrar:
DESCRIBE transaction;
 
# PASO 3 -  Eliminar columna website en company:
ALTER TABLE company
DROP COLUMN website;
-- Comprobar:
SHOW COLUMNS FROM company;

# PASO 4 -  Modificaciones en la tabla credit_card

-- 4.1 cambiar tipo de dato:
ALTER TABLE credit_card
MODIFY COLUMN id varchar(20);
-- error 1833. Pra solucionarlo, primero hay que quitar PK, quitar FK, modificar columna y después activar PK, activar FK

-- Quitar FK en trasaction:
ALTER TABLE transaction
DROP FOREIGN KEY fk_credit_card;

-- Quitar PK en credit_card:
ALTER TABLE credit_card
DROP PRIMARY KEY;

-- Modificar tipo de dato:
ALTER TABLE credit_card
MODIFY COLUMN id varchar(20);
-- comprobar:
DESCRIBE credit_card;

-- Asignar de nuevo la PK:
ALTER TABLE credit_card
ADD PRIMARY KEY (id);

-- Asignar de nuevo la FK:
ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card (id);

-- 4.2. Cambiar tipo de dato
ALTER TABLE transaction                   -- para que coincida en tabla trasaction con credit_card
MODIFY COLUMN credit_card_id varchar(20);

ALTER TABLE credit_card
MODIFY COLUMN  pin varchar(4);

ALTER TABLE credit_card
MODIFY COLUMN expiring_date varchar(20);

-- 4.3 Nueva columna en credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;
-- comprobar:
DESCRIBE credit_card;
SELECT * FROM credit_card;

# Exercici 2 #:

-- Crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu 
-- i utilitzeu àlies per canviar de nom columnes segons calgui.
-- Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.


-- 2.1 Creación de la vista:
CREATE VIEW `InformeTecnico` AS
SELECT 
	t.id AS Id_transaction,
    d.name AS First_name,
    d.surname AS Surname,
    cc.iban AS IBAN,
    c.company_name AS Company_name
FROM transaction t
JOIN credit_card cc
ON t.credit_card_id = cc.id
JOIN data_user d
ON t.user_id = d.id
JOIN company c
ON t.company_id = c.id
ORDER BY id_transaction DESC;

-- 2.2 Usar la vista:
SELECT * 
FROM InformeTecnico;

