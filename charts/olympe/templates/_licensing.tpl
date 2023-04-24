{{- define "olympe.checkLicenseAgreement" }}
  {{- if ne .Values.acceptLicenseAgreement "yes" }}
    {{- include "olympe.licenseAgreementMessage" .Values.acceptLicenseAgreement | fail }}
  {{- end }}
{{- end }}

{{- define "olympe.licenseAgreementMessage" }}

Please check the Olympe license agreement: https://
Set acceptLicenseAgreement: "yes" when you accepted it.

{{ end -}}