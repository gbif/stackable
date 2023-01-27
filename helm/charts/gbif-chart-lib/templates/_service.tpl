{{/*
Basic service template to create fixed NodePorts for the infrastructure we need exposed to VMs without our servers only.
All node ports is fixed to fit within the default range for nodePorts.
*/}}

{{- define "gbif-chart-list.service.tpl" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name | printf "%s-%s" "gbif-node" }}
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: {{ include "gbif-chart-lib.name" . }}
  ports:
  - protocol: TCP
    port: {{ .Values.appPort }}
    targetPort: {{ .Values.appPort }}
    nodeport: {{ .Values.nodePort }}
{{- end -}}