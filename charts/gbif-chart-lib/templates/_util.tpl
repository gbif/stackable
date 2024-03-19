{{- /*
Merge util made from the Helm documentation
Takes the generic template and merges it with a implemented version of the template
*/}}
{{- define "gbif-chart-lib.util.merge" -}}
{{- $top := first . -}}
{{- $overrides := fromYaml (include (index . 1) $top) | default (dict ) -}}
{{- $tpl := fromYaml (include (index . 2) $top) | default (dict ) -}}
{{- toYaml (merge $overrides $tpl) -}}
{{- end -}}

{{- /*
Takes a list in string representation (when it parsed from the values file) and recreates it as a list of items with single quote.
This is needed of the cmd fields in pods.
*/}}
{{- define "gbif-chart-lib.util.parse" -}}
{{- $newList := list -}}
{{- range .Values.command -}}
{{- $newList = append $newList . -}}
{{- end -}}
{{- toJson $newList -}}
{{- end -}}

{{- /*
Ugly template function to calculate yunikorn memory based on provided value.
Currently support these suffixes:
- Gi
- G
- Mi
- M
Hardcoded for 125Mi at the moment
*/}}
{{- define "gbif-chart-lib.calculate-memory" -}}
{{- $originalValue := . -}}
{{- $result := 1000.0 -}}
{{- $suffix := "Gi" -}}
{{- if or (hasSuffix "Gi" $originalValue) (hasSuffix "G" $originalValue) -}}
{{- if (hasSuffix "Gi" $originalValue) -}}
{{- $originalValue = trimSuffix "Gi" $originalValue -}}
{{- $suffix = "Gi" -}}
{{- $result = (addf $originalValue 0.125) -}}
{{- else if (hasSuffix "G" $originalValue) -}}
{{- $originalValue = trimSuffix "G" $originalValue -}}
{{- $suffix = "G" -}}
{{- $result = (addf $originalValue 0.125) -}}
{{- end -}}
{{ printf "%f%s" $result $suffix }}
{{- end -}}
{{- if or (hasSuffix "Mi" $originalValue) (hasSuffix "M" $originalValue) -}}
{{- if (hasSuffix "Mi" $originalValue) -}}
{{- $originalValue = trimSuffix "Mi" $originalValue -}}
{{- $suffix = "Mi" -}}
{{- $result = (add $originalValue 125) -}}
{{- else if (hasSuffix "Mi" $originalValue) -}}
{{- $originalValue = trimSuffix "M" $originalValue -}}
{{- $suffix = "M" -}}
{{- $result = (add $originalValue 125) -}}
{{- end -}}
{{ printf "%d%s" $result $suffix }}
{{- end -}}
{{- end -}}

{{- /*
Ugly template function to calculate yunikorn cpu based on provided value.
Coverts everything whole CPUs into mili.
Hardcoded for 125m at the moment
*/}}
{{- define "gbif-chart-lib.calculate-cpu" -}}
{{- $originalValue := . -}}
{{- $result := 100 -}}
{{- if (hasSuffix "m" $originalValue) -}}
{{- $originalValue = trimSuffix "m" $originalValue -}}
{{- else -}}
{{- $originalValue = mul $originalValue 1000 -}}
{{- end -}}
{{- $result = add $originalValue 125 -}}
{{ printf "%d%s" $result "m" }}
{{- end -}}