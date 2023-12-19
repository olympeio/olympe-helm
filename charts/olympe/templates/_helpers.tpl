{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "olympe.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "olympe.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "olympe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "olympe.labels" -}}
helm.sh/chart: {{ include "olympe.chart" . }}
helm.sh/chart-version: {{ .Chart.Version }}
{{ include "olympe.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "olympe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "olympe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "olympe.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "olympe.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Looks if there's an existing secret and reuse its password. If not it generates
new password and use it.
*/}}
{{- define "olympe.drawPassword" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-orchestrator-secret" (include "olympe.fullname" .) | trunc 63 | trimSuffix "-")) -}}
  {{- if $secret -}}
    {{-  index $secret "data" "DRAW_PASSWORD" -}}
  {{- else -}}
    {{- (randAlphaNum 20) | b64enc | quote -}}
  {{- end -}}
{{- end -}}


{{- define "olympe.serviceApps.containers" }}
containers:
  - name: {{ .serviceAppName }}
    workingDir: /home/node/app/
    securityContext:
      allowPrivilegeEscalation: false
    image: {{ default .defaultImage .serviceApp.image }}
    imagePullPolicy: {{ .pullPolicy }}
    ports:
      - protocol: TCP
        containerPort: 3141
    {{- if .serviceApp.webservices }}
      - protocol: TCP
        containerPort: {{ .defaultPort }}
    {{- end }}
    {{ if .serviceApp.ports }}
      {{ range .serviceApp.ports }}
      - containerPort: {{ .targetPort }}
      {{- end }}
    {{- end }}
    resources:
      {{- toYaml .serviceApp.resources | nindent 6 }}
    env:
      - name: ORCHESTRATOR_HOST
        value: orchestrator
      - name: ORCHESTRATOR_PORT
        value: "8080"
      - name: ORCHESTRATOR_SSL
        value: "false"
      {{- with (first .hosts) }}
      - name: APP_HOSTNAME
        value: {{ . }}
      {{- end }}
      - name: JS_SCRIPT
        value: /home/node/app/main.js
    {{- if .serviceApp.env }}
      {{- toYaml .serviceApp.env | nindent 6 }}
    {{ end }}
    envFrom:
      {{- if .serviceApp.configMapData }}
      {{- if gt (len .serviceApp.configMapData) 0 }}
      - configMapRef:
          name: {{ printf "%s-config" .serviceAppName }}
      {{- end }}
      {{- end }}
      {{- if .serviceApp.secretData }}
      {{- if gt (len .serviceApp.secretData) 0 }}
      - secretRef:
          name: {{ printf "%s-secret" .serviceAppName }}
      {{- end }}
      {{- end }}
    volumeMounts:
      - mountPath: /test
        name: test-volume
      {{- if .serviceApp.oConfig }}
      - name: backend-oconfig
        mountPath: /home/node/app/conf.d
      {{- end }}
      {{ if .serviceApp.volumeMounts }}
        {{- toYaml .serviceApp.volumeMounts | nindent 6 }}
      {{- end }}
    livenessProbe:
      {{- if .serviceApp.enableDefaultProbe }}
      httpGet:
        path: /readiness
        port: 3141
      timeoutSeconds: {{ default 7 ((.serviceApp.livenessProbe).timeoutSeconds) }}
      initialDelaySeconds: {{ default 45 ((.serviceApp.livenessProbe).initialDelaySeconds) }}
      failureThreshold: {{ default 3 ((.serviceApp.startupProbe).failureThreshold) }}
      {{- else }}
      {{- toYaml .serviceApp.livenessProbe | nindent 6 }}
      {{- end }}
    readinessProbe:
      {{- toYaml .serviceApp.readinessProbe | nindent 6 }}
    startupProbe:
      {{- if .serviceApp.enableDefaultProbe }}
      httpGet:
        path: /readiness
        port: 3141
      timeoutSeconds: {{ default 7 ((.serviceApp.startupProbe).timeoutSeconds) }}
      initialDelaySeconds: {{ default 5 ((.serviceApp.startupProbe).initialDelaySeconds) }}
      failureThreshold: {{ default 10 ((.serviceApp.startupProbe).failureThreshold) }}
      {{- else }}
      {{- toYaml .serviceApp.startupProbe | nindent 6 }}
      {{- end }}
{{- end }}

{{- define "olympe.serviceApps.volumes" }}
volumes:
  - name: test-volume
    emptyDir: {}
  {{- if .serviceApp.oConfig }}
  - name: backend-oconfig
    secret:
      secretName: {{ printf "%s-%s-oconfig" (include "olympe.fullname" .root) .serviceAppName | trunc 63 | trimSuffix "-" }}
  {{- end }}
  {{ if .serviceApp.volumes }}
  {{- toYaml .serviceApp.volumes | nindent 2 }}
  {{- end }}
{{- end }}

{{- define "magda.var_dump" -}}
{{- . | mustToPrettyJson | printf "\nThe JSON output of the dumped var is: \n%s" | fail }}
{{- end -}}