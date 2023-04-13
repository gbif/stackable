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

import logging
import os

import tempfile

from datetime import datetime,timedelta

from airflow.utils.trigger_rule import TriggerRule
from airflow import DAG
from airflow.decorators import task

from operators.stackable_spark_operator import SparkKubernetesOperator
from sensors.stackable_spark_sensor import SparkKubernetesSensor

BASE_DIR = tempfile.gettempdir()

@task(task_id="create_application_file", templates_dict={"file": "templates/spark_job_template.yaml"}, templates_exts=[".yaml"])
def create_file(fileName=None, **kwargs):
    import uuid
    baseDir = tempfile.gettempdir()
    if fileName != None:
        fullPath = baseDir + "/" + fileName + "-" + str(uuid.uuid4()) + ".yaml"
    else:
        logging.warning("No file name provided, created file with random uuid")
        fullPath = baseDir + uuid.uuid4() + ".yaml"
    f = open(fullPath, "w")
    f.write(str(kwargs["templates_dict"]["file"]))
    f.close()
    return fullPath

@task(task_id="read_application_file")
def read_file(ti=None):
    processedTemplate = ti.xcom_pull(key="return_value", task_ids="create_application_file")
    with open(processedTemplate, "r") as f:
        while True:
            l = f.readline()
            if not l:
                break
            print(l.strip())

@task(task_id="cleanup_application_file", trigger_rule=TriggerRule.ALL_DONE)
def remove_file(ti=None):
    processedTemplate = ti.xcom_pull(key="return_value", task_ids="create_application_file")
    if os.path.isfile(processedTemplate) == True:
        print("Removing the processed application file.\n")
        os.remove(processedTemplate)
    else:
        print("Unable to find processed application file, skipping stepn.\n")

with DAG(
    dag_id='gbif_spark_execution_dag',
    schedule=None,
    start_date=datetime(2022, 5, 1),
    catchup=False,
    dagrun_timeout=timedelta(minutes=60),
    tags=['spark_executor', 'GBIF']
) as dag:

    create_application_file = create_file("{{ dag_run.conf.main }}")

    read_application_file = read_file()

    cleanup_application_file = remove_file()

    start_spark = SparkKubernetesOperator(
        task_id='spark_submit',
        namespace = "namespace",
        application_file="{{ task_instance.xcom_pull(key='return_value', task_ids='create_application_file' }}",
        do_xcom_push=True,
        dag=dag,
    )

    monitor_spark = SparkKubernetesSensor(
        task_id='spark_monitor',
        namespace = "namesapce",
        application_name="{{ task_instance.xcom_pull(key='return_value', task_ids='create_application_file' }}",
        poke_interval=5,
        dag=dag,
    )

    create_application_file >> read_application_file >> start_spark >> monitor_spark >> cleanup_application_file