from operators.stackable_spark_operator import SparkKubernetesOperator
from sensors.stackable_spark_sensor import SparkKubernetesSensor
from airflow.models.param import Param
from airflow import DAG
from datetime import timedelta
import pendulum

with DAG(
    dag_id='sparkapp_dag',
    schedule_interval='0 0 * * *',
    start_date=pendulum.datetime(2022, 5, 1, tz="Europe/Copenhagen"),
    catchup=False,
    dagrun_timeout=timedelta(minutes=60),
    tags=['spark'],
    params= {
        "namespace_to_run": Param("stack-demo")
        },
) as dag:

    t1 = SparkKubernetesOperator(
        task_id='spark_map_submit',
        namespace = "{{ params.namespace_to_run }}",
        application_file="gbif-map-proces.yaml",
        do_xcom_push=True,
        dag=dag,
    )

    t2 = SparkKubernetesSensor(
        task_id='spark_map_monitor',
        namespace = "{{ params.namespace_to_run }}",
        application_name="{{ task_instance.xcom_pull(task_ids='spark_map_submit')['metadata']['name'] }}",
        poke_interval=5,
        dag=dag,
    )

    t1 >> t2