from airflow.providers.trino.hooks.trino import TrinoHook
from typing import Callable, Optional

# This piece of python code for the Trino provider is original from Trino blog: https://trino.io/blog/2022/07/13/how-to-use-airflow-to-schedule-trino-jobs.html
"""Trino hook for interacting with the Trino cluster"""

def handler(cur):
    cur.fetchall()

class TrinoCustomHook(TrinoHook):

    def run(
        self,
        sql,
        autocommit: bool = False,
        parameters: Optional[dict] = None,
        handler: Optional[Callable] = None,
    ) -> None:
        """:sphinx-autoapi-skip:"""

        return super(TrinoHook, self).run(
            sql=sql, autocommit=autocommit, parameters=parameters, handler=handler
        )