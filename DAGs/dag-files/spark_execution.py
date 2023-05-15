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

from datetime import datetime,timedelta

from airflow.utils.trigger_rule import TriggerRule
from airflow import DAG
from airflow.decorators import task

from operators.stackable_spark_operator import SparkKubernetesOperator
from sensors.stackable_spark_sensor import SparkKubernetesSensor

@task(task_id="process_application_file", templates_dict={"file": "templates/spark_job_template.yaml"}, templates_exts=[".yaml"])
def proces_template(**kwargs):
    return str(kwargs["templates_dict"]["file"])

@task(task_id="print_application_file")
def print_processed_template(ti=None):
    processedTemplate = ti.xcom_pull(key="return_value", task_ids="create_application_file")
    print(processedTemplate)

with DAG(
    dag_id='gbif_spark_execution_dag',
    schedule=None,
    start_date=datetime(2022, 5, 1),
    catchup=False,
    dagrun_timeout=timedelta(minutes=60),
    tags=['spark_executor', 'GBIF']
) as dag:

    process_application_file = proces_template()

    print_application_file = print_processed_template()

    start_spark = SparkKubernetesOperator(
        task_id='spark_submit',
        namespace = "gbif-develop",
        application_file="{{ task_instance.xcom_pull(key='return_value', task_ids='process_application_file') }}",
        do_xcom_push=True,
        dag=dag,
    )

    monitor_spark = SparkKubernetesSensor(
        task_id='spark_monitor',
        namespace = "gbif-develop",
        application_name="{{ task_instance.xcom_pull(task_ids='spark_submit')['metadata']['name'] }}",
        poke_interval=5,
        dag=dag,
    )

    process_application_file >> print_application_file >> start_spark >> monitor_spark