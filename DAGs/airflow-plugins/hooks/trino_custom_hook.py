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