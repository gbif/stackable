{{/*
Basic service template to create fixed NodePorts for the infrastructure we need exposed to VMs without our servers only.
All node ports is fixed to fit within the default range for nodePorts.
*/}}

{{- define "gbif-chart-list.service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ printf "%s-%s" .Release.Name "nodeport" }}
spec:
  type: NodePort
  selector:
    app.kubernetes.io/instance: {{ include "gbif-chart-lib.name" . }}
  ports:
  - name: gbif
    protocol: TCP
    port: {{ .Values.appPort }}
    targetPort: {{ .Values.appPort }}
    nodePort: {{ .Values.nodePort }}
{{- end -}}
{{- define "gbif-chart-list.service" -}}
{{- include "gbif-chart-list.util.merge" (append . "gbif-chart-list.service.tpl") -}}
{{- end -}}