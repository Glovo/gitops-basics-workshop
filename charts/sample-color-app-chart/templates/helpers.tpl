# sample-color-app-chart/templates/_helpers.tpl
{{- define "fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
This template is used to generate the blue-green rollout strategy for the service.
*/}}
{{- define "rollout.blue-green" -}}
blueGreen:
  activeService: {{ include "fullname" . }}-rollout
  previewService: {{ include "fullname" . }}-preview
  autoPromotionEnabled: {{ .Values.strategy.blueGreen.config.autoPromotion }}
  autoPromotionSeconds: {{ .Values.strategy.blueGreen.config.autoPromotionSeconds }}
  scaleDownDelaySeconds: {{ .Values.strategy.blueGreen.config.scaleDownDelaySeconds }}
  activeMetadata:
  {{- toYaml .Values.strategy.blueGreen.config.activeMetadata | nindent 4 }}
  previewMetadata:
  {{- toYaml .Values.strategy.blueGreen.config.previewMetadata | nindent 4 }}
{{- end }}

{{/*
This template is used to generate the canary rollout strategy for the service.
*/}}
{{- define "rollout.canary" -}}
canary: 
  canaryMetadata:
    {{- toYaml .Values.strategy.canary.config.canaryMetadata | nindent 4 }}
  stableMetadata:
    {{- toYaml .Values.strategy.canary.config.stableMetadata | nindent 4 }}
  minPodsPerReplicaSet: {{ .Values.autoscaling.minReplicas }}
  maxSurge: "25%"
  maxUnavailable: {{ .Values.strategy.canary.config.maxUnavailable  }}
  steps:
  {{- toYaml .Values.strategy.canary.steps | nindent 6 }}
{{- end }}
