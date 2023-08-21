-- 1 Listar os empregados (nomes) que tem salário maior que seu chefe (usar o join)

SELECT e1.nome AS empregado, e1.salario AS salario_empregado, e2.nome AS chefe, e2.salario AS salario_chefe
FROM empregados AS e1
JOIN empregados AS e2 ON e1.supervisor_id = e2.emp_id
WHERE e1.salario > e2.salario;
-- Query complete 00:00:01.176

-- 2 Listar o maior salario de cada departamento (usa o group by)

SELECT d.dep_id, d.nome AS departamento, MAX(e.salario) AS maior_salario
FROM departamentos AS d
JOIN empregados AS e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome;
--Query complete 00:00:00.222

-- 3 Listar o dep_id, nome e o salario do funcionario com maior salario dentro de cada departamento (usar o with)

WITH FuncionarioMaiorSalarioPorDepartamento AS (
  SELECT
    dep_id,
    MAX(salario) AS maior_salario
  FROM empregados
  GROUP BY dep_id
)

SELECT
  d.dep_id,
  d.nome AS departamento,
  e.nome AS nome_funcionario,
  e.salario
FROM FuncionarioMaiorSalarioPorDepartamento AS f
JOIN empregados AS e ON f.dep_id = e.dep_id AND f.maior_salario = e.salario
JOIN departamentos AS d ON f.dep_id = d.dep_id;
--Query complete 00:00:00.266

-- 4 Listar os nomes departamentos que tem menos de 3 empregados;

SELECT d.nome AS nome_departamento
FROM departamentos AS d
LEFT JOIN empregados AS e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome
HAVING COUNT(e.emp_id) < 3;
--Query complete 00:00:00.412

-- 5 Listar os departamentos com o número de colaboradores

SELECT d.dep_id, d.nome AS nome_departamento, COUNT(e.emp_id) AS numero_colaboradores
FROM departamentos AS d
LEFT JOIN empregados AS e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome;
--Query complete 00:00:00.422
  
-- 6 Listar os empregados que não possue o seu chefe no mesmo departamento

SELECT e.emp_id, e.nome AS nome_empregado, e.dep_id AS departamento_empregado, e.supervisor_id, e.salario
FROM empregados AS e
LEFT JOIN empregados AS supervisor ON e.supervisor_id = supervisor.emp_id
WHERE e.dep_id <> supervisor.dep_id OR supervisor.dep_id IS NULL;
--Query complete 00:00:01.147

-- 7 Listar os nomes dos departamentos com o total de salários pagos (sliding windows function)

SELECT
  d.dep_id,
  d.nome AS nome_departamento,
  (SELECT SUM(e.salario) FROM empregados e WHERE e.dep_id = d.dep_id) AS total_salarios
FROM departamentos AS d;
--Query complete 00:00:04.631

-- 8 Listar os nomes dos colaboradores com salario maior que a média do seu departamento (dica: usar subconsultas);

SELECT e.nome AS nome_colaborador, e.salario, d.nome AS nome_departamento
FROM empregados AS e
JOIN departamentos AS d ON e.dep_id = d.dep_id
WHERE e.salario > (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id);
--Passou de 25 min

-- 9  Faça uma consulta capaz de listar os dep_id, nome, salario, e as médias de cada departamento utilizando o windows function;

SELECT
  e.dep_id,
  d.nome AS nome_departamento,
  e.salario,
  (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id) AS media_salario_departamento
FROM empregados AS e
JOIN departamentos AS d ON e.dep_id = d.dep_id;
--Passou de 25 min

-- 10 - Encontre os empregados com salario maior ou igual a média do seu departamento. Deve ser reportado o salario do empregado e a média do departamento (dica: usar window function com subconsulta)
SELECT
  e.nome AS nome_empregado,
  e.salario,
  (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id) AS media_salario_departamento
FROM empregados AS e
WHERE e.salario >= (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id);
--Passou de 25 min
