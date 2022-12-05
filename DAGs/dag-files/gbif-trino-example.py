import pendulum

from airflow import DAG
from airflow.operators.python_operator import PythonOperator

from trino_operator import TrinoOperator

## This method is called by task2 (below) to retrieve and print to the logs the return value of task1
def print_command(**kwargs):
        task_instance = kwargs['task_instance']
        print('Return Value: ',task_instance.xcom_pull(task_ids='task_1',key='return_value'))

with DAG(
    default_args={
        'depends_on_past': False
    },
    dag_id='my_first_trino_dag',
    schedule_interval='0 8 * * *',
    start_date=pendulum.datetime(2022, 5, 1, tz="US/Central"),
    catchup=False,
    tags=['example'],
) as dag:

    ## Task 1 runs a Trino select statement to count the number of records 
    ## in the tpch.tiny.customer table
    task1 = TrinoOperator(
      task_id='task_1',
      trino_conn_id='trino_connection',
      sql="select count(1) from \"gbif-trino-hadoop\".test2")

    ## Task 2 is a Python Operator that runs the print_command method above 
    task2 = PythonOperator(
      task_id = 'print_command',
      python_callable = print_command,
      provide_context = True,
      dag = dag)

    ## Task 3 demonstrates how you can use results from previous statements in new SQL statements
    task3 = TrinoOperator(
      task_id='task_3',
      trino_conn_id='trino_connection',
      sql="select ")

    ## Task 4 demonstrates how you can run multiple statements in a single session.  
    ## Best practice is to run a single statement per task however statements that change session 
    ## settings must be run in a single task.  The set time zone statements in this example will 
    ## not affect any future tasks but the two now() functions would timestamps for the time zone 
    ## set before they were run.
    task4 = TrinoOperator(
      task_id='task_4',
      trino_conn_id='trino_connection',
      sql="set time zone 'America/Chicago'; select now(); set time zone 'UTC' ; select now()")

    ## The following syntax determines the dependencies between all the DAG tasks.
    ## Task 1 will have to complete successfully before any other tasks run.
    ## Tasks 3 and 4 won't run until Task 2 completes.
    ## Tasks 3 and 4 can run in parallel if there are enough worker threads. 
    task1 >> task2 >> [task3, task4]