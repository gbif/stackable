from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='gbif_test_dag',
    schedule_interval='0 0 * * *',
    start_date=datetime(year=2022, month=1, day=1, tzinfo=timezone.utc),
    catchup=False,
    dagrun_timeout=timedelta(minutes=60),
    tags=['what', 'is', 'this'],
    params={"my_var": "my_value"}
) as dag:
    stage_1 = BashOperator(
        task_id='stage_1',
        bash_command='echo "I am at stage one"'
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