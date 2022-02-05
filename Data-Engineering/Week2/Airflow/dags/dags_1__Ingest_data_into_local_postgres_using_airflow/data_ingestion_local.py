
from datetime import datetime
from airflow import DAG

from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

local_workflow = DAG(
    "Local_Ingestion_Dag"
    , schedule_interval="0 6 2 * *"
    , start_date=datetime(2021, 1, 1)
)

with local_workflow:

    wget_task = BashOperator(
        task_id='wget'
        , bash_command='echo "hello world"'
    )

    ingest_task = BashOperator(
        task_id='ingest'
        , bash_command='echo "hello world again"'
    )

    wget_task >> ingest_task