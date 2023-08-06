{{- /*
Merge util made from the Helm documentation
Takes the generic template and merges it with a implemented version of the template
*/}}
{{- define "gbif-chart-list.util.merge" -}}
{{- $top := first . -}}
{{- $overrides := fromYaml (include (index . 1) $top) | default (dict ) -}}
{{- $tpl := fromYaml (include (index . 2) $top) | default (dict ) -}}
{{- toYaml (merge $overrides $tpl) -}}
{{- end -}}

{{- /*
Takes a list in string representation (when it parsed from the values file) and recreates it as a list of items with single quote.
This is needed of the cmd fields in pods.
*/}}
{{- define "gbif-chart-list.util.parse" -}}
{{- $newList := list -}}
{{- range .Values.command -}}
{{- $newList = append $newList . -}}
{{- end -}}
{{- toJson $newList -}}
{{- end -}}