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
from datetime import timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='gbif_test_dag',
    schedule_interval='0 0 * * *',
    start_date=pendulum.datetime(2022, 5, 1, tz="Europe/Copenhagen"),
    catchup=False,
    dagrun_timeout=timedelta(minutes=60),
    tags=['what', 'is', 'this'],
    params={"my_var": "gbif"}
) as dag:
    stage_1 = BashOperator(
        task_id='stage_1',
        bash_command='echo "I am at stage one and hello {{ params.my_var }}"'
    )

    stage_2 = BashOperator(
        task_id='stage_2',
        bash_command='ls -la'
    )
    stage_2 >> stage_1

    for i in range(3):
        task = BashOperator(
            task_id='runme_' + str(i),
            bash_command='echo "{{ task_instance_key_str }}" && sleep 1',
        )
        task >> stage_2

if __name__ == "__main__":
    dag.cli()