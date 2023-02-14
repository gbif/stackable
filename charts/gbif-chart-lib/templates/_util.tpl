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