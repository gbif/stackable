import pendulum
from datetime import timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='gbif_test_dag',
    schedule_interval='0 0 * * *',
    start_date=pendulum.datetime(2022, 5, 1, tz="Europa/Copenhagen"),
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