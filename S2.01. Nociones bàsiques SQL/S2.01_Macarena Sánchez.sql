# SPRINT 2 - Macarena Sánchez

#Análisis rápido de las tablas:
USE transactions;
#Company 100 rows
SELECT *  FROM company;
#Transaction 100000 rows
SELECT * FROM transaction;

--  NIVELL 1 -- 

##  Exercici 2 ##
#2.1 => Llistat dels països que estan generant vendes.

SELECT DISTINCT country
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined = 0;

#2.2 => Des de quants països es generen les vendes:

SELECT COUNT(DISTINCT country) AS numero_paises
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined = 0;

#2.3 => Identifica la companyia amb la mitjana més gran de vendes.

SELECT company.id, company_name, ROUND(AVG(amount),2) AS media_ventas
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY company.id, company_name
ORDER BY AVG(amount) DESC
LIMIT 1;

## Exercici 3 ##
# 3.1 => Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT *
FROM transaction
WHERE EXISTS (SELECT id
			  FROM company
			  WHERE company.id = transaction.company_id
              AND country = "Germany"
              AND declined = 0);
              
              

# 3.2 => Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT DISTINCT company_name
FROM company
WHERE EXISTS(SELECT company_id
			 FROM transaction
             WHERE transaction.company_id = company.id
             AND amount > (SELECT AVG(amount) AS media_transacciones
						   FROM transaction
						   WHERE declined = 0));
                

#3.3 Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT company_name
FROM company
WHERE NOT EXISTS (SELECT company_id
					 FROM transaction
                     WHERE transaction.company_id = company.id
                     AND declined = 0);
                 
-- NIVELL 2 -- 


## Exercici 1 ##
# 1.1 Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
#Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS fecha, SUM(amount) AS total_ventas
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY SUM(amount) DESC
LIMIT 5;

## Exercici 2 ##
# Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT country, ROUND(AVG(amount),2) AS media_paises
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY country
ORDER BY AVG(amount) DESC;


## Exercici 3 ##
# Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia "Non Institute".
-- Paso 1 => ver de qué país es "Non Institute"

SELECT country
FROM company
WHERE company_name = "Non Institute";

-- Paso 2 
#3.1 Mostra el llistat aplicant JOIN i subconsultes.

SELECT *
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
AND company_name != "Non Institute"
AND company.country = (SELECT country
				       FROM company 
			           WHERE company_name = "Non Institute");


#3.2 Mostra el llistat aplicant solament subconsultes.

SELECT *
FROM transaction
WHERE declined = 0
AND EXISTS (SELECT id
			FROM company
			WHERE company.id = transaction.company_id
			AND company.company_name != 'Non Institute'
			AND company.country = (SELECT country
								   FROM company 
                                   WHERE company_name = 'Non Institute'));

        
-- NIVELL 3 -- 

## Exercici 1 ##        
# Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
# en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
# Ordena els resultats de major a menor quantitat.

SELECT company_name,
	   phone,
       country,
       DATE(timestamp) AS fecha,
       amount
FROM transaction
JOIN company
ON transaction.company_id = company.id
WHERE (amount BETWEEN 350 AND 400)
		AND (declined = 0)
		AND DATE(timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY amount DESC;

## Exercici 2## 

#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
# però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

-- MEDIANTE CASE -- 
SELECT company_name, COUNT(*) AS total_transacciones,
	CASE WHEN COUNT(*) > 400 then "Más de 400"
		 ELSE "Menos 400"
	END AS volumen_transacciones
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY COUNT(*) DESC;


-- CON JOIN + SUBCONSULTA -- menos eficiente, solo para comprobar
-- PASO 1 => Contar las transacciones por empresa
SELECT company_id, COUNT(id) AS total_transacciones
FROM transaction
GROUP BY company_id
HAVING total_transacciones > 400;

-- Empresas con + 400 transacciones
SELECT DISTINCT company_name
FROM company
JOIN (SELECT company_id, COUNT(id) AS total_transacciones
	  FROM transaction
      WHERE declined = 0
	  GROUP BY company_id
      HAVING total_transacciones > 400) AS empresa_transacciones
ON company.id = empresa_transacciones.company_id;

-- Empresas con menos de 400 transacciones
SELECT DISTINCT company_name
FROM company
JOIN (SELECT company_id, COUNT(id) AS total_transacciones
	  FROM transaction
      WHERE declined = 0
	  GROUP BY company_id
      HAVING total_transacciones <= 400) AS empresa_transacciones
ON company.id = empresa_transacciones.company_id;


