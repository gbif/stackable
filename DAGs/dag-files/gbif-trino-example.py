#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

import pendulum

from airflow import DAG
from datetime import timedelta
from airflow.operators.python_operator import PythonOperator

from operators.trino_operator import TrinoOperator

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
    start_date=pendulum.datetime(2022, 5, 1, tz="Europe/Copenhagen"),
    dagrun_timeout=timedelta(minutes=60),
    catchup=False,
    tags=['example'],
) as dag:

    ## Task 1 runs a Trino select statement to count the number of records
    ## As both catalog and scheme is provided in the connection, 
    ## here are some examples on how you can specify both in the queries
    task1 = TrinoOperator(
      task_id='task_1',
      trino_conn_id='trino_connection',
      sql="select count(1) from gbif.alex.new_table")
    
    ## Task 1_1 runs a Trino select statement to count the number of records 
    task1_1 = TrinoOperator(
      task_id='task_1_1',
      trino_conn_id='trino_connection',
      sql="select count(1) from alex.new_table")

    ## Task 1_2 runs a Trino select statement to count the number of records 
    task1_2 = TrinoOperator(
      task_id='task_1_2',
      trino_conn_id='trino_connection',
      sql="select count(1) from new_table")

    ## Task 2 is a Python Operator that runs the print_command method above 
    task2 = PythonOperator(
      task_id = 'print_command',
      python_callable = print_command,
      provide_context = True,
      dag = dag)

    ## Task 3 demonstrates templating sql
    task3 = TrinoOperator(
      task_id='task_3',
      trino_conn_id='trino_connection',
      sql="select * FROM {{ params.VARONE }}.{{ params.TABLE }}",
      params={"VARONE": "alex", "TABLE": "new_table"})

    ## Task 4 demostrates parametized queries
    ## For some reason the Trino provider tries to get the first element when using paramitized sql
    ## which results in it failing the task, might be by design
    task4 = TrinoOperator(
      task_id='task_4',
      trino_conn_id='trino_connection',
      sql="select * FROM {{ params.VARONE }}.{{ params.TABLE }} where name = ?",
      params={"VARONE": "alex", "TABLE": "new_table"},
      parameters=("Something",))

    ## The following syntax determines the dependencies between all the DAG tasks.
    ## Task 1, Task 1_1 and Task 1_2 will run parallel and will have to complete successfully before any other tasks run.
    ## Tasks 3 and 4 won't run until Task 2 completes.
    ## Tasks 3 and 4 can run in parallel if there are enough worker threads. 
    [task1, task1_1, task1_2] >> task2 >> [task3, task4]