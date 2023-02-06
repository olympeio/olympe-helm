# Olympe Helm Chart

# Description

# Prerequisites

- Nodes.js 14
- Yeoman 4.1.0 or greater

# Installation

## Basic Installation

- Add the repository222
```
helm repo add olympe https://olympeio.github.io/olympe-helm/
```
- Install this Helm chart
```
helm install <name> olympe/olympe \
 --namespace <name> \
 --create-namespace \
 --wait
```

- Follow the process described on the outputed notes

## Build your own images

- Install project generator globally and generate a project.
```
npm install --global @olympeio/generator-project
yo @olympeio/project
```
- Build and push the frontend image
```
npm run build:draw
docker build -t <registry>/<frontend-image>:<tag> -f docker/olympe-frontend.Dockerfile .
docker push <registry>/<frontend-image>:<tag>
```

- Build and push the orchestrator image
```
npx gulp patches
docker build -t <registry>/<orchestrator-image>:<tag> -f docker/olympe-orchestrator.Dockerfile .
docker push <registry>/<orchestrator-image>:<ftag>
```

- Build and push the olympe-tools image
```
docker build -t <registry>/<olympe-tools-image>:<tag> -f docker/olympe-tools.Dockerfile .
docker push <registry>/<olympe-tools-image>:<tag>
```

- Install this Helm chart using your images
```
helm dependency build && helm install <name> stable-composer/composer-helm \
 --namespace <name>
 --set orchestrator.image=<registry>/<orchestrator-image>:<tag> \
 --set frontend.image=<registry>/frontend-image>:<tag> \
 --set olympeTools.image=<registry>/<olympe-tools-image>:<tag> \
 --create-namespace
```

- Follow the process described on the outputed notes

## Expose your application

## External RabbitMQ
- auth module
- mqtt module

## External Neo4j
 - licensing
 - protocol (bolt/neo4j)

# Olympe Tools

You can use the Olympe Tools image to execute multiple tasks:

- ResetDB: Reset the database to its initial state or to the latest snapshot (if configured)
- Snapshooter: Take a snapshot of your instance and backup it to a git repository
- Change credentials: Change the admin user and/or password

## ResetDB

The resetDB is automatically executed at instance creation, but you can re-execute it manually if needed

> :warning: **Executing it will wipe all the handmade data**: Except if you snaphooted them before!

- Delete the remaining resetdb job
```
kubectl delete job -n <namespace> --selector=app.kubernetes.io/component=resetdb --ignore-not-found
```

- Execute the new job
```
helm dependency build && helm template <namespace> stable-composer/composer-helm \
 --set orchestrator.image=olympeio/awesome-project-orchestrator:latest \
 --set frontend.image=olympeio/awesome-project-frontend:latest \
 --set olympeTools.image=olympeio/vanilla-draw-olympe-tools:latest \
  -s templates/olympe-tools.yml | kubectl apply -n <namespace> -f -
```

## Snapshooter
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
      "name": "<name>",
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
  - name: <name>
    schedule: "45 12 * * *" # cron syntax
    secretName: snapshooter-secret
    image: <registry>/<olympe-tools-image>:<tag>
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
helm dependency build && helm template <namespace> stable-composer/composer-helm \
 --set orchestrator.image=olympeio/awesome-project-orchestrator:latest \
 --set frontend.image=olympeio/awesome-project-frontend:latest \
 --set olympeTools.image=olympeio/vanilla-draw-olympe-tools:latest \
 --set olympeTools.action=resetCredentials \
  -s templates/olympe-tools.yml
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | rabbitmq | 11.6.0 |
| https://neo4j-contrib.github.io/neo4j-helm | neo4j | 4.4.9 |

## Values
**Keys without a description are not meant to be changed**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| appRepository | string | `"olympeio/olympe-composer"` | Docker repository for the resource image |
| businessData.postgres.enabled | string | `"false"` |  |
| businessData.postgres.endpoint | string | `nil` | endpoint of postgres RDS cluster |
| businessData.postgres.postgresPassword | string | `nil` | user password of the project's postgres database (defaults to a 12 characters randomly generated string) |
| clusterName | string | `"eks-ci"` | Kubernetes cluster name |
| drawPassword | string | `nil` | Olympe admin password. This parameter is passed to resetdb command. |
| enabled | bool | `true` | Define if a project is enabled or not. If not, replicas will be set to 0 but data will be kept |
| frontend.affinity | object | `{}` |  |
| frontend.dataVolume.storageClassName | string | `"standard"` |  |
| frontend.env | object | `{}` | frontend environment variables |
| frontend.image | object | `{"registry":"olympeio","repository":"olympe-frontend"}` | frontend image |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podSecurityContext.runAsUser | int | `0` |  |
| frontend.replicas | int | `1` | Number of frontend replicas |
| frontend.resources.limits | string | `nil` | frontend memory request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) memory: "100Mi" -- frontend CPU request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) cpu: "50m" |
| frontend.resources.requests | string | `nil` |  |
| frontend.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| frontend.tolerations | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| httpProbe | bool | `true` | Define if a project HTTP check is enabled on Grafana |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| imagePullSecrets[0].name | string | `"gitlab-docker-cfg"` |  |
| ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"36000"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"36000"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-send-timeout" | string | `"36000"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.extraPaths | list | `[]` |  |
| ingress.hosts[0] | string | `"olympe.local"` |  |
| ingress.tls[0].hosts | list | `[]` |  |
| ingress.tls[0].secretName | string | `nil` |  |
| nameOverride | string | `""` |  |
| neo4j.acceptLicenseAgreement | string | `"yes"` |  |
| neo4j.core.initContainers[0].command[0] | string | `"/bin/sh"` |  |
| neo4j.core.initContainers[0].command[1] | string | `"-c"` |  |
| neo4j.core.initContainers[0].command[2] | string | `"cp /var/lib/neo4j/plugins/* /plugins"` |  |
| neo4j.core.initContainers[0].image | string | `"olympeio/olympe-database:2.3.1"` | Init container which is used to copy the plugins. This should be the set as <neo4j.image>:<neo4j.imageTag> |
| neo4j.core.initContainers[0].name | string | `"copy-plugins"` |  |
| neo4j.core.initContainers[0].volumeMounts[0].mountPath | string | `"/plugins"` |  |
| neo4j.core.initContainers[0].volumeMounts[0].name | string | `"plugins"` |  |
| neo4j.core.standalone | bool | `true` |  |
| neo4j.enabled | bool | `true` |  |
| neo4j.fullnameOverride | string | `"neo4j"` |  |
| neo4j.image | string | `"olympeio/olympe-database"` |  |
| neo4j.imageTag | string | `"2.3.1"` |  |
| neo4j.neo4jPassword | string | `"olympe"` |  |
| neo4j.plugins | list | `[]` |  |
| nodes.dataVolume.storageClassName | string | `"efs-storage-class"` |  |
| olympeTools.action | string | `"resetdb"` |  |
| olympeTools.image | string | `"olympeio/olympe-tools:latest"` |  |
| orchestrator.affinity | object | `{}` |  |
| orchestrator.clusterType | string | `"none"` | Orchestrator cluster type. Can be "none", "infinispan" or "hazelcast" |
| orchestrator.configMapEnv | object | `{"ACTIVITY_TIMEOUT":"70000000","ALLOWED_WS_ORIGINS":"|.*","JAVA_PROCESS_XMX":"1g","PERMISSION_CHECK_ENABLED":"false","RABBITMQ_CLIENT_PREFETCH_SIZE":200,"WAIT_FOR_NEO4J":"120"}` | Orchestrator environment variables (in separated configMap) |
| orchestrator.dataVolume.backupData | object | `{}` |  |
| orchestrator.dataVolume.fileService | object | `{}` |  |
| orchestrator.dataVolume.patches | object | `{}` |  |
| orchestrator.dataVolume.storageClassName | string | `"standard"` |  |
| orchestrator.env | string | `nil` | Orchestrator environment variables (in statefulset) |
| orchestrator.existingSecret | string | `""` |  |
| orchestrator.haEnabled | bool | `false` | Orchestrator HA setup |
| orchestrator.image | object | `{"registry":"olympe-orchestrator","repository":"olympeio"}` | Orchestrator image |
| orchestrator.livenessProbe.failureThreshold | int | `10` |  |
| orchestrator.livenessProbe.httpGet.path | string | `"/readiness"` |  |
| orchestrator.livenessProbe.httpGet.port | int | `8082` |  |
| orchestrator.neo4j.createDB | bool | `true` | Toggle createdb execution at project creation only |
| orchestrator.neo4j.dbName | string | `nil` | database name of the project (defaults to project name without hyphen) |
| orchestrator.neo4j.dbUserPassword | string | `"olympe"` | database user password of the project (defaults to a 12 characters randomly generated string) |
| orchestrator.neo4j.dbUsername | string | `"neo4j"` | database username of the project (defaults to project name without hyphen) |
| orchestrator.neo4j.hostname | string | `nil` | hostname of Neo4j (default to project cluster) |
| orchestrator.neo4j.protocol | string | `"bolt"` | protocol |
| orchestrator.neo4j.resetDB | bool | `true` | Toggle resetdb execution at project creation only |
| orchestrator.neo4j.rootPassword | string | `"password1"` | shared neo4j root password |
| orchestrator.nfsFixerImage | string | `"470752198308.dkr.ecr.eu-central-1.amazonaws.com/alpine"` | Orchestrator image |
| orchestrator.nodeSelector | object | `{}` |  |
| orchestrator.podSecurityContext.runAsUser | int | `1000` |  |
| orchestrator.prometheus.enabled | bool | `false` |  |
| orchestrator.rabbitmq.host | string | `"rabbitmq"` |  |
| orchestrator.rabbitmq.orchestratorPassword | string | `"guest"` |  |
| orchestrator.rabbitmq.orchestratorUsername | string | `"guest"` |  |
| orchestrator.rabbitmq.password | string | `"guest"` |  |
| orchestrator.rabbitmq.port | int | `5672` |  |
| orchestrator.rabbitmq.username | string | `"guest"` |  |
| orchestrator.replicas | int | `1` | Number of orchestrator replicas |
| orchestrator.resources.limits | string | `nil` | Orchestrator memory request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) memory: "600Mi" -- Orchestrator CPU request. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) cpu: "100m" |
| orchestrator.resources.requests | string | `nil` |  |
| orchestrator.secretRef | string | `nil` | secretRef value for orchestrator |
| orchestrator.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| orchestrator.startupProbe.failureThreshold | int | `10` |  |
| orchestrator.startupProbe.httpGet.path | string | `"/readiness"` |  |
| orchestrator.startupProbe.httpGet.port | int | `8082` |  |
| orchestrator.tolerations | list | `[]` |  |
| podSecurityContext | object | `{}` |  |
| rabbitmq.auth.password | string | `"guest"` |  |
| rabbitmq.auth.username | string | `"guest"` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.extraConfiguration | string | `"default_vhost = orchestrator\ndefault_permissions.configure = .*\ndefault_permissions.read = .*\ndefault_permissions.write = .*\nauth_backends.1         = internal\nauth_backends.2         = http\nauth_http.http_method   = post\nauth_http.user_path     = http://orchestrator:8080/auth/user\nauth_http.vhost_path    = http://orchestrator:8080/auth/vhost\nauth_http.resource_path = http://orchestrator:8080/auth/resource\nauth_http.topic_path    = http://orchestrator:8080/auth/topic"` |  |
| rabbitmq.extraPlugins[0] | string | `"rabbitmq_web_mqtt"` |  |
| rabbitmq.extraPlugins[1] | string | `"rabbitmq_auth_mechanism_ssl"` |  |
| rabbitmq.extraPlugins[2] | string | `"rabbitmq_auth_backend_cache"` |  |
| rabbitmq.extraPlugins[3] | string | `"rabbitmq_auth_backend_http"` |  |
| rabbitmq.fullnameOverride | string | `"rabbitmq"` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceApps | list | `[]` | Service Apps configuration. Please see the example folders for more details |
| serviceAppsImage | string | `"node:14.21.2-slim"` |  |
| snapshooters | list | `[]` | Snapshooters configuration, You can have multiple of them, each with the following values:<br /> - name: string, mandatory - Name of the snapshooter <br />    schedule: string, mandatory - schedule (cron format) <br />    secretName: string, mandatory - name of the secret containing the configuration <br />    resources <br />      requests: <br />        memory: string, default "200Mi" <br />        cpu: string, default "100m" <br />      limits: <br />        memory: string, default "1000Mi" <br />        cpu: string, default "200m" <br /> |
| vaultTemplate | bool | `false` |  |
