import os
import sys

# sys.path.insert(1, "/dags/dags_1__Ingest_data_into_local_postgres_using_airflow")

from datetime import datetime
from airflow import DAG

from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator


from ingest_script import ingest_callable


# def ingest_callable(user, password, host, port, db, table_name, csv_file, execution_date):
#     print(table_name, csv_file, execution_date)

#     engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')
#     engine.connect()

#     print('connection established successfully, inserting data...')

#     t_start = time()
#     df_iter = pd.read_csv(csv_file, iterator=True, chunksize=100000)

#     df = next(df_iter)

#     df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
#     df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

#     df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

#     df.to_sql(name=table_name, con=engine, if_exists='append')

#     t_end = time()
#     print('inserted the first chunk, took %.3f second' % (t_end - t_start))

#     while True: 
#         t_start = time()

#         try:
#             df = next(df_iter)
#         except StopIteration:
#             print("completed")
#             break

#         df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
#         df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

#         df.to_sql(name=table_name, con=engine, if_exists='append')

#         t_end = time()

#         print('inserted another chunk, took %.3f second' % (t_end - t_start))

PG_HOST = os.getenv('PG_HOST')
PG_USER = os.getenv('PG_USER')
PG_PASSWORD = os.getenv('PG_PASSWORD')
PG_PORT = os.getenv('PG_PORT')
PG_DATABASE = os.getenv('PG_DATABASE')

local_workflow = DAG(
    "Local_Ingestion_Dag"
    , schedule_interval="0 6 2 * *"
    , start_date=datetime(2021, 1, 1)
)


AIRFLOW_HOME = os.environ.get("AIRFLOW_HOME", "/opt/airflow/")
URL_PREFIX = 'https://s3.amazonaws.com/nyc-tlc/trip+data'
# URL_TEMPLATE = URL_PREFIX + '/yellow_tripdata_2021-01.csv'
URL_TEMPLATE = URL_PREFIX + '/yellow_tripdata_{{ execution_date.strftime(\'%Y-%m\') }}.csv'
OUTPUT_FILE_TEMPLATE = AIRFLOW_HOME + '/output_{{ execution_date.strftime(\'%Y-%m\') }}.csv'
TABLE_NAME_TEMPLATE = 'yellow_taxi_{{ execution_date.strftime(\'%Y_%m\') }}'

with local_workflow:

    wget_task = BashOperator(
        task_id='wget'
        #, bash_command='echo "hello world"'
        #, bash_command=f'wget {url} -O {AIRFLOW_HOME}/output.csv'
        #, bash_command=f'curl -sSL {url} > {AIRFLOW_HOME}/output.csv'
        #, bash_command='echo "{{ ds }}" "{{ execution_date.strftime(\'%Y-%m\') }}"' 
        , bash_command=f'curl -sSL {URL_TEMPLATE} > {OUTPUT_FILE_TEMPLATE}'
    )

    # ingest_task = BashOperator(
    #     task_id='ingest'
    #     #, bash_command='echo "hello world again"'
    #     , bash_command=f'ls {AIRFLOW_HOME}'
    # )

    ingest_task = PythonOperator(
        task_id='ingest'
        , python_callable=ingest_callable
        , op_kwargs = dict(
            user=PG_USER,
            password=PG_PASSWORD,
            host=PG_HOST,
            port=PG_PORT,
            db=PG_DATABASE,
            table_name=TABLE_NAME_TEMPLATE,
            csv_file=OUTPUT_FILE_TEMPLATE
        ),
    )

    wget_task >> ingest_task