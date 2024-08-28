# Olympe Helm Chart

# Description

# Prerequisites

- Kubernetes (k3d,k3s,minikube, etc) >= v1.24
- Kubectl: https://kubernetes.io/docs/tasks/tools/#kubectl

# About Neo4j
Default Olympe installation is using Neo4j Community as database engine. Be aware that **Neo4j Enterprise is a licensed product**. Please read the [official license documentation](https://neo4j.com/licensing)

# Installation

## Basic Installation

- Add the repository
```
helm repo add olympe https://olympeio.github.io/olympe-helm/
```
- Install this Helm chart
```
name=<your project name>
helm install $name olympe/olympe \
 --namespace $name \
 --create-namespace \
 --wait
```

This process will run the frontend and backend, as well as load the default patches required for Olympe to work. You can then access Draw by following the process described on the outputed notes

## Upgrade
- Update the repositories
```
helm repo update
```
- Use the `helm upgrade` command:
```
helm upgrade $name olympe/olympe \
  --namespace $name
```

# Build and deploy your own code

> :warning: **About unsaved data**: Data that are not snapshooted will be wiped during the update process. Please [check below](#configure-a-snapshooter) how to snapshot your data

## Olympe Project Template
- Clone the [Olympe-Project-Template](https://github.com/olympeio/olympe-project-template) git repository
- Follow the repository instructions to build your code

## Deploy CodeAsData from your local computer
- Delete the current patches:
```
kubectl exec \
--namespace $name \
$(kubectl get pod --namespace $name -l app.kubernetes.io/component=orchestrator \
  --no-headers \
  -o custom-columns=":metadata.name") \
 -- sh -c 'rm -rf /patches/*'
```
- From your local olympe template directory, compress and copy your built Code As Data to the orchestrator:
```
tar -czvf patches.tar.gz -C dist/codeAsData . &&\
kubectl cp --namespace $name patches.tar.gz \
 $(kubectl get pod --namespace $name -l app.kubernetes.io/component=orchestrator \
 --no-headers -o custom-columns=":metadata.name"):/patches
```
- Extract the copied archive
```
kubectl exec \
--namespace $name \
$(kubectl get pod --namespace $name -l app.kubernetes.io/component=orchestrator \
  --no-headers \
  -o custom-columns=":metadata.name") \
 -- sh -c 'tar -xzvf /patches/patches.tar.gz -C /patches && rm /patches/patches.tar.gz'
```
- Once finished, run the update job:
```
kubectl delete job --namespace $name -l app.kubernetes.io/part-of=toolkit --ignore-not-found
helm template $name olympe/olympe \
 --namespace $name \
 --set orchestrator.initInstall.command=update \
 -s templates/init-install.yml | kubectl apply --namespace $name -f -
```

## Deploy CodeAsData using a Docker image
- Build and push the codeAsData image
```
docker_registry=<your docker registry>
codeasdata_image=<your codeasdata image name>
tag=<the tag of your codeasdata>
docker build -t $docker_registry/$codeasdata_image:$tag \
 --build-arg="SOURCES_PATH=runDraw/dist/codeAsData" \
 -f docker/codeasdata.Dockerfile .
docker push $docker_registry/$codeasdata_image:$tag
```
- Deploy CodeAsData
```
kubectl delete job --namespace $name $name-olympe-codeasdata --ignore-not-found
helm template $name olympe/olympe \
 --namespace $name \
 --set codeAsData.image.repository=$docker_registry \
 --set codeAsData.image.name=$codeasdata_image \
 --set codeAsData.image.tag=$tag \
 -s templates/init-codeasdata.yml | kubectl apply --namespace $name -f -
```
- Once the job is finished, run the update job
```
kubectl delete job --namespace $name $name-olympe-install --ignore-not-found
helm template $name olympe/olympe \
 --namespace $name \
 --set orchestrator.initInstall.command=update \
 -s templates/init-install.yml | kubectl apply --namespace $name -f -
```

## Configure a Snapshooter
A Snapshooter is a CronJob that will download and save the code as data into patches (json files) from a deployed environment to a git repository. You will need the following information to configure it:
- **root tags**: You can get the root tag of your application(s) by opening it in Draw. the tag will be in the URL\n. You can snapshoot multiple tags (e.g. `["018a88a4d5312b1501c6","018a88a4d5312b1501c6"]`)
- **git repository**: https link to repository with authentication token (e.g. `https://gitlab-token:****@gitlab.mycompany.com/my-project.git`)
- **branch**: an existing branch on the selected git repository (e.g. `snapshot`)

### With config key
- Enable the snapshooter in values.yaml
```
repo=<link to git repository>
branch=<branch>
rootTags=<list of root tags>
cat <<EOF | helm upgrade $name olympe/olympe --namespace $name --reuse-values -f -
snapshooters:
  - name: $name
    schedule: "45 12 * * *" # cron syntax
    config: |-
      [
        {
          "snapshooter": {
            "name": "$name",
            "rootTags": $rootTags,
            "outputDir": "snapshot"
          },
          "git": {
            "repo": "$repo",
            "branch": "$branch",
            "commitMessage": "Snapshoted at {date} in {folder}"
          }
        }
      ]
EOF
```
### With custom secret
If you don't want sensitive data in you helm values, you can also create the secret separately

- Create a secret with the following configuration:
```
repo=<link to git repository>
branch=<branch>
rootTags=<list of root tags>
cat <<EOF | kubectl apply --namespace $name -f -
apiVersion: v1
kind: Secret
metadata:
  name: $name-olympe-snapshooter-config
type: Opaque
stringData:
  $name.json: |-
    [
      {
        "snapshooter": {
          "name": "$name",
          "rootTags": $rootTags,
          "outputDir": "snapshot"
        },
        "git": {
          "repo": "$repo",
          "branch": "$branch",
          "commitMessage": "Snapshoted at {date} in {folder}"
        }
      }
    ]
EOF
```

- Enable the snapshooter in values.yaml
```
cat <<EOF | helm upgrade $name olympe/olympe --namespace $name --reuse-values -f -
snapshooters:
  - name: $name
    schedule: "45 12 * * *" # cron syntax
EOF
```

## Change credentials
- Create a secret named `orchestrator-default-secret` in the correct namespace with your new credentials. You can setup only `DRAW_PASSWORD`, `DRAW_USERNAME` or both of them.
```
cat <<EOF | kubectl apply --namespace $name -f -
apiVersion: v1
kind: Secret
metadata:
  name: orchestrator-default-secret
type: Opaque
stringData:
  DRAW_USERNAME: <username>
  DRAW_PASSWORD: ****
EOF
```
- Restart the orchestrator
```
kubectl rollout restart --namespace $name deploy/$name-olympe-orchestrator
```
- Execute the updateUser job
```
kubectl delete job --namespace $name -l app.kubernetes.io/part-of=toolkit --ignore-not-found
helm template $name olympe/olympe \
 --namespace $name \
 --set orchestrator.initInstall.command=updateUser \
 -s templates/init-install.yml | kubectl apply --namespace $name -f -
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | rabbitmq | 14.3.2 |
| https://helm.neo4j.com/neo4j | neo4j(neo4j-standalone) | 4.4.33 |

## Values
**Keys without a description are not meant to be changed**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| acceptLicenseAgreement | string | `"no"` | Please check the license agreement: https:// |
| additionalIngress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| additionalIngress.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"36000"` |  |
| additionalIngress.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"36000"` |  |
| additionalIngress.annotations."nginx.ingress.kubernetes.io/proxy-send-timeout" | string | `"36000"` |  |
| additionalIngress.enabled | bool | `false` |  |
| additionalIngress.prefix | string | `"preview."` |  |
| additionalServices.enabled | bool | `false` |  |
| codeAsData.image.name | string | `"codeasdata"` |  |
| codeAsData.image.repository | string | `"olympeio"` |  |
| codeAsData.podSecurityContext.runAsUser | int | `0` |  |
| codeAsData.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| enabled | bool | `true` | Define if a project is enabled or not. If not, replicas will be set to 0 but data will be kept |
| frontend.additionalConfig | string | `""` | additional frontend configuration |
| frontend.affinity | object | `{}` | setup affinity for the frontend. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| frontend.containerSecurityContext | object | `{"allowPrivilegeEscalation":false}` | defines privilege and access control settings for the frontend on Container level. |
| frontend.image | object | `{"name":"frontend","repository":"olympeio"}` | frontend image |
| frontend.nodeSelector | object | `{}` | setup nodeSelector for the frontend. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| frontend.podSecurityContext | object | `{"runAsUser":101}` | defines privilege and access control settings for the frontend on Pod level. |
| frontend.port | int | `80` | frontend port |
| frontend.previewPort | int | `85` | frontend preview port |
| frontend.previewService.enabled | bool | `false` |  |
| frontend.previewService.port | int | `85` |  |
| frontend.previewService.suffix | string | `"preview"` |  |
| frontend.rabbitmq.host | string | `"rabbitmq"` |  |
| frontend.rabbitmq.mqttPort | int | `15675` |  |
| frontend.replicas | int | `1` | Number of frontend replicas |
| frontend.resources.limits | string | `nil` | frontend memory request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) memory: "100Mi" -- frontend CPU request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) cpu: "50m" |
| frontend.resources.requests | string | `nil` |  |
| frontend.tolerations | list | `[]` | setup tolerations for the frontend. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| fullnameOverride | string | `""` | fully override release name |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| ingress | object | `{"annotations":{"kubernetes.io/ingress.class":"nginx","nginx.ingress.kubernetes.io/proxy-connect-timeout":"36000","nginx.ingress.kubernetes.io/proxy-read-timeout":"36000","nginx.ingress.kubernetes.io/proxy-send-timeout":"36000"},"enabled":false,"extraPaths":[],"hosts":["olympe.local"],"previewHosts":["preview.olympe.local"],"tls":[{"hosts":[],"secretName":null}]}` | Ingress configuration |
| nameOverride | string | `""` | partially override realease name |
| neo4j.enabled | bool | `true` |  |
| neo4j.fullnameOverride | string | `"neo4j"` |  |
| neo4j.image.customImage | string | `"olympeio/database:v2.8.2"` |  |
| neo4j.image.customImage | string | `"olympeio/database:v2.9.1"` |  |
| neo4j.neo4j.password | string | `"olympe"` |  |
| neo4j.services.neo4j.spec.type | string | `"ClusterIP"` |  |
| neo4j.volumes.data.defaultStorageClass.requests.storage | string | `"20Gi"` |  |
| neo4j.volumes.data.mode | string | `"defaultStorageClass"` |  |
| networkPolicies.additionalRules | list | `[]` |  |
| networkPolicies.defaultRules | list | `[]` |  |
| networkPolicies.enabled | bool | `false` | Define if network policies are enabled globally (including service apps)  |
| nodes.dataVolume.accessModes[0] | string | `"ReadWriteOnce"` |  |
| orchestrator.affinity | object | `{}` | setup affinity for the orchestrator. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| orchestrator.clusterType | string | `"none"` | Orchestrator cluster type. Can be "none", "infinispan" or "hazelcast" |
| orchestrator.containerSecurityContext | object | `{"allowPrivilegeEscalation":false}` | defines privilege and access control settings for the Orchestrator on Container level. |
| orchestrator.dataVolume | object | `{"accessModes":["ReadWriteOnce"],"backupData":{},"fileService":{},"patches":{}}` | setup dataVolume for the frontend |
| orchestrator.env | string | `nil` | Orchestrator environment variables (in statefulset) |
| orchestrator.existingSecret | string | `""` |  |
| orchestrator.haEnabled | bool | `false` | Orchestrator HA setup |
| orchestrator.image | object | `{"name":"orchestrator","repository":"olympeio","tag":"7.3.3"}` | Orchestrator image |
| orchestrator.image | object | `{"name":"orchestrator","repository":"olympeio","tag":"7.4.0"}` | Orchestrator image |
| orchestrator.initInstall | object | `{"command":"install","enabled":true}` | Toggle codeAsData install during chart installation (only executed at creation) |
| orchestrator.livenessProbe.failureThreshold | int | `10` |  |
| orchestrator.livenessProbe.httpGet.path | string | `"/readiness"` |  |
| orchestrator.livenessProbe.httpGet.port | int | `8082` |  |
| orchestrator.neo4j.createDB | bool | `true` | Toggle createdb execution at project creation only |
| orchestrator.neo4j.dbName | string | `nil` | database name of the project (defaults to project name without hyphen) |
| orchestrator.neo4j.dbUserPassword | string | `"olympe"` | database user password of the project (defaults to a 12 characters randomly generated string) |
| orchestrator.neo4j.dbUsername | string | `"neo4j"` | database username of the project (defaults to project name without hyphen) |
| orchestrator.neo4j.hostname | string | `nil` | hostname of Neo4j (default to project cluster) |
| orchestrator.neo4j.protocol | string | `"bolt"` | protocol |
| orchestrator.neo4j.rootPassword | string | `"password1"` | shared neo4j root password |
| orchestrator.nodeSelector | object | `{}` | setup nodeSelector for the orchestrator. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| orchestrator.podSecurityContext | object | `{"runAsUser":1000}` | defines privilege and access control settings for the Orchestrator on Pod level. |
| orchestrator.port | int | `8080` |  |
| orchestrator.previewService.enabled | bool | `false` |  |
| orchestrator.previewService.port | int | `8080` |  |
| orchestrator.previewService.suffix | string | `"preview"` |  |
| orchestrator.prometheus | object | `{"enabled":false,"serviceMonitor":{"additionalLabels":{},"annotations":{},"enabled":false,"interval":"30s","metricRelabelings":[],"namespace":"","relabelings":[],"scheme":"","selector":{},"tlsConfig":{}}}` | enable Prometheus metrics |
| orchestrator.prometheus.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| orchestrator.prometheus.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| orchestrator.prometheus.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| orchestrator.prometheus.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| orchestrator.prometheus.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| orchestrator.prometheus.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| orchestrator.prometheus.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| orchestrator.prometheus.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| orchestrator.prometheus.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| orchestrator.prometheus.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| orchestrator.rabbitmq.host | string | `"rabbitmq"` | rabbitMQ host |
| orchestrator.rabbitmq.orchestratorPassword | string | `"guest"` | rabbitMQ orchestrator password |
| orchestrator.rabbitmq.orchestratorUsername | string | `"guest"` | rabbitMQ orchestrator username |
| orchestrator.rabbitmq.password | string | `"guest"` | rabbitMQ password |
| orchestrator.rabbitmq.port | int | `5672` | rabbitMQ port |
| orchestrator.rabbitmq.username | string | `"guest"` | rabbitMQ username |
| orchestrator.replicas | int | `1` | Number of orchestrator replicas |
| orchestrator.resources.limits | string | `nil` | Orchestrator memory request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) memory: "600Mi" -- Orchestrator CPU request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) cpu: "100m" |
| orchestrator.resources.requests | string | `nil` |  |
| orchestrator.secretRef | string | `nil` | secretRef value for orchestrator |
| orchestrator.startupProbe.failureThreshold | int | `10` |  |
| orchestrator.startupProbe.httpGet.path | string | `"/readiness"` |  |
| orchestrator.startupProbe.httpGet.port | int | `8082` |  |
| orchestrator.tolerations | list | `[]` | setup tolerations for the orchestrator. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| rabbitmq.auth.password | string | `"guest"` |  |
| rabbitmq.auth.username | string | `"guest"` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.extraConfiguration | string | `"default_vhost = orchestrator\ndefault_permissions.configure = .*\ndefault_permissions.read = .*\ndefault_permissions.write = .*\nauth_backends.1         = internal\nauth_backends.2         = http\nauth_http.http_method   = post\nauth_http.user_path     = http://orchestrator:8080/auth/user\nauth_http.vhost_path    = http://orchestrator:8080/auth/vhost\nauth_http.resource_path = http://orchestrator:8080/auth/resource\nauth_http.topic_path    = http://orchestrator:8080/auth/topic"` |  |
| rabbitmq.extraPlugins[0] | string | `"rabbitmq_web_mqtt"` |  |
| rabbitmq.extraPlugins[1] | string | `"rabbitmq_auth_mechanism_ssl"` |  |
| rabbitmq.extraPlugins[2] | string | `"rabbitmq_auth_backend_cache"` |  |
| rabbitmq.extraPlugins[3] | string | `"rabbitmq_auth_backend_http"` |  |
| rabbitmq.fullnameOverride | string | `"rabbitmq"` |  |
| rabbitmq.service.extraPorts[0].name | string | `"mqtt"` |  |
| rabbitmq.service.extraPorts[0].port | int | `15675` |  |
| rabbitmq.service.extraPorts[0].targetPort | int | `15675` |  |
| service | object | `{"port":80,"type":"ClusterIP"}` | Frontend service configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceApps | object | `{}` | Service Apps configuration. Please see the example folders for more details |
| serviceAppsDefaultPort | int | `2015` |  |
| serviceAppsImage | string | `"node:14.21.3-slim"` | Default Service Apps image |
| serviceAppsPreviewServices.enabled | bool | `false` |  |
| serviceAppsPreviewServices.suffix | string | `"preview"` |  |
| snapshooters | list | `[]` | Snapshooters configuration, You can have multiple of them, each with the following values:<br /> - name: string, mandatory - Name of the snapshooter <br />    schedule: string, mandatory - schedule (cron format) <br />    config: string, json configuration. Please read documentation for examples (can't be used with secretName key below) <br />    secretName: string, name of the secret containing the configuration (can't be used with config key above) <br />    resources <br />      requests: <br />        memory: string, default "200Mi" <br />        cpu: string, default "100m" <br />      limits: <br />        memory: string, default "1000Mi" <br />        cpu: string, default "200m" <br /> |
| toolkit.cronJobs | object | `{"garbageCollector":{"args":["startGC"],"command":"startGC","resources":{"limits":{"cpu":"100m","memory":"100Mi"},"requests":{"cpu":"100m","memory":"100Mi"}},"schedule":"5 1 * * 0","suspend":false}}` | available values are:     - help     - snapshot     - snapshotUsers     - snapshotBusinessData     - restoreUsers     - restoreBusinessData     - reset     - checkDB     - startGC     - statsDB     - maintenance     - updateUser      |
| toolkit.image | object | `{"name":"toolkit","repository":"olympeio","tag":"1.1.0"}` | Olympe Toolkit image |
| toolkit.podSecurityContext | object | `{"runAsUser":0}` | defines privilege and access control settings for the Olympe Tools on Pod level. |
| upgradeScript.schedule | string | `"5 1 * * 0"` |  |
