{{/*
Expand the name of the chart.
*/}}
{{- define "gbif-chart-lib.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gbif-chart-lib.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gbif-chart-lib.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gbif-chart-lib.labels" -}}
helm.sh/chart: {{ include "gbif-chart-lib.chart" . }}
{{ include "gbif-chart-lib.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gbif-chart-lib.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gbif-chart-lib.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "gbif-chart-lib.yunikornName" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 54 | trimSuffix "-" }}
{{- else }}
{{- .Values.appName | trunc 54 | trimSuffix "-" }}
{{- end }}
{{- end }}