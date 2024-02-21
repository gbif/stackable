{{- /*
Sub template for calculating the resulting podoverride and merge it
*/}}
{{- define "gbif-chart-lib.podMetadata.tpl" }}
{{- if .Values.yunikorn.enabled }}
spec:
    job:
        podOverrides:
            metadata:
                annotations:
                    yunikorn.apache.org/task-group-name: "{{ include "gbif-chart-lib.yunikornName" . }}-submit"
                    yunikorn.apache.org/gangSchedulingStyle: "hard"
                    yunikorn.apache.org/task-groups: |-
                        [{
                        "name": "{{ include "gbif-chart-lib.yunikornName" . }}-submit",
                        "minMember": 1,
                        "maxMember": 1
                        },
                        {
                        "name": "{{ include "gbif-chart-lib.yunikornName" . }}-driver",
                        "minMember": 1,
                        "maxMember": 1,
                        "minResource": {
                            "cpu": "{{ .Values.nodes.driver.cpu.min }}",
                            "memory": "{{ .Values.nodes.driver.memory }}"
                        },
                        "maxResource": {
                            "cpu": "{{ .Values.nodes.driver.cpu.max }}",
                            "memory": "{{ .Values.nodes.driver.memory }}"
                        }
                        },
                        {
                        "name": "{{ include "gbif-chart-lib.yunikornName" . }}-executor",
{{- if .Values.yunikorn.dynamicResources.enabled }}
                        "minMember": {{ .Values.yunikorn.dynamicResources.executor.min }},
                        "maxMember": {{ .Values.yunikorn.dynamicResources.executor.max }},
{{- else }}
                        "minMember": 1,
                        "maxMember": {{ .Values.nodes.executor.replicas }},
{{- end }}
                        "minResource": {
                            "cpu": "{{ .Values.nodes.executor.cpu.min }}",
                            "memory": "{{ .Values.nodes.executor.memory }}"
                        },
                        "maxResource": {
                            "cpu": "{{ .Values.nodes.executor.cpu.max }}",
                            "memory": "{{ .Values.nodes.executor.memory }}"
                        }
                        },
                        ]
    driver:
        podOverrides:
            metadata:
                annotations:
                    yunikorn.apache.org/task-group-name: "{{ include "gbif-chart-lib.yunikornName" . }}-driver"
                    yunikorn.apache.org/gangSchedulingStyle: "hard"
    executor:
        podOverrides:
            metadata:
                annotations:
                    yunikorn.apache.org/task-group-name: "{{ include "gbif-chart-lib.yunikornName" . }}-executor"
                    yunikorn.apache.org/gangSchedulingStyle: "hard"
{{- end }}
{{- end }}

{{- define "gbif-chart-lib.podSpec.tpl" }}
{{- if and .Values.image (contains "SNAPSHOT" .Values.image.version) }}
spec:
    driver:
        podOverrides:
            spec:
                initContainers:
                - name: job
                  imagePullPolicy: Always
                    
    executor:
        podOverrides:
            spec:
                initContainers:
                - name: job
                  imagePullPolicy: Always
{{- end }}
{{- end }}

{{- define "gbif-chart-lib.sparkPodOverride" }}
{{- $meta := fromYaml (include "gbif-chart-lib.podMetadata.tpl" .) }}
{{- $spec := fromYaml (include "gbif-chart-lib.podSpec.tpl" .) }}
{{- $full := merge $meta $spec }}
{{ toYaml $full }}
{{- end }}

{{- define "gbif-chart-lib.sparkStandardConf" }}
"spark.driver.extraClassPath": "/etc/hadoop/conf/:/stackable/spark/extra-jars/*:/etc/gbif/"
"spark.executor.extraClassPath": "/etc/hadoop/conf/:/stackable/spark/extra-jars/*:/etc/gbif/"
"spark.kubernetes.authenticate.driver.serviceAccountName": "gbif-spark-sa"
{{- if .Values.yunikorn.enabled }}
"spark.kubernetes.scheduler.name": "yunikorn"
"spark.kubernetes.driver.label.queue": {{ .Values.yunikorn.driver.queue }}
"spark.kubernetes.executor.label.queue": {{ .Values.yunikorn.executor.queue }}
"spark.kubernetes.driver.annotation.yunikorn.apache.org/app-id": "{{ include "gbif-chart-lib.yunikornName" . }}"
"spark.kubernetes.executor.annotation.yunikorn.apache.org/app-id": "{{ include "gbif-chart-lib.yunikornName" . }}"
{{- if .Values.yunikorn.dynamicResources.enabled }}
spark.dynamicAllocation.enabled: "true"
spark.dynamicAllocation.initialExecutors: {{ .Values.yunikorn.dynamicResources.executor.initial }}
spark.dynamicAllocation.minExecutors: {{ .Values.yunikorn.dynamicResources.executor.min }}
spark.dynamicAllocation.maxExecutors: {{ .Values.yunikorn.dynamicResources.executor.max }}
{{- end }}
{{- end }}
{{- end }}