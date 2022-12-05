from datetime import datetime, timedelta, timezone
from operators import SparkKubernetesOperator
from hooks import SparkKubernetesSensor
from airflow.models import Variable
from airflow import DAG

with DAG(
    dag_id='sparkapp_dag',
    schedule_interval='0 0 * * *',
    start_date=datetime(year=2022, month=1, day=1, tzinfo=timezone.utc),
    catchup=False,
    dagrun_timeout=timedelta(day=7),
    tags=['spark'],
    params={"namespace_to_run": "spark-demo"},
) as dag:

    t1 = SparkKubernetesOperator(
        task_id='spark_map_submit',
        namespace = Variable.get("namespace_to_run"),
        application_file="gbif-map-proces.yaml",
        do_xcom_push=True,
        dag=dag,
    )

    t2 = SparkKubernetesSensor(
        task_id='spark_map_monitor',
        namespace = Variable.get("namespace_to_run"),
        application_name="{{ task_instance.xcom_pull(task_ids='spark_map_submit')['metadata']['name'] }}",
        poke_interval=5,
        dag=dag,
    )

    t1 >> t2