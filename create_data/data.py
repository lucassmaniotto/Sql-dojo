import psycopg2
import random
import csv

def loadcsv():
    csv_file_path = "ibge-fem-10000.csv"
    data_to_insert = []

    with open(csv_file_path, "r") as csv_file:
        csv_reader = csv.reader(csv_file)
        next(csv_reader)  # Skip header row

        for row in csv_reader:
            data_to_insert.append(row[0].lower())
    return data_to_insert

def create_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="dojo",
        user="postgres",
        password="postgres"
    )
    conn.set_session(autocommit=False)
    cur = conn.cursor()

    cur.execute("truncate table empregados;")
    cur.execute("truncate table departamentos;")
    print("Dropping tables...")

    return conn, cur

nomes = loadcsv()
conn, cur = create_connection()
random_values = list(range(1000, 10000, 100))
random.shuffle(random_values)

N = 10000000
dep_names = [
    "Administrativo", "Atacado", "Atendimento ao cliente", "Auditoria", "Comercial",
    "Comunicação", "Contabilidade", "Controladoria", "Desenvolvimento", "Estratégia",
    "Esportes", "Financeiro", "Garantia de Qualidade",  "Inteligência de Mercado",
    "Legal", "Logística", "Manutenção", "Marketing", "Operações", "Pesquisa e Desenvolvimento",
    "Planejamento", "Planejamento Financeiro", "Processos", "Produção", "Projetos",
    "Recursos Humanos", "Seguros", "Tesouraria", "TI Tecnologia da Informação",
    "Treinamento e Desenvolvimento", "Tributário, Fiscal", "Varejo", "Vendas"
]

print(f"Populating table empregados with {N} tuples")
for emp_id in range(0, N):
    dep_id = random.randint(1, len(dep_names))
    supervisor_id = random.randint(1, 10) if emp_id > 1 else 0
    nome = nomes[random.randint(0, len(nomes) - 1)]
    salario = random_values[random.randint(0, len(random_values) - 1)]

    insert_query = f"INSERT INTO empregados (emp_id, dep_id, supervisor_id, nome, salario) VALUES ({emp_id}, {dep_id}, {supervisor_id}, '{nome}', {salario});"
    cur.execute(insert_query)

print("Populating table departamentos...")
for dep_id, nome in enumerate(dep_names):
    insert_query = f"INSERT INTO departamentos VALUES ({dep_id}, '{nome}');"
    cur.execute(insert_query)

conn.commit()

cur.execute("SELECT count(*) FROM empregados;")
print("Number of tuples in the table empregados:", cur.fetchone()[0])

cur.close()
conn.close()
