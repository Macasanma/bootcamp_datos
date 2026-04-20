-- Tasca S4.01. Creació de Base de Dades

	          ###########  NIVELL 1 ##############

-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
--  almenys 4 taules de les quals puguis realitzar les següents consultes:

################ PASO 1 -> Creación de la base de datos:

CREATE DATABASE ecommerce;
-- comprobación:
SHOW DATABASES;

################ PASO 2 -> Creación de tablas, de dimensiones y de hechos: 
-- Creación de tablas genérica para proporcionar felixibilidad, la longitud va determinada según lo observado en los archivos.
-- Formula para calcular la longitud de los campos:

SELECT max(char_length(company_id)) as longitud_campo FROM companies;

-- 2.1 Creación tabla dimension companies:
CREATE TABLE companies (
		company_id VARCHAR(10),
        company_name VARCHAR(100),
        phone VARCHAR(20),      
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(100)
		);

-- Comprobación:
DESCRIBE companies;

-- 2.2 Creación tabla dimensión credit_cards:
CREATE TABLE credit_cards (
			id VARCHAR(50),
            user_id VARCHAR(100),
            iban VARCHAR(100),
            pan VARCHAR(100),
            pin VARCHAR(10),
            cvv VARCHAR(10),
            track_1 VARCHAR(200),
            track_2 VARCHAR(200),
            expiring_date VARCHAR(20)
            );
            
-- Comprobación:
DESCRIBE credit_cards;

-- 2.3 Creación tabla dimensión users:
CREATE TABLE users(
			id VARCHAR(50),
            `name` VARCHAR(20), 
            surname VARCHAR(20),
            phone VARCHAR(20),
            email VARCHAR(100),
            birth_date VARCHAR(20),
            country VARCHAR(50),
            city VARCHAR(50),
            postal_code VARCHAR(50),
            address VARCHAR(100),
            continent VARCHAR(50) 
            );

-- Comprobación:
DESCRIBE users;

-- 2.4 Creación tabla de hechos transactions: 
CREATE TABLE transactions (
			id VARCHAR(50),
            card_id VARCHAR(50),
            business_id VARCHAR(10),
            `timestamp` VARCHAR(50),
            amount VARCHAR(50),
            declined VARCHAR(10),
            product_ids VARCHAR(50),
            users_id VARCHAR(50),
            latitude VARCHAR(100),
            longitude VARCHAR(100)
            );
            
-- Comprobación:
DESCRIBE transactions;

-- 2.5 Creación tabla products:  
CREATE TABLE products (
		id VARCHAR(50),
		product_name VARCHAR(50),
		price VARCHAR(20),
		colour VARCHAR(20),
		weight VARCHAR(10),
		warehouse_id VARCHAR(10)
		);

-- Comprobación:
DESCRIBE products;

################ PASO 3 -> Cargar los archivos CSV con los datos:

/*
SET GLOBAL local_infile = 1;
SHOW VARIABLES like "secure_file_priv";
SHOW VARIABLES LIKE 'local_infile';
*/

-- 3.1 Subir archivo TABLA COMPANIES:

LOAD DATA LOCAL INFILE '/Users/maca/Documents/Academico/IT academy cibernarium/Análisis de datos/Especialización/Sprint 4_ bbdd/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','    -- campos separados por comas
OPTIONALLY ENCLOSED BY '"'  -- campos que pueden venir entre comillas dobles o no
LINES TERMINATED BY '\n'    -- cuando cada linea del csv acaba con salto de linea
IGNORE 1 ROWS;				-- las cabeceras son los nombres de las columnas, no datos reales

-- Comprobación:
SELECT * FROM companies;

-- 3.2 Subir archivo TABLA CREDIT_CARDS:
LOAD DATA LOCAL INFILE '/Users/maca/Documents/Academico/IT academy cibernarium/Análisis de datos/Especialización/Sprint 4_ bbdd/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Comprobación:
SELECT * FROM credit_cards;

-- 3.3 Subir archivos TABLA USERS:
-- Tabla AMERICAN_USERS:

LOAD DATA LOCAL INFILE '/Users/maca/Documents/Academico/IT academy cibernarium/Análisis de datos/Especialización/Sprint 4_ bbdd/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, `name`, surname, phone, email, birth_date, country, city, postal_code, address)  -- para indicar que el campo continent no está en el csv
SET continent = 'America';

-- Comprobación:
SELECT * FROM USERS;

-- Tabla EUROPEAN_USERS:

LOAD DATA LOCAL INFILE '/Users/maca/Documents/Academico/IT academy cibernarium/Análisis de datos/Especialización/Sprint 4_ bbdd/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, `name`, surname, phone, email, birth_date, country, city, postal_code, address) 
SET continent = 'Europe';

-- Comprobación:
SELECT * FROM users;

-- 3.4 Subir archivo TABLA TRANSACTIONS:

LOAD DATA LOCAL INFILE '/Users/maca/Documents/Academico/IT academy cibernarium/Análisis de datos/Especialización/Sprint 4_ bbdd/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Comprobación:
SELECT * FROM transactions;

-- 3.5 Subir archivo TABLA PRODUCTS:

LOAD DATA LOCAL INFILE '/Users/maca/Documents/Academico/IT academy cibernarium/Análisis de datos/Especialización/Sprint 4_ bbdd/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Comprobación:
SELECT * FROM products;

############# PASO 4 -> Exploración, limpieza de datos y transformaciones:

### 4.1 TABLA COMPANIES:###
-- Exploración
DESCRIBE companies;
SELECT * FROM companies;  					 -- 100 rows

-- Detectar duplicados en la columna PK:
SELECT company_id, COUNT(*) AS veces_repetido
FROM companies
GROUP BY company_id
HAVING COUNT(*) > 1;
 
 -- Valores duplicados en campos considerados únicos:
 -- teléfono
 SELECT phone, COUNT(*) AS veces_repetido
 FROM companies
 GROUP BY phone
 HAVING COUNT(*) >1;
 
 -- correo electrónico
SELECT email, COUNT(*) AS veces_repetido
 FROM companies
 GROUP BY email
 HAVING COUNT(*) > 1;

-- Detectar nulos o valores vacíos en alguna columna:

SELECT *
FROM companies
WHERE company_id IS NULL OR company_id = ''
	OR company_name IS NULL OR company_name = ''
    OR phone IS NULL OR phone =''
    OR email IS NULL OR email =''
    OR country IS NULL OR country = ''
    OR website IS NULL OR website = '';
    
-- Transformaciones de tipo de dato de la tabla: 
ALTER TABLE companies
ADD PRIMARY KEY(company_id);
-- Restricciones NOT NULL en campos obligatorios
-- Pueden ponerse todas las restricciones con un único ALTER TABLE sin necesidad de comprobar una a una.

ALTER TABLE companies
MODIFY COLUMN company_name varchar(255) NOT NULL; 

ALTER TABLE companies
MODIFY COLUMN phone varchar(15) NOT NULL;

ALTER TABLE companies
MODIFY COLUMN email varchar(100) NOT NULL;

-- Comprobación de las modificaciones:
DESCRIBE companies;

### 4.2 TABLA CREDIT_CARDS ###

-- Exploración:
DESCRIBE credit_cards;      
SELECT * FROM credit_cards;                 -- 5000 rows

-- Detectar duplicados en la columna PK:
SELECT id, COUNT(*) AS veces_repetido
FROM credit_cards
GROUP BY id
HAVING COUNT(*) > 1;

-- Valores duplicados en campos considerados únicos:
-- Número iban:
SELECT iban, COUNT(*) AS veces_repetido
FROM credit_cards
GROUP BY iban
HAVING COUNT(*) > 1;

-- Número pan:
SELECT pan, COUNT(*) AS veces_repetido
FROM credit_cards
GROUP BY pan
HAVING COUNT(*) > 1;

-- Detectar nulos o valores vacíos en alguna columna crítica:
SELECT *
FROM credit_cards
WHERE id IS NULL OR id = ''
	OR user_id IS NULL OR user_id = ''
    OR iban IS NULL OR iban = ''
    OR pan IS NULL OR pan = ''
    OR pin IS NULL OR pin = ''
    OR cvv IS NULL OR cvv = ''
    OR track_1 IS NULL OR track_1 = ''
    OR track_2 IS NULL OR track_2 = '';
    
-- Transformaciones de tipo de dato de la tabla:
ALTER TABLE credit_cards
ADD PRIMARY KEY(id);

ALTER TABLE credit_cards
MODIFY COLUMN user_id INT NOT NULL; -- No es unique porque un usuario puede tener varias credit_cards

ALTER TABLE credit_cards
MODIFY COLUMN iban varchar(100) UNIQUE NOT NULL;

-- Campo pan: 
-- Transformar formato pan sin espacios:
ALTER TABLE credit_cards			 
ADD pan_nueva varchar(100);			  -- crear columna nueva

UPDATE credit_cards			  
SET pan_nueva = REPLACE(pan, " ", "") -- modificaciones de formato en esta columna nueva
WHERE id IS NOT NULL
LIMIT 100000;

SELECT pan, pan_nueva  				  -- comparación de las columnas
FROM credit_cards;
	
ALTER TABLE credit_cards
DROP COLUMN pan;                     -- eliminar tabla 1
 
ALTER TABLE credit_cards			  -- cambiar nombre a la columna
RENAME COLUMN pan_nueva TO pan;
 
-- Comprobación:
SELECT * FROM credit_cards; 

-- Cambio de tipo de datos:
ALTER TABLE credit_cards
MODIFY COLUMN pan CHAR(100) NOT NULL UNIQUE AFTER iban;

ALTER TABLE credit_cards
MODIFY COLUMN pin CHAR(4);

ALTER TABLE credit_cards
MODIFY COLUMN cvv CHAR(3);

-- Campo expiring_date DATE:
-- 1.1 Cambiar formato a ISO:
ALTER TABLE credit_cards			 
ADD new_date DATE;			  						  -- crear columna nueva

UPDATE credit_cards			  
SET new_date = STR_TO_DATE(expiring_date, '%m/%d/%y') -- modificaciones de formato en esta columna nueva
WHERE id IS NOT NULL
LIMIT 100000;

SELECT new_date, expiring_date  	 -- comparación de las columnas
FROM credit_cards;
	
ALTER TABLE credit_cards			  -- eliminar columna inicial
DROP COLUMN expiring_date;                 
 
ALTER TABLE credit_cards			  -- cambiar nombre a la columna nueva por el de la inicial
RENAME COLUMN new_date TO expiring_date;

-- Comprobación tras las modificaciones:
SELECT * FROM credit_cards;
DESCRIBE credit_cards;


#### 4.3 TABLA USERS ####
-- Exploración:
SELECT * FROM users;                    -- 500 rows
DESCRIBE users;

-- Detectar duplicados en la columna PK:
SELECT id, COUNT(*) AS veces_repetido
FROM users
GROUP BY id
HAVING COUNT(*) > 1;

-- Valores duplicados en campos considerados únicos:
-- Phone:
SELECT phone, COUNT(*) AS veces_repetido
FROM users
GROUP BY phone
HAVING COUNT(*) > 1;

-- Correo electrónico:
SELECT email, COUNT(*) AS veces_repetido
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Detectar nulos o valores vacíos en alguna columna:
SELECT *
FROM users
WHERE id IS NULL OR id = ''
	OR `name` IS NULL OR `name` = ''
    OR surname IS NULL OR surname = ''
    OR phone IS NULL OR phone = ''
    OR email IS NULL OR email = ''
    OR birth_date IS NULL OR birth_date = ''
    OR country IS NULL OR country = ''
    OR city IS NULL OR city = ''
    OR postal_code IS NULL OR postal_code = ''
    OR address IS NULL OR address = ''
    OR continent IS NULL OR continent = '';
    
-- Transformaciones de tipo de dato de la tabla: 
-- Modificaciones en la PK:
ALTER TABLE users
ADD PRIMARY KEY (id);

ALTER TABLE users
MODIFY COLUMN id INT;

ALTER TABLE users
MODIFY COLUMN `name` VARCHAR(20) NOT NULL;

ALTER TABLE users
MODIFY COLUMN surname VARCHAR(20) NOT NULL;

ALTER TABLE users
MODIFY COLUMN phone VARCHAR(20) NOT NULL;

ALTER TABLE users
MODIFY COLUMN email VARCHAR(100) NOT NULL;

-- Cambio de formato y tipo de dato de birth_date:
ALTER TABLE users
ADD birth_date_new DATE;		-- Creación de la tabla

UPDATE users
SET birth_date_new = STR_TO_DATE(birth_date, '%b %d, %Y')  -- Cambio de formato
WHERE id IS NOT NULL
LIMIT 100000;

SELECT birth_date, birth_date_new				-- Comparación de las columnas
FROM users;

ALTER TABLE users
DROP COLUMN birth_date;							-- eliminar columna inicial
                
 ALTER TABLE users
 RENAME COLUMN birth_date_new TO birth_date;  	-- cambiar nombre a la columna nueva por el de la inicial

ALTER TABLE users
MODIFY COLUMN birth_date DATE AFTER email;    -- Colocar la columna en la posición inicial

-- Comprobación de las modificaciones:
SELECT * FROM users;
DESCRIBE users;

#### 4.4 TABLA TRANSACTIONS ####
-- Exploración:
SELECT * FROM transactions;
DESCRIBE transactions;

-- Detectar duplicados en la columna PK:
SELECT id, COUNT(*) AS veces_repetido
FROM transactions
GROUP BY id
HAVING COUNT(*) > 1;

-- Detectar nulos o valores vacíos en alguna columna crítica:
SELECT * 
FROM transactions
WHERE id IS NULL OR id = ''
OR card_id IS NULL OR card_id = ''
OR business_id IS NULL OR business_id = ''
OR amount IS NULL OR amount = '';

-- Transformaciones de tipo de dato de la tabla:
-- Modificaciones en la PK:
ALTER TABLE transactions
ADD PRIMARY KEY (id);

ALTER TABLE transactions
MODIFY COLUMN card_id VARCHAR(50) NOT NULL;

ALTER TABLE transactions
MODIFY COLUMN business_id VARCHAR(10) NOT NULL;

ALTER TABLE transactions
MODIFY COLUMN `timestamp` TIMESTAMP;

ALTER TABLE transactions
MODIFY COLUMN amount DECIMAL(10,2);   

ALTER TABLE transactions
MODIFY COLUMN declined TINYINT;   

ALTER TABLE transactions
MODIFY COLUMN users_id INT NOT NULL;

ALTER TABLE transactions
MODIFY COLUMN latitude DECIMAL(10,8);

ALTER TABLE transactions
MODIFY COLUMN longitude DECIMAL(11,8);

-- Comprobar transformaciones:
DESCRIBE transactions;

#(tabla para el nivel 3)#
#### 4.5 TABLA PRODUCTS ####
-- Exploración:
SELECT * from products;
DESCRIBE products;

-- Detectar duplicados en la columna PK:
SELECT id, COUNT(*) AS veces_respetido
FROM products 
GROUP BY id
HAVING COUNT(*) > 1;

-- Valores duplicados en otros campos importantes:
-- nombre de producto:
SELECT product_name, COUNT(*) AS veces_repetidos
FROM products
GROUP BY product_name
HAVING COUNT(*) > 1;

-- Detectar nulos o valores vacíos:
SELECT * 
FROM products
WHERE id IS NULL OR id = ''
OR product_name IS NULL OR product_name = ''
OR price IS NULL OR price = ''
OR colour IS NULL OR colour = ''
OR weight IS NULL OR weight = ''
OR warehouse_id IS NULL OR warehouse_id = '';

-- Transformaciones de tipo de dato de la tabla:
-- Modificaciones en la PK:
ALTER TABLE products
ADD PRIMARY KEY (id);

ALTER TABLE products
MODIFY COLUMN id INT;

-- Formato price:
UPDATE products
SET price = REPLACE(price, '$', '')
WHERE id IS NOT NULL
LIMIT 100000;

ALTER TABLE products
MODIFY COLUMN price DECIMAL(10,2);

-- Comprobación
DESCRIBE products;
SELECT * FROM products;


################ PASO 4 -> Establecer relaciones entre las tablas del esquema:
                
-- 4.1  RELACIÓN TABLA DIMENSIÓN CON HECHOS: COMPANIES <-> TRANSACTIONS 
-- Relación de 1:N -> 1 COMPAÑÍA - N transacciones

ALTER TABLE transactions
ADD CONSTRAINT fk_companies       -- nombre asignado a la FK
FOREIGN KEY (business_id)	      -- nombre de la columna en transactions
REFERENCES companies(company_id);  -- tabla donde está(nombre columna PK)

-- Comprobación:
DESCRIBE transactions;

-- 4.2  RELACIÓN TABLA DIMENSIÓN CON HECHOS: CREDIT_CARDS <-> TRANSACTIONS 
-- Relación de 1:N -> 1 Credit_card - N transacciones

ALTER TABLE transactions
ADD CONSTRAINT fk_credit_cards
FOREIGN KEY  (card_id)
REFERENCES credit_cards(id);

-- Comprobación:
DESCRIBE transactions;

-- 4.2  RELACIÓN TABLA DIMENSIÓN CON HECHOS: USERS <-> TRANSACTIONS 
-- Relación de 1:N -> 1 USER - N transacciones

ALTER TABLE transactions
ADD CONSTRAINT fk_users
FOREIGN KEY (users_id)
REFERENCES users(id);

-- Comprobación:
DESCRIBE transactions;

-- Comprobación:
DESCRIBE  credit_cards;
SELECT * FROM transactions;


##### NIVELL 1 EXERCICI 1             
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.	
 
SELECT u.id, u.`name`, u.surname, tran_user.num_transactions 
FROM users u
JOIN (SELECT cc.user_id, COUNT(t.id) AS num_transactions
	FROM transactions t 
	JOIN credit_cards cc
	ON t.card_id = cc.id
	GROUP BY cc.user_id
	HAVING COUNT(t.id) > 80) AS tran_user
ON u.id = tran_user.user_id;
    
#### NIVELL 1 EXERCICI 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules. 

SELECT * FROM transactions;  
SELECT * FROM  companies;    -- companies.company_id = trasactions.busines_id
SELECT * FROM credit_cards; -- iban, credit_cards.id transactions.card_id

SELECT c.iban, ROUND(AVG(t.amount),2) AS cantidad_media
FROM transactions t
JOIN credit_cards c
	ON t.card_id = c.id
JOIN companies cc
	ON t.business_id = cc.company_id
WHERE company_name = 'Donec Ltd'
AND t.declined = 0
GROUP BY c.iban;  

	          ###########  NIVELL 2 ##############
-- Exercici 1:              
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions han estat declinades aleshores és inactiu,
--  si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:

-- 1.1 -> Creación de la tabla que servirá e intermediaria:                
CREATE TABLE  card_condition (
				card_id VARCHAR (50) PRIMARY KEY,
                card_status VARCHAR(20)
                );
                
-- Proceso de desarrollo:			
--  Window function e información que necesito: 

SELECT card_id, declined,
ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY `timestamp` DESC) AS rated
FROM transactions t;

-- Mostrar cómo son las 3 últimas transacciones de cada tarjeta:
SELECT *
FROM (SELECT card_id, declined,
	ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY `timestamp` DESC) AS rated
    FROM transactions) tabla_ordenada
WHERE rated <= 3;

-- 1.2 ->  Insertar los valores que tendrán los dos campos de la tabla creada previamente con los datos anteriores:
 INSERT INTO card_condition (card_id, card_status)
SELECT card_id, 
    CASE						
		WHEN SUM(declined) = 3 THEN 'Inactive'
        ELSE 'Active'
	END AS card_status         
FROM (SELECT 
	  card_id,
      declined,
      ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY `timestamp` DESC) AS rated
      FROM transactions t
      ) last_transactions	  -- Tabla auxiliar
WHERE rated <= 3              -- Filtro 3 últimas transacciones
GROUP BY card_id;			  -- Agrupo tarjeta x fila
                
-- 1.3 Comprobación:
DESCRIBE card_condition;
SELECT * from card_condition;

-- 1.4 Quantes targetes estan actives?
SELECT COUNT(*) AS cards_number
FROM card_condition
WHERE card_status = 'Active';

-- Nota - No relaciono la tabla con credit_cards porque considero que es una tabla derivada para consulta puntual.
 
								###########  NIVELL 3 ##############
                                
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
--  tenint en compte que des de transaction tens product_ids. 
-- Genera la següent consulta:


-- 1. Creación de tabla intermedia: -- 
CREATE TABLE transaction_products (
    transaction_id VARCHAR(100),
    product_id INT,
    declined TINYINT,
    PRIMARY KEY (transaction_id,product_id),
    CONSTRAINT fk_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(id)
    );
    
 -- 2. Introducir los datos la tabla intermedia:  
INSERT INTO transaction_products (transaction_id, product_id, declined)
SELECT 
    t.id,
    js.product_id,           
    t.declined
FROM transactions t
JOIN JSON_TABLE(
    CONCAT('[',REPLACE(t.product_ids, ', ', ','),']'), 
    '$[*]' COLUMNS (product_id INT PATH '$')
) AS js;

-- 3. Comprobar:
SELECT * FROM transaction_products;

-- Exercici 1: Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT product_id, product_name, COUNT(*) AS veces_vendido
FROM transaction_products tp
JOIN products p
ON tp.product_id = p.id
WHERE declined = 0
GROUP BY product_id, product_name
ORDER BY product_id ASC;