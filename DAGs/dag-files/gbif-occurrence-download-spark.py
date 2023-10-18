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

from airflow import DAG
from airflow.decorators import task
from airflow.models import Variable
from airflow.models.param import Param

from operators.stackable_spark_operator import SparkKubernetesOperator
from sensors.stackable_spark_sensor import SparkKubernetesSensor
import requests


def update_download_status(dag_id, status, callback_url):
    response = requests.get(callback_url + '?job_id=' + dag_id + '&status=' + status)
    response.raise_for_status()

def get_download_key(context):
    return context['run_id'].replace('download-','')
def on_success_download(context):
    update_download_status(get_download_key(context),'SUCCEEDED', context["params"]["callbackUrl"])

def on_failure_download(context):
    update_download_status(get_download_key(context),'FAILED', context["params"]["callbackUrl"])

def on_execute_download(context):
    update_download_status(cget_download_key(context),'RUNNING', context["params"]["callbackUrl"])

@task(task_id="process_application_file", templates_dict={"file": "templates/spark_job_download_template.yaml"}, templates_exts=[".yaml"])
def process_template(**kwargs):
    return str(kwargs["templates_dict"]["file"])

@task(task_id="print_application_file")
def print_processed_template(ti=None):
    processedTemplate = ti.xcom_pull(key="return_value", task_ids="create_application_file")
    print(processedTemplate)

with DAG(
    dag_id='gbif_occurrence_download_dag',
    schedule_interval=None,
    start_date=datetime.now(),
    catchup=False,
    dagrun_timeout=timedelta(minutes=180),
    tags=['spark_executor', 'GBIF', 'occurrence_download'],
    params= {
        "args": Param(["", "Occurrence"], type="array"),
        "version": Param("1.0.11", type="string"),
        "component": Param("occurrence-download-spark", type="string"),
        "main": Param("org.gbif.occurrence.download.spark.SparkDownloads", type="string"),
        "hdfsClusterName": Param("gbif-hdfs", type="string"),
        "hiveClusterName": Param("gbif-hive-metastore", type="string"),
        "hbaseClusterName": Param("gbif-hbase", type="string"),
        "componentConfig": Param("occurrence", type="string"),
        "driverCores": Param("2000m", type="string"),
        "driverMemory": Param("2Gi", type="string"),
        "executorInstances": Param(6, type="integer", minimum=1, maximum=12),
        "executorCores": Param("6000m", type="string"),
        "executorMemory": Param("10Gi", type="string"),
        "callbackUrl": Param("", type="string")
    },
) as dag:

    process_application_file = process_template()

    print_application_file = print_processed_template()

    start_spark = SparkKubernetesOperator(
        task_id='spark_submit',
        namespace=Variable.get('namespace_to_run'),
        application_file="{{ task_instance.xcom_pull(key='return_value', task_ids='process_application_file') }}",
        do_xcom_push=True,
        dag=dag,
        on_success_callback=on_success_download,
        on_failure_callback=on_failure_download,
        on_execute_callback=on_execute_download,
    )

    monitor_spark = SparkKubernetesSensor(
        task_id='spark_monitor',
        namespace=Variable.get('namespace_to_run'),
        application_name="{{ task_instance.xcom_pull(task_ids='spark_submit')['metadata']['name'] }}",
        poke_interval=10,
        dag=dag
    )

    process_application_file >> print_application_file >> start_spark >> monitor_spark
