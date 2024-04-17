{{- /*
Sub template for calculating the resulting podoverride and merge it
*/}}
{{- define "gbif-chart-lib.podMetadata.tpl" }}
{{- if .Values.yunikorn.enabled }}
spec:
  job:
    podOverrides:
      metadata:
        labels:
{{- include "gbif-chart-lib.yunikornLabels" . | indent 10 }}
  driver:
    podOverrides:
      metadata:
        annotations:
          yunikorn.apache.org/task-groups: |-
              [{
              "name": "{{ include "gbif-chart-lib.yunikornName" . }}-driver",
              "minMember": 1,
              "minResource": {
                  "cpu": "{{ include "gbif-chart-lib.calculate-cpu" .Values.nodes.driver.cpu.min }}",
                  "memory": "{{ include "gbif-chart-lib.calculate-memory" .Values.nodes.driver.memory }}"
              }
              },
              {
              "name": "{{ include "gbif-chart-lib.yunikornName" . }}-executor",
{{- if .Values.yunikorn.dynamicResources.enabled }}
              "minMember": {{ .Values.yunikorn.dynamicResources.executor.min }},
{{- else }}
              "minMember": 1
{{- end }}
              "minResource": {
                  "cpu": "{{ include "gbif-chart-lib.calculate-cpu" .Values.nodes.executor.cpu.min }}",
                  "memory": "{{ include "gbif-chart-lib.calculate-memory" .Values.nodes.executor.memory }}"
              }
              }]
          yunikorn.apache.org/task-group-name: "{{ include "gbif-chart-lib.yunikornName" . }}-driver"
          yunikorn.apache.org/gangSchedulingStyle: "hard"
        labels:
{{- include "gbif-chart-lib.yunikornLabels" . | indent 10 }}
  executor:
    podOverrides:
      metadata:
        annotations:
            yunikorn.apache.org/task-group-name: "{{ include "gbif-chart-lib.yunikornName" . }}-executor"
            yunikorn.apache.org/gangSchedulingStyle: "hard"
        labels:
{{- include "gbif-chart-lib.yunikornLabels" . | indent 10 }}
{{- end }}
{{- end }}

{{- define "gbif-chart-lib.podSpec.tpl" }}
{{- if .Values.image.alwaysPull }}
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
{{- if .Values.yunikorn.enabled }}
"spark.kubernetes.scheduler.name": "yunikorn"
"spark.kubernetes.driver.label.queue": "{{ .Values.yunikorn.driver.queue }}"
"spark.kubernetes.executor.label.queue": "{{ .Values.yunikorn.executor.queue }}"
"spark.kubernetes.authenticate.driver.serviceAccountName": "{{ .Values.yunikorn.user }}"
{{- if .Values.yunikorn.dynamicResources.enabled }}
spark.dynamicAllocation.enabled: "true"
spark.dynamicAllocation.initialExecutors: "{{ .Values.yunikorn.dynamicResources.executor.initial }}"
spark.dynamicAllocation.minExecutors: "{{ .Values.yunikorn.dynamicResources.executor.min }}"
spark.dynamicAllocation.maxExecutors: "{{ .Values.yunikorn.dynamicResources.executor.max }}"
spark.dynamicAllocation.shuffleTracking.enabled: "true"
{{- end }}
{{- end }}
{{- end }}