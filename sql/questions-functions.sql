/* EXERCICIO A 
- Crie uma tabela com a assinatura 
	“employee (id int, name varchar(50), BirthYear int, salary float)”. 
- Insira 5 tuplas


	CREATE TABLE employee (id int, name varchar(50), BirthYear int, salary float);
	INSERT INTO employee (id, name, BirthYear, salary)
	VALUES
		(1, 'Miguel', 2099, 70000.99),
		(2, 'Miles', 2000, 42.42),
		(3, 'Gwen', 2000, 174.50),
		(4, 'Peter', 1961, 0.25),
		(5, 'Hobbie', 1980, 0)
*/

-- A) Faça uma função capaz de aplicar um aumento de 10% em todos os funcionários;
DROP FUNCTION IF EXISTS raise10percent();
CREATE OR REPLACE FUNCTION raise10percent()
RETURNS SETOF employee AS $$
BEGIN
	UPDATE employee SET salary = salary * 1.1;
	RETURN QUERY SELECT * FROM employee;
END;
$$
LANGUAGE plpgsql ;

SELECT * FROM raise10percent();

-- B) Faça uma função capaz de aplicar um aumento de X% nos funcionários com id maior 
-- que N. Importante: X e N serão passados por argumento. O valor de x pode ser um float 
-- entre 0 e 1. 
DROP FUNCTION IF EXISTS raiseByParams();
CREATE OR REPLACE FUNCTION raiseByParams(X float, N int)
RETURNS SETOF employee AS $$
DECLARE
	percentage float = X;
BEGIN
	IF X > 0 AND X < 1 THEN
		X = X + 1;
		UPDATE employee e SET salary = salary * X
		WHERE e.id > N;
		RETURN QUERY SELECT * FROM employee e WHERE e.id > N;
	ELSE
		RAISE NOTICE 'Informe um valor de aumento entre 0 e 1!, você informou %', percentage;
	END IF;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM raiseByParams(0.8, 2);