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

from airflow.models.baseoperator import BaseOperator
from airflow.utils.decorators import apply_defaults
import logging
from typing import Sequence
from hooks.trino_custom_hook import TrinoCustomHook

# This piece of python code for the Trino provider is original from Trino blog: https://trino.io/blog/2022/07/13/how-to-use-airflow-to-schedule-trino-jobs.html
"""Trino operator for interacting with the Trino cluster"""

def handler(cur):
    cur.fetchall()

class TrinoOperator(BaseOperator):

    template_fields: Sequence[str] = ('sql',)

    @apply_defaults
    def __init__(self, trino_conn_id: str, sql, parameters=None, **kwargs) -> None:
        super().__init__(**kwargs)
        self.trino_conn_id = trino_conn_id
        self.sql = sql
        self.parameters = parameters

    def execute(self, context):
        task_instance = context['task']

        logging.info('Creating Trino connection')
        hook = TrinoCustomHook(trino_conn_id=self.trino_conn_id)

        sql_statements = self.sql

        if isinstance(sql_statements, str):
            sql = list(filter(None,sql_statements.strip().split(';')))

            if len(sql) == 1:
                logging.info('Executing single sql statement')
                sql = sql[0]
                return hook.get_first(sql, parameters=self.parameters)

            if len(sql) > 1:
                logging.info('Executing multiple sql statements')
                return hook.run(sql, autocommit=False, parameters=self.parameters, handler=handler)

        if isinstance(sql_statements, list):
            sql = []
            for sql_statement in sql_statements:
                sql.extend(list(filter(None,sql_statement.strip().split(';'))))

            logging.info('Executing multiple sql statements')
            return hook.run(sql, autocommit=False, parameters=self.parameters, handler=handler)