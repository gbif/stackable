{{- /*
Standard Sparkapplication to import in different sub charts, uses values to determine how final chart looks.
*/}}
{{- define "gbif-chart-lib.sparkapplication.tpl" }}
apiVersion: spark.stackable.tech/v1alpha1
kind: SparkApplication
metadata:
  name: {{ include "gbif-chart-lib.fullname" . }}
  labels:
    {{- include "gbif-chart-lib.labels" . | nindent 4 }}
spec:
  version: {{ .Chart.AppVersion | quote }}
{{- if .Values.image }}
  image: {{ cat .Values.image.repository .Values.image.name ":" .Values.image.version | nospace }}
{{- else }}
  image: ""
{{- end }}
  sparkImage:
    productVersion: {{ .Values.stackProduct }}
    stackableVersion: {{ .Values.stackVersion }}
  mode: cluster
  mainApplicationFile: local:///stackable/spark/jobs/{{ .Values.image.name }}.jar
  mainClass: {{ .Values.mainClass }}
{{- if .Values.logging.enabled }}
  vectorAggregatorConfigMapName: {{ .Values.logging.discoveryMap }}
{{- end }}
{{- if .Values.bucket }}
  s3connection:
    inline:
      host: {{ .Values.bucket.connection.host }}
      port: {{ .Values.bucket.connection.port }}
      accessStyle: Path
      credentials:
        secretClass: {{ .Values.bucket.connection.sparkHistoryName }}-credentials-class
  logFileDirectory:
    s3:
      prefix: {{ .Values.bucket.prefix }}
      bucket:
        inline:
          bucketName: {{ .Values.bucket.name }}     
{{- end }}
{{- if .Values.args }}
  args:
{{- tpl (.Values.args | toYaml) . | nindent 4 }}
{{- end }}
{{- if .Values.deps }}
  deps:
{{- if .Values.deps.repositories }}
    repositories:
{{- tpl (.Values.deps.repositories | toYaml) . | nindent 6 }}
{{- end }}
{{- if .Values.deps.packages }}
    packages:
{{- tpl (.Values.deps.packages | toYaml) . | nindent 6 }}
{{- end }}
{{- end }}
{{- if .Values.sparkConf }}
  sparkConf:
{{- $standardConf := fromYaml (include "gbif-chart-lib.sparkStandardConf" .) }}
{{- (merge .Values.sparkConf $standardConf) | toYaml | nindent 4 }}
{{- end }}
  volumes:
{{- /*
The template assumes that a sparkjob has one config map that default gets mapped into the spark pods.
If something different is required either use the customProperty to confgiure it or overwrite it within the file including the template
*/}}
{{- if not .Values.customProperties }}
    - name: gbif-config
      configMap:
        name: {{ include "gbif-chart-lib.name" . }}-conf
{{- end }}
{{- if .Values.customProperties }}
    - name: custom-proerties
      configMap:
        name: {{ .Values.customProperties.configmapName }}
{{- end }}
{{- if and .Values.hdfs .Values.hdfs.clusterName }}
    - name: hdfs-env
      configMap:
        name: {{ .Values.hdfs.clusterName }}
        items:
        - key: core-site.xml
          path: core-site.xml
        - key: hdfs-site.xml
          path: hdfs-site.xml
{{- end }}
{{- if and .Values.hive .Values.hive.clusterName }}
    - name: hive-env
      configMap:
        name: {{ .Values.hive.clusterName }}-custom
        items:
        - key: hive-site.xml
          path: hive-site.xml
{{- end }}
{{- if and .Values.hbase .Values.hbase.clusterName }}
    - name: hbase-env
      configMap:
        name: {{ .Values.hbase.clusterName }}
        items:
        - key: hbase-site.xml
          path: hbase-site.xml
{{- end }}
  driver:
    config:
      resources:
        cpu:
          min: "{{ .Values.nodes.driver.cpu.min }}"
          max: "{{ .Values.nodes.driver.cpu.max }}"
        memory:
          limit: "{{ .Values.nodes.driver.memory }}"
{{- if .Values.logging.enabled  }}
      logging:
        enableVectorAgent: true
        containers:
          vector:
            file:
              level: {{ .Values.logging.vectorLogLevel }}
          spark:
            console:
              level: {{ .Values.nodes.driver.logLevel }}
            file:
              level: {{ .Values.nodes.driver.logLevel }}
            loggers:
              ROOT:
                level: {{ .Values.nodes.driver.logLevel }}
{{- end }}
      volumeMounts:
{{- if not .Values.customProperties }}
        - name: gbif-config
          mountPath: /etc/gbif/config.yaml
          subPath: config.yaml
{{- end }}
{{- if .Values.customProperties }}
        - name: custom-proerties
          mountPath: {{ .Values.customProperties.path }}{{ .Values.customProperties.file }}
          subPath: {{ .Values.customProperties.file }}
{{- end }}
{{- if and .Values.hdfs .Values.hdfs.clusterName }}
        - name: hdfs-env
          mountPath: /etc/hadoop/conf/core-site.xml
          subPath: core-site.xml
        - name: hdfs-env
          mountPath: /etc/hadoop/conf/hdfs-site.xml
          subPath: hdfs-site.xml
{{- end }}
{{- if and .Values.hive .Values.hive.clusterName }}
        - name: hive-env
          mountPath: /etc/hadoop/conf/hive-site.xml
          subPath: hive-site.xml
{{- end }}
{{- if and .Values.hbase .Values.hbase.clusterName }}
        - name: hbase-env
          mountPath: /etc/hadoop/conf/hbase-site.xml
          subPath: hbase-site.xml
{{- end }}
  executor:
{{- if .Values.yunikorn.dynamicResources.enabled }}
    replicas: {{ .Values.yunikorn.dynamicResources.executor.min }}
{{- else }}
    replicas: {{ .Values.nodes.executor.replicas }}
{{- end }}
    config:
      resources:
        cpu:
          min: "{{ .Values.nodes.executor.cpu.min }}"
          max: "{{ .Values.nodes.executor.cpu.max }}"
        memory:
          limit: "{{ .Values.nodes.executor.memory }}"
{{- if .Values.logging.enabled  }}
      logging:
        enableVectorAgent: true
        containers:
          vector:
            file:
              level: {{ .Values.logging.vectorLogLevel }}
          spark:
            console:
              level: {{ .Values.nodes.executor.logLevel }}
            file:
              level: {{ .Values.nodes.executor.logLevel }}
            loggers:
              ROOT:
                level: {{ .Values.nodes.executor.logLevel }}
{{- end }}
      volumeMounts:
{{- if not .Values.customProperties }}
        - name: gbif-config
          mountPath: /etc/gbif/config.yaml
          subPath: config.yaml
{{- end }}
{{- if .Values.customProperties }}
        - name: custom-proerties
          mountPath: {{ .Values.customProperties.path }}{{ .Values.customProperties.file }}
          subPath: {{ .Values.customProperties.file }}
{{- end }}
{{- if and .Values.hdfs .Values.hdfs.clusterName }}
        - name: hdfs-env
          mountPath: /etc/hadoop/conf/core-site.xml
          subPath: core-site.xml
        - name: hdfs-env
          mountPath: /etc/hadoop/conf/hdfs-site.xml
          subPath: hdfs-site.xml
{{- end }}
{{- if and .Values.hive .Values.hive.clusterName }}
        - name: hive-env
          mountPath: /etc/hadoop/conf/hive-site.xml
          subPath: hive-site.xml
{{- end }}
{{- if and .Values.hbase .Values.hbase.clusterName }}
        - name: hbase-env
          mountPath: /etc/hadoop/conf/hbase-site.xml
          subPath: hbase-site.xml
{{- end }}

{{- end }}

{{- define "gbif-chart-lib.sparkapplicationCollected" }}
{{- $mainTemplate := fromYaml (include "gbif-chart-lib.sparkapplication.tpl" .) }}
{{- $podOverrides := fromYaml (include "gbif-chart-lib.sparkPodOverride" .) }}
{{- $total := merge $mainTemplate $podOverrides }}
{{ toYaml $total }}
{{- end }}

{{- define "gbif-chart-lib.sparkapplication" }}
{{ include "gbif-chart-list.util.merge" (append . "gbif-chart-lib.sparkapplicationCollected") }}
{{- end }}