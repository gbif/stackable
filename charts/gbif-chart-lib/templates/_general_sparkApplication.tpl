{{/*
Standard Sparkapplication to import in different sub charts, uses values to determine how final chart looks.
*/}}
{{- define "gbif-chart-lib.name" -}}
apiVersion: spark.stackable.tech/v1alpha1
kind: SparkApplication
metadata:
  name: {{ include "gbif-chart-lib.fullname" . }}
  labels:
    {{- include "gbif-chart-lib.labels" . | nindent 4 }}
spec:
  version: {{ .Values.version }}
  image: docker.gbif.org/{{ .Values.component }}:{{ .Values.version }}
{{/*
Add comments plus make the stackable version configuable
*/}}
  sparkImage: docker.stackable.tech/stackable/spark-k8s:3.3.0-stackable23.7.0
  mode: cluster
  mainApplicationFile: local:///stackable/spark/jobs/{{ .Values.component }}.jar
  mainClass: {{ .Values.main }}
  args:
{{- for arg in .Values.args }}
    - "{{arg}}"
{{- endfor }}
  deps:
    repositories:
      - https://repository.gbif.org/repository/central/
    packages:
      - org.apache.spark:spark-avro_2.12:3.4.0
  sparkConf:
     "spark.driver.extraJavaOptions": "-XX:+UseConcMarkSweepGC"
     "spark.executor.extraJavaOptions": "-XX:+UseConcMarkSweepGC"
     "spark.jars.ivy": "/tmp"
     "spark.broadcast.compress": "true"
     "spark.checkpoint.compress": "true"
     "spark.executor.memoryOverhead": "4096"
     "spark.executor.heartbeatInterval": "10s"
     "spark.network.timeout": "60s"
     "spark.io.compression.codec": "lz4"
     "spark.rdd.compress": "true"
     "spark.driver.extraClassPath": "/etc/hadoop/conf/:/etc/gbif/:/stackable/spark/extra-jars/*"
     "spark.executor.extraClassPath": "/etc/hadoop/conf/:/etc/gbif/:/stackable/spark/extra-jars/*"
     "spark.kubernetes.authenticate.driver.serviceAccountName": "gbif-spark-sa"
{{- if .Values.componentConfig or .Values.hdfsClusterName or .Values.hiveClusterName .Values.hbaseClusterName }}
  volumes:
{{- if .Values.componentConfig }}
    - name: gbif-config
      configMap:
        name: {{ .Values.componentConfig }}-conf
{{- end }}
{{- if .Values.componentProperty }}
    - name: gbif-property
      configMap:
        name: {{ .Values.componentProperty.propertyName }}-conf
{{- end }}
{{- if .Values.hdfsClusterName }}
    - name: hdfs-env
      configMap:
        name: {{ .Values.hdfsClusterName }}
        items:
        - key: core-site.xml
          path: core-site.xml
        - key: hdfs-site.xml
          path: hdfs-site.xml
{{- end }}
{{- if .Values.hiveClusterName }}
    - name: hive-env
      configMap:
        name: {{ .Values.hiveClusterName }}-custom
        items:
        - key: hive-site.xml
          path: hive-site.xml
{{- end }}
{{- if .Values.hbaseClusterName }}
    - name: hbase-env
      configMap:
        name: {{ .Values.hbaseClusterName }}
        items:
        - key: hbase-site.xml
          path: hbase-site.xml
{{- end }}
{{- end }}
  driver:
    resources:
      cpu:
        min: "100m"
        max: "{{ .Values.driverCores }}"
      memory:
        limit: "{{ .Values.driverMemory }}"
    volumeMounts:
{{- if .Values.componentConfig }}
      - name: gbif-config
        mountPath: /etc/gbif/config.yaml
        subPath: config.yaml
{{- end }}
{{- if .Values.componentProperty }}
    - name: gbif-property
      mountPath: {{ .Values.componentProperty.path }}{{ .Values.componentProperty.file }}
      subPath: {{ .Values.componentProperty.file }}
{{- end }}
{{- if .Values.hdfsClusterName }}
      - name: hdfs-env
        mountPath: /etc/hadoop/conf/core-site.xml
        subPath: core-site.xml
      - name: hdfs-env
        mountPath: /etc/hadoop/conf/hdfs-site.xml
        subPath: hdfs-site.xml
{{- end }}
{{- if .Values.hiveClusterName }}
      - name: hive-env
        mountPath: /etc/hadoop/conf/hive-site.xml
        subPath: hive-site.xml
{{- end }}
{{- if .Values.hbaseClusterName }}
      - name: hbase-env
        mountPath: /etc/hadoop/conf/hbase-site.xml
        subPath: hbase-site.xml
{{- end }}
  executor:
    instances: {{ .Values.executorInstances }}
    resources:
      cpu:
        min: "100m"
        max: "{{ .Values.executorCores }}"
      memory:
        limit: "{{ .Values.executorMemory }}"
    volumeMounts:
{{- if .Values.componentConfig }}
      - name: gbif-config
        mountPath: /etc/gbif/config.yaml
        subPath: config.yaml
{{- end }}
{{- if .Values.componentProperty }}
    - name: gbif-property
      mountPath: {{ .Values.componentProperty.path }}{{ .Values.componentProperty.file }}
      subPath: {{ .Values.componentProperty.file }}
{{- end }}
{{- if .Values.hdfsClusterName }}
      - name: hdfs-env
        mountPath: /etc/hadoop/conf/core-site.xml
        subPath: core-site.xml
      - name: hdfs-env
        mountPath: /etc/hadoop/conf/hdfs-site.xml
        subPath: hdfs-site.xml
{{- end }}
{{- if .Values.hiveClusterName }}
      - name: hive-env
        mountPath: /etc/hadoop/conf/hive-site.xml
        subPath: hive-site.xml
{{- end }}
{{- if .Values.hbaseClusterName }}
      - name: hbase-env
        mountPath: /etc/hadoop/conf/hbase-site.xml
        subPath: hbase-site.xml
{{- end }}
{{- end }}