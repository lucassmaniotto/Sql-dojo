-- Query 1
EXPLAIN (ANALYZE, COSTS, BUFFERS, TIMING)
SELECT e.nome AS nome_colaborador, e.salario, d.nome AS nome_departamento
FROM empregados AS e
JOIN departamentos AS d ON e.dep_id = d.dep_id
WHERE e.salario > (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id);

	-- Otimizada
	EXPLAIN (ANALYZE, COSTS, BUFFERS, TIMING)
	SELECT e.nome AS nome_colaborador, e.salario, d.nome AS nome_departamento
	FROM empregados e
	JOIN departamentos d ON e.dep_id = d.dep_id
	CROSS JOIN LATERAL (
		SELECT AVG(salario) AS salario_medio
		FROM empregados
		WHERE dep_id = e.dep_id
	) AS subq
	WHERE e.salario > subq.salario_medio;

---

EXPLAIN (ANALYZE, COSTS, BUFFERS, TIMING)
SELECT
  e.dep_id,
  d.nome AS nome_departamento,
  e.salario,
  (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id) AS media_salario_departamento
FROM empregados AS e
JOIN departamentos AS d ON e.dep_id = d.dep_id;

	--Otimizada
	EXPLAIN (ANALYZE, COSTS, BUFFERS, TIMING)
	SELECT
	  e.dep_id,
	  d.nome AS nome_departamento,
	  e.salario,
	  AVG(e.salario) OVER (PARTITION BY e.dep_id) AS media_salario_departamento
	FROM empregados AS e
	JOIN departamentos AS d ON e.dep_id = d.dep_id;

---

EXPLAIN (ANALYZE, COSTS, BUFFERS, TIMING)
SELECT
  e.nome AS nome_empregado,
  e.salario,
  (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id) AS media_salario_departamento
FROM empregados AS e
WHERE e.salario >= (SELECT AVG(salario) FROM empregados WHERE dep_id = e.dep_id);

	--Otimizada
	EXPLAIN (ANALYZE, COSTS, BUFFERS, TIMING)
	SELECT
	  e.nome AS nome_empregado,
	  e.salario,
	  subquery.media_salario_departamento
	FROM empregados AS e
	JOIN (
	  SELECT dep_id, AVG(salario) AS media_salario_departamento
	  FROM empregados
	  GROUP BY dep_id
	) AS subquery ON e.dep_id = subquery.dep_id
	WHERE e.salario >= subquery.media_salario_departamento;