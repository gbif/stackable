{{/*
Basic service template to create fixed NodePorts for the infrastructure we need exposed to VMs without our servers only.
All node ports is fixed to fit within the default range for nodePorts.
*/}}

{{- define "gbif-chart-list.nodeport-service.tpl" -}}
{{- range $nodeKey, $nodeValue := .Values.nodes }}
{{- if gt ( len $nodeValue.ports ) 0 }}
apiVersion: v1
kind: Service
metadata:
  name: {{ printf "%s-%s" $nodeKey "nodeport" }}
  namespace: {{ $.Release.Namespace }}
spec:
  type: NodePort
  selector:
    app.kubernetes.io/component: {{ $nodeKey }}
    app.kubernetes.io/instance: {{ include "gbif-chart-lib.name" $ }}
  ports:
{{- range $portKey, $portValue := $nodeValue.ports }}
  - name: {{ $portKey }}
    protocol: TCP
    port: {{ $portValue.appPort }}
    targetPort: {{ $portValue.appPort }}
    nodePort: {{ $portValue.nodePort }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}