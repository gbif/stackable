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

from operators.stackable_spark_operator import SparkKubernetesOperator
from sensors.stackable_spark_sensor import SparkKubernetesSensor
from operators.trino_operator import TrinoOperator
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.models.param import Param
from airflow import DAG
from datetime import timedelta
import pendulum

from kubernetes.client import models as k8s

hadoop_env_mounts = k8s.V1VolumeMount(
    mount_path="/app/conf", name="hadoop-env", sub_path=None, read_only=True
)

hadoop_env_volume = k8s.V1Volume(
    name="hadoop-env", 
    config_map=k8s.V1ConfigMapVolumeSource(name="gbif-hdfs")
)

with DAG(
    dag_id='data_proces_flow_dag',
    schedule_interval='0 0 1 1 *',
    start_date=pendulum.datetime(2022, 5, 1, tz="Europe/Copenhagen"),
    catchup=False,
    dagrun_timeout=timedelta(minutes=300),
    tags=['spark'],
    params= {
        "namespace_to_run": Param("stack-demo")
        },
) as dag:
    task1 = TrinoOperator(
      task_id='create_schema',
      trino_conn_id='trino_connection',
      sql="CREATE SCHEMA IF NOT EXISTS gbif.alex WITH (LOCATION = 'hdfs://gbif-hdfs/user/alex')"
    )
    task4 = SparkKubernetesOperator(
        task_id='create_hive_tables',
        namespace="{{ params.namesoace_to_run }}",
        application_file="spark-example-job.yaml",
        do_xcom_push=True,
        dag=dag
    )
    task5 = SparkKubernetesSensor(
        task_id='monitor_table_creation',
        namespace="{{ params.namesoace_to_run }}",
        application_name="{{ task_instance.xcom_pull(task_ids='create_hive_tables')['metadata']['name'] }}",
        poke_interval=5,
        dag=dag
    )
    task6 = TrinoOperator(
        task_id='create_table_from_search',
        trino_conn_id='trino_connection',
        sql="CREATE TABLE gbif.alex.result WITH (format='ORC') AS SELECT * FROM gbif.alex.occurrence_parquet WHERE year > 2000"
    )

    task2 = KubernetesPodOperator(
        namespace="{{ params.namesoace_to_run }}",
        image="docker.gbif.org/hadoop-integration-example:0.1.8",
        name="relocate-data",
        volumes=[hadoop_env_volume],
        volume_mounts=[hadoop_env_mounts],
        do_xcom_push=True,
        is_delete_operator_pod=True,
        in_cluster=True,
        task_id="data-relocator",
        get_logs=True,
    )

    task1 >> task2 >> task4 >> task5 >> task6