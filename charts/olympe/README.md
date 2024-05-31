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

## Olympe Project Template
- Clone the [Olympe-Project-Template](https://github.com/olympeio/olympe-project-template) git repository
- Follow the repository instructions to build your code

## Deploy CodeAsData from your local computer
Copy your built code as data to the orchestrator:
```
kubectl cp --namespace $name dist/codeAsData/ \
 $(kubectl get pod -n $name -l app.kubernetes.io/component=orchestrator \
 --no-headers -o custom-columns=":metadata.name"):/tmp &&\
kubectl exec --namespace $name deploy/$name-olympe-orchestrator -- \
bash -c "rsync -aci --delete --exclude 'change_log.txt' \
 /tmp/codeAsData/. /patches/ | (grep -E '^[^.c].*[^\/]$' || true) | tee -a /patches/change_log.txt"
```
- Once finished, run the update job:
```
kubectl delete job --namespace $name -l app.kubernetes.io/part-of=toolkit --ignore-not-found
helm template $name olympe/olympe \
 --namespace $name \
 --set orchestrator.initInstall.command=update \
 -s templates/init-install.yml | kubectl apply -n $name -f -
```

## Deploy CodeAsData using a Docker image
- Build and push the codeAsData image
```
docker_registry=<your docker registry>
codeasdata_image=<your codeasdata image name>
tag=<the tag of your codeasdata>
docker build -t $docker_registry/$codeasdata_image:$tag --build-arg="SOURCES_PATH=runDraw/dist/codeAsData" -f docker/codeasdata.Dockerfile .
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
 -s templates/init-codeasdata.yml | kubectl apply -n $name -f -
```
- Once the job is finished, run the update job
```
kubectl delete job --namespace $name $name-olympe-install --ignore-not-found
helm template $name olympe/olympe \
 --namespace $name \
 -s templates/init-install.yml | kubectl apply -n $name -f -
```

# Olympe Toolkit

You can use the Olympe Toolkit image to execute multiple tasks:

- Install: Reset the database to its initial state or to the latest snapshot (if configured)
- Update: Reset the database to its initial state or to the latest snapshot (if configured)
- Snapshooter: Take a snapshot of your instance and backup it to a git repository
- Change credentials: Change the admin user and/or password

## Snapshooter
### With config key
- Enable the snapshooter in values.yaml
```
[...]
snapshooters:
  - name: $name
    schedule: "45 12 * * *" # cron syntax
    secretName: snapshooter-secret
    config |-
      [{
        "name": "$name",
        "rootTags": [<list of root tags>],
        "path": "snapshot",
        "server": {
          "user": "admin",
          "password": "***",
          "host": "<namespace>-orchestrator",
          "port": 8080
        },
        "git":{
          "repo": "https://",
          "branch": "<branch>",
          "commitMessage": "Snapshot at {date} in {folder}\n\n"
        }
      }]
```
### With custom secret
- Create a secret with the following configuration:
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: snapshooter-secret
type: Opaque
stringData:
  config.json: |-
    [{
      "name": "$name",
      "rootTags": [<list of root tags>],
      "path": "snapshot",
      "server": {
        "user": "admin",
        "password": "***",
        "host": "<namespace>-orchestrator",
        "port": 8080
      },
      "git":{
        "repo": "https://",
        "branch": "<branch>",
        "commitMessage": "Snapshot at {date} in {folder}\n\n"
      }
    }]
EOF
```
  **rootTags**: You can get the root tag of your application(s) by opening it in Draw. the tag will be in the URL\n
  **git.repo**: https link to repository with authentication token (e.g. https://gitlab-token:****@gitlab.mycompany.com/my-project.git)

- Enable the snapshooter in values.yaml
```
[...]
snapshooters:
  - name: $name
    schedule: "45 12 * * *" # cron syntax
    secretName: snapshooter-secret
    image: $docker_registry/<olympe-tools-image>:$tag
```

## Change credentials
- Create a secret named `orchestrator-default-secret` in the correct namespace with your new credentials. You can setup only `DRAW_PASSWORD`, `DRAW_USERNAME` or both of them.
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: orchestrator-default-secret
  namespace: <namespace>
type: Opaque
stringData:
  DRAW_USERNAME: <username>
  DRAW_PASSWORD: ****
EOF
```

- Delete the remaining resetCredentials job (if applicable)
```
kubectl delete job -n <namespace> --selector=app.kubernetes.io/component=resetcredentials --ignore-not-found
```

- Execute the new job
```
helm dependency build && helm template <namespace> olympe/olympe \
 --set olympeTools.action=resetCredentials \
  -s templates/olympe-tools.yml
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | rabbitmq | 11.16.2 |
| https://helm.neo4j.com/neo4j | neo4j(neo4j-standalone) | 4.4.22 |

## Values
**Keys without a description are not meant to be changed**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| acceptLicenseAgreement | string | `"no"` | Please check the license agreement: https:// |
| codeAsData.image.name | string | `"codeasdata"` |  |
| codeAsData.image.repository | string | `"olympeio"` |  |
| codeAsData.podSecurityContext.runAsUser | int | `0` |  |
| codeAsData.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| enabled | bool | `true` | Define if a project is enabled or not. If not, replicas will be set to 0 but data will be kept |
| frontend.additionalConfig | string | `""` | additional frontend configuration |
| frontend.affinity | object | `{}` | setup affinity for the frontend. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| frontend.containerSecurityContext | object | `{"allowPrivilegeEscalation":false}` | defines privilege and access control settings for the frontend on Container level. |
| frontend.env | object | `{}` | frontend environment variables |
| frontend.image | object | `{"name":"frontend","repository":"olympeio"}` | frontend image |
| frontend.nodeSelector | object | `{}` | setup nodeSelector for the frontend. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| frontend.oConfig | string | `""` | frontend oConfig content |
| frontend.podSecurityContext | object | `{"runAsUser":101}` | defines privilege and access control settings for the frontend on Pod level. |
| frontend.port | int | `80` | frontend port |
| frontend.rabbitmq.host | string | `"rabbitmq"` |  |
| frontend.rabbitmq.mqttPort | int | `15675` |  |
| frontend.replicas | int | `1` | Number of frontend replicas |
| frontend.resources.limits | string | `nil` | frontend memory request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) memory: "100Mi" -- frontend CPU request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) cpu: "50m" |
| frontend.resources.requests | string | `nil` |  |
| frontend.tolerations | list | `[]` | setup tolerations for the frontend. Please see [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| fullnameOverride | string | `""` | fully override release name |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| ingress | object | `{"annotations":{"kubernetes.io/ingress.class":"nginx","nginx.ingress.kubernetes.io/proxy-connect-timeout":"36000","nginx.ingress.kubernetes.io/proxy-read-timeout":"36000","nginx.ingress.kubernetes.io/proxy-send-timeout":"36000"},"enabled":false,"extraPaths":[],"hosts":["olympe.local"],"tls":[{"hosts":[],"secretName":null}]}` | Ingress configuration |
| nameOverride | string | `""` | partially override realease name |
| neo4j.enabled | bool | `true` |  |
| neo4j.fullnameOverride | string | `"neo4j"` |  |
| neo4j.image.customImage | string | `"olympeio/database:v2.7.2"` |  |
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
| orchestrator.image | object | `{"name":"orchestrator","repository":"olympeio","tag":"7.2.2"}` | Orchestrator image |
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
| orchestrator.prometheus | object | `{"enabled":false}` | enable Prometheus metrics |
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
| snapshooters | list | `[]` | Snapshooters configuration, You can have multiple of them, each with the following values:<br /> - name: string, mandatory - Name of the snapshooter <br />    schedule: string, mandatory - schedule (cron format) <br />    config: string, json configuration. Please read documentation for examples (can't be used with secretName key below) <br />    secretName: string, name of the secret containing the configuration (can't be used with config key above) <br />    resources <br />      requests: <br />        memory: string, default "200Mi" <br />        cpu: string, default "100m" <br />      limits: <br />        memory: string, default "1000Mi" <br />        cpu: string, default "200m" <br /> |
| toolkit.cronJobs | object | `{"garbageCollector":{"args":["startGC"],"command":"startGC","resources":{"limits":{"cpu":"100m","memory":"100Mi"},"requests":{"cpu":"100m","memory":"100Mi"}},"schedule":"5 1 * * 0","suspend":false}}` | available values are:     - help     - snapshot     - snapshotUsers     - snapshotBusinessData     - restoreUsers     - restoreBusinessData     - reset     - checkDB     - startGC     - statsDB     - maintenance     - updateUser      |
| toolkit.image | object | `{"name":"toolkit","repository":"olympeio","tag":"stable"}` | Olympe Toolkit image |
| toolkit.podSecurityContext | object | `{"runAsUser":0}` | defines privilege and access control settings for the Olympe Tools on Pod level. |
| upgradeScript.schedule | string | `"5 1 * * 0"` |  |
