-- Lucas Smaniotto Schuch
--2121101016
-- Trabalho 1 - Triggers

-- 1- Armazenar o histórico de alterações dos salários. Ou seja, 
-- deve ser criado uma tabela adicional para armazenar o usuário 
-- que fez a alteração, data, salário antigo e o novo salário.

CREATE TABLE historico_salarios (
    historico_id serial PRIMARY KEY,
    emp_id int NOT NULL,
    usuario varchar(255) NOT NULL,
    data_alteracao timestamp NOT NULL,
    salario_antigo int NOT NULL,
    novo_salario int NOT NULL
);

CREATE OR REPLACE FUNCTION registrar_historico_salario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico_salarios (emp_id, usuario, data_alteracao, salario_antigo, novo_salario)
    VALUES (
        NEW.emp_id,
        current_user,
        current_timestamp,
        OLD.salario,
        NEW.salario
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registro_alteracao_salario
AFTER UPDATE ON empregados
FOR EACH ROW
WHEN (OLD.salario IS DISTINCT FROM NEW.salario)
EXECUTE FUNCTION registrar_historico_salario();

-- SELECT * FROM empregados WHERE emp_id = 1
-- UPDATE empregados SET salario = 7000 WHERE emp_id = 1
-- SELECT * FROM historico_salarios

-- 2- Armazenar o histórico de alterações do departamento. 

CREATE TABLE historico_departamentos (
    historico_id serial PRIMARY KEY,
    dep_id int NOT NULL,
    usuario varchar(255) NOT NULL,
    data_alteracao timestamp NOT NULL,
    nome_antigo varchar(255) NOT NULL,
    novo_nome varchar(255) NOT NULL
);

CREATE OR REPLACE FUNCTION registrar_historico_departamento()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico_departamentos (dep_id, usuario, data_alteracao, nome_antigo, novo_nome)
    VALUES (
        OLD.dep_id,
        current_user,
        current_timestamp,
        OLD.nome,
        NEW.nome
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registro_alteracao_departamento
AFTER UPDATE ON departamentos
FOR EACH ROW
EXECUTE FUNCTION registrar_historico_departamento();

-- SELECT * FROM departamentos WHERE dep_id = 1
-- UPDATE departamentos SET nome = 'Teste' WHERE dep_id = 1
-- SELECT * FROM historico_departamentos

-- 3- Evite a inserção ou atualização de um salário do  empregado que seja maior do que seu chefe.

-- Gatilho BEFORE para verificar o salário do supervisor
CREATE OR REPLACE FUNCTION verificar_salario_supervisor()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salario > (
        SELECT salario
        FROM empregados
        WHERE emp_id = NEW.supervisor_id
    ) THEN
        RAISE EXCEPTION 'O salário do empregado não pode ser maior que o salário do supervisor.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gatilho BEFORE para inserção
CREATE TRIGGER verificar_salario_insert
BEFORE INSERT ON empregados
FOR EACH ROW
EXECUTE FUNCTION verificar_salario_supervisor();

-- Gatilho BEFORE para atualização
CREATE TRIGGER verificar_salario_update
BEFORE UPDATE ON empregados
FOR EACH ROW
EXECUTE FUNCTION verificar_salario_supervisor();

-- Gatilho AFTER para registrar histórico de salários
CREATE OR REPLACE FUNCTION registrar_historico_salario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico_salarios (emp_id, usuario, data_alteracao, salario_antigo, novo_salario)
    VALUES (
        NEW.emp_id,
        current_user,
        current_timestamp,
        OLD.salario,
        NEW.salario
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM empregados WHERE emp_id = 1
-- UPDATE empregados SET salario = 57000 WHERE emp_id = 2
-- INSERT INTO empregados (emp_id, dep_id, supervisor_id, nome, salario)
-- VALUES
-- 	(6,1,1,'Claudia','10000'),
-- 	(7,4,1,'Ana','12200'),
-- SELECT * FROM historico_salarios

-- 4- Faça um trigger para armazenar o total de salário pagos em cada 
-- departamento. Caso um novo empregado seja adicionado (ou atualizado),
-- o total gasto no departamento deve ser atualizado.

ALTER TABLE departamentos ADD total_salario float;

CREATE OR REPLACE FUNCTION soma_salarios_departamentos()
RETURNS void AS $$
BEGIN
	UPDATE departamentos dep SET total_salario = (select sum(salario) from empregados emp where emp.dep_id = dep.dep_id);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualiza_salarios_departamentos()
RETURNS trigger AS $$
BEGIN
	UPDATE departamentos SET total_salario = (select sum(emp.salario) from empregados emp where emp.dep_id = NEW.dep_id)
		WHERE dep_id = NEW.dep_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualiza_soma_salarios_departamentos
AFTER INSERT OR UPDATE OF salario ON empregados
FOR EACH ROW
EXECUTE FUNCTION atualiza_salarios_departamentos();

-- UPDATE empregados SET salario = 7000 WHERE emp_id = 1
-- SELECT * FROM departamentos
