<a name="unreleased"></a>
## [Unreleased]


<a name="2.6.2"></a>
## [2.6.2] - 2025-08-25
### Chore
- Update appVersion to v2.11.8
- Update appVersion to v2.11.7
- Update appVersion to v2.11.6
- Update appVersion to v2.11.5
- Update appVersion to v2.11.4

### Feat
- enable frontend replica selection

### Fix
- fix HPA for ArgoCD


<a name="olympe-2.6.1"></a>
## [olympe-2.6.1] - 2025-06-14
### Fix
- query service individiaul storage class name


<a name="olympe-2.6.0"></a>
## [olympe-2.6.0] - 2025-06-13
### Chore
- Update appVersion to v2.11.3
- Update appVersion to v2.10.8
- Update appVersion to v2.10.7
- Update appVersion to v2.11.2
- Update appVersion to v2.11.1
- Update appVersion to v2.11.0
- Update appVersion to v2.10.5

### Feat
- add cache volume for orchestrator + remove cache on frontend size


<a name="olympe-2.5.7"></a>
## [olympe-2.5.7] - 2025-03-14
### Fix
- change default loggable value


<a name="olympe-2.5.6"></a>
## [olympe-2.5.6] - 2025-03-13
### Fix
- add frontend configurable logs to reduce amount of logs


<a name="olympe-2.5.5"></a>
## [olympe-2.5.5] - 2025-03-07
### Chore
- Update appVersion to v2.10.4

### Feat
- amqp setup
- add service apps HPA

### Fix
- frontend configuration

### Reverts
- fix: snapshooter configuration


<a name="olympe-2.5.4"></a>
## [olympe-2.5.4] - 2025-02-27
### Fix
- frontend configuration

### Reverts
- fix: snapshooter configuration


<a name="olympe-2.5.3"></a>
## [olympe-2.5.3] - 2025-01-16
### Chore
- Update appVersion to v2.10.3
- Update appVersion to v2.10.2

### Fix
- snapshooter configuration


<a name="olympe-2.5.2"></a>
## [olympe-2.5.2] - 2024-12-09
### Chore
- Update appVersion to v2.10.1
- Update appVersion to v2.10.0

### Fix
- prometheus for orchestrator components


<a name="olympe-2.5.1"></a>
## [olympe-2.5.1] - 2024-11-26
### Fix
- missing 2.5.0 config


<a name="olympe-2.5.0"></a>
## [olympe-2.5.0] - 2024-11-25
### Chore
- Update appVersion to v2.9.2

### Feat
- ability to split orchestrator in components


<a name="olympe-2.4.2"></a>
## [olympe-2.4.2] - 2024-09-20

<a name="olympe-2.4.1"></a>
## [olympe-2.4.1] - 2024-09-18
### Fix
- frontend config syntax


<a name="olympe-2.4.0"></a>
## [olympe-2.4.0] - 2024-09-04
### Chore
- Update appVersion to v2.9.1
- Update appVersion to v2.9.0
- Update appVersion to v2.8.2
- Update appVersion to v4.0.0
- Update appVersion to v2.8.1
- Update appVersion to v2.8.0

### Feat
- frontend config with current and next version
- add cache templating for nginx
- test nginx dynamic cache
- no-downtime: rename key
- no-downtime: additional ingress
- no-downtime: rename key
- no-downtime: rename key
- no-downtime: fix healthcheck
- no-downtime: preview ingress + new values
- no-downtime: service apps setup
- no-downtime: orchestrator setup
- no-downtime: frotnend setup
- add prometheus service monitor
- add preview services for no downtime deployment
- add custom secretRef for orchestrator

### Fix
- frontend config name
- remove empty env variable frontend
- remove configmap range env key
- frontend environment variable
- set toolkit version

### Reverts
- chore: Update appVersion to v4.0.0


<a name="olympe-2.3.0"></a>
## [olympe-2.3.0] - 2024-06-06
### Chore
- Update appVersion to v2.5.2
- Update appVersion to v2.5.1
- Update appVersion to v2.5.0
- **deps:** update helm release rabbitmq to v14
- **deps:** update helm release neo4j-standalone to v4.4.33
- **deps:** update helm release rabbitmq to v12.15.0
- **deps:** update helm release neo4j-standalone to v4.4.28
- **deps:** update helm release rabbitmq to v12
- **deps:** update helm release neo4j-standalone to v4.4.27

### Feat
- add service apps volume
- define service apps as cronjobs
- add missing labels on services for network policies + add network policies

### Fix
- init-install lower case
- fix volumeName
- fix local install
- add missing labels for jobs
- service app file-service pvc name
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options


<a name="olympe-2.2.9"></a>
## [olympe-2.2.9] - 2024-03-20
### Fix
- remove PERMISSION_CHECK_ENABLED override


<a name="olympe-2.2.8"></a>
## [olympe-2.2.8] - 2024-03-07
### Fix
- fix snapshooter
- add snapshot configuration in olympe-toolkit + adapt format
- set garbageCollector suspend to false
- fix  garbageCollector command


<a name="olympe-2.2.7"></a>
## [olympe-2.2.7] - 2024-02-16
### Fix
- fixing various default vlaues
- fix env variables for toolkit
- fix toolkit config for new version
- olympe toolkit value reference for cron jobs


<a name="olympe-2.2.6"></a>
## [olympe-2.2.6] - 2024-01-31
### Feat
- additional directives for frontend
- add service apps volume
- define service apps as cronjobs
- add upgrade-script
- add missing labels on services for network policies + add network policies
- olympe-toolkit add command and args
- migrate feeder to olympe-toolkit

### Fix
- add missing labels for jobs
- add missing labels for jobs
- olympe toolkit new structure
- remove configMapEnv custom values
- add missing labels in toolkit
- cronjob truncate at 52 characters
- fix snapshooter configuration
- service app file-service pvc name
- fix frontend configuration
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options
- toolkit template typo
- olympe toolkit pullsecrets + default image
- forbid concurrency on toolkit jobs
- fix olympe-toolkit mount + snapshooter


<a name="olympe-2.1.11"></a>
## [olympe-2.1.11] - 2024-01-31
### Chore
- Update appVersion to v2.5.2
- Update appVersion to v2.5.1
- Update appVersion to v2.5.0
- **deps:** update helm release neo4j-standalone to v4.4.28
- **deps:** update helm release rabbitmq to v12
- **deps:** update helm release neo4j-standalone to v4.4.27

### Feat
- add service apps volume
- define service apps as cronjobs
- add missing labels on services for network policies + add network policies

### Fix
- add missing labels for jobs
- service app file-service pvc name
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options


<a name="olympe-2.2.5"></a>
## [olympe-2.2.5] - 2024-01-25
### Feat
- additional directives for frontend

### Fix
- olympe toolkit new structure
- remove configMapEnv custom values


<a name="olympe-2.2.4"></a>
## [olympe-2.2.4] - 2024-01-17
### Fix
- add missing labels in toolkit


<a name="olympe-2.2.3"></a>
## [olympe-2.2.3] - 2024-01-12
### Fix
- cronjob truncate at 52 characters
- fix snapshooter configuration


<a name="olympe-2.2.2"></a>
## [olympe-2.2.2] - 2024-01-09
### Feat
- add service apps volume
- define service apps as cronjobs
- add upgrade-script
- add missing labels on services for network policies + add network policies
- olympe-toolkit add command and args
- migrate feeder to olympe-toolkit

### Fix
- service app file-service pvc name
- fix frontend configuration
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options
- toolkit template typo
- olympe toolkit pullsecrets + default image
- forbid concurrency on toolkit jobs
- fix olympe-toolkit mount + snapshooter


<a name="olympe-2.1.10"></a>
## [olympe-2.1.10] - 2024-01-09
### Chore
- Update appVersion to v2.5.2
- Update appVersion to v2.5.1
- Update appVersion to v2.5.0
- **deps:** update helm release neo4j-standalone to v4.4.28
- **deps:** update helm release rabbitmq to v12
- **deps:** update helm release neo4j-standalone to v4.4.27

### Feat
- add service apps volume
- define service apps as cronjobs
- add missing labels on services for network policies + add network policies

### Fix
- service app file-service pvc name
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options


<a name="olympe-2.2.1"></a>
## [olympe-2.2.1] - 2023-12-19
### Feat
- define service apps as cronjobs
- add upgrade-script
- add missing labels on services for network policies + add network policies
- olympe-toolkit add command and args
- migrate feeder to olympe-toolkit

### Fix
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options
- toolkit template typo
- olympe toolkit pullsecrets + default image
- forbid concurrency on toolkit jobs
- fix olympe-toolkit mount + snapshooter


<a name="olympe-2.1.9"></a>
## [olympe-2.1.9] - 2023-12-19
### Chore
- Update appVersion to v2.5.0
- **deps:** update helm release neo4j-standalone to v4.4.28
- **deps:** update helm release rabbitmq to v12
- **deps:** update helm release neo4j-standalone to v4.4.27

### Feat
- define service apps as cronjobs
- add missing labels on services for network policies + add network policies

### Fix
- backend as cronjob: set default backoffLimit to 0
- backend as cronjob: remove generated conf in backend + add suspend and startingDeadlineSeconds options


<a name="olympe-2.2.0"></a>
## [olympe-2.2.0] - 2023-12-06
### Feat
- add missing labels on services for network policies + add network policies
- olympe-toolkit add command and args
- migrate feeder to olympe-toolkit

### Fix
- forbid concurrency on toolkit jobs
- fix olympe-toolkit mount + snapshooter


<a name="olympe-2.1.8"></a>
## [olympe-2.1.8] - 2023-11-20
### Chore
- Update appVersion to v2.5.0
- Update appVersion to v2.4.5
- **deps:** update helm release rabbitmq to v12
- **deps:** update helm release neo4j-standalone to v4.4.27

### Feat
- add missing labels on services for network policies + add network policies


<a name="olympe-2.1.7"></a>
## [olympe-2.1.7] - 2023-07-31
### Chore
- **deps:** update helm release neo4j-standalone to v4.4.22

### Fix
- increase backend livenessProbe initialDelay and FailureThreshold


<a name="olympe-2.1.6"></a>
## [olympe-2.1.6] - 2023-07-18
### Chore
- Update appVersion to v2.4.4
- **deps:** update helm release neo4j-standalone to v4.4.21
- **deps:** update helm release rabbitmq to v11.16.2

### Feat
- add additionalDirectives for frontend + request headers + rabbitmq upstream setup


<a name="olympe-2.1.5"></a>
## [olympe-2.1.5] - 2023-06-08
### Fix
- fix maintenance mode frontend configuration


<a name="olympe-2.1.4"></a>
## [olympe-2.1.4] - 2023-06-07
### Fix
- set default client_max_body_size to 100M for runtime


<a name="olympe-2.1.3"></a>
## [olympe-2.1.3] - 2023-06-06
### Feat
- add annotations and podAnnotations for deployments


<a name="olympe-2.1.2"></a>
## [olympe-2.1.2] - 2023-06-05
### Chore
- **deps:** update helm release rabbitmq to v11.16.1

### Fix
- frontend config fix


<a name="olympe-2.1.1"></a>
## [olympe-2.1.1] - 2023-06-01
### Fix
- remove orchestrator serviceName


<a name="olympe-2.1.0"></a>
## [olympe-2.1.0] - 2023-06-01
### Chore
- Update appVersion to v2.4.3
- Update appVersion to v2.4.2
- **deps:** update helm release rabbitmq to v11.15.3

### Feat
- move orchestrator from statefulset to deployment


<a name="olympe-2.0.1"></a>
## [olympe-2.0.1] - 2023-05-24
### Chore
- Update appVersion to v2.4.1
- **deps:** update helm release rabbitmq to v11.15.2

### Fix
- update liveness default initialDelaySeconds + ability to set custom values
- ability to define custom source port for webservices


<a name="olympe-2.0.0"></a>
## [olympe-2.0.0] - 2023-04-24
### Chore
- Update appVersion to v2.4.0
- **deps:** update helm release rabbitmq to v11.13.0
- **deps:** update helm release neo4j-standalone to v4.4.19

### Feat
- enable default ports + webservices on service apps
- enable frontend custom port
- enable inline snapshooter configuration
- add licence check
- oConfig frontend and backend automatically injected
- snapshooter secret automatically injected

### Fix
- service app container port typo


<a name="olympe-1.4.1"></a>
## [olympe-1.4.1] - 2023-03-29
### Fix
- add specific role for resetDB


<a name="olympe-1.4.0"></a>
## [olympe-1.4.0] - 2023-03-28
### Chore
- **deps:** update helm release rabbitmq to v11.12.0
- **deps:** update helm release rabbitmq to v11.11.0
- **deps:** update helm release rabbitmq to v11.10.3
- **deps:** update node docker tag to v14.21.3

### Feat
- allow changing userID on olmype-tools
- allow frontend port change
- implemenent default runtime exposure + neo4j 4.4
- add nginx cache for graphDef

### Fix
- remove snapshot references
- set backofflimit to 1 for initial resetdb


<a name="olympe-1.3.1-SNAPSHOT-SNAPSHOT"></a>
## [olympe-1.3.1-SNAPSHOT-SNAPSHOT] - 2023-02-08

<a name="olympe-1.3.1-SNAPSHOT"></a>
## [olympe-1.3.1-SNAPSHOT] - 2023-02-08

<a name="olympe-1.3.7"></a>
## [olympe-1.3.7] - 2023-02-06

<a name="olympe-1.3.6"></a>
## [olympe-1.3.6] - 2023-02-06

<a name="olympe-1.3.5"></a>
## [olympe-1.3.5] - 2023-02-06

<a name="olympe-1.3.4"></a>
## [olympe-1.3.4] - 2023-02-06

<a name="olympe-1.3.3"></a>
## [olympe-1.3.3] - 2023-02-06

<a name="olympe-1.3.2"></a>
## [olympe-1.3.2] - 2023-02-06

<a name="olympe-1.3.1"></a>
## [olympe-1.3.1] - 2023-02-06

<a name="olympe-1.3.0"></a>
## olympe-1.3.0 - 2023-02-06

[Unreleased]: https://github.com/olympeio/olympe-helm-test.git/compare/2.6.2...HEAD
[2.6.2]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.6.1...2.6.2
[olympe-2.6.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.6.0...olympe-2.6.1
[olympe-2.6.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.7...olympe-2.6.0
[olympe-2.5.7]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.6...olympe-2.5.7
[olympe-2.5.6]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.5...olympe-2.5.6
[olympe-2.5.5]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.4...olympe-2.5.5
[olympe-2.5.4]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.3...olympe-2.5.4
[olympe-2.5.3]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.2...olympe-2.5.3
[olympe-2.5.2]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.1...olympe-2.5.2
[olympe-2.5.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.5.0...olympe-2.5.1
[olympe-2.5.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.4.2...olympe-2.5.0
[olympe-2.4.2]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.4.1...olympe-2.4.2
[olympe-2.4.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.4.0...olympe-2.4.1
[olympe-2.4.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.3.0...olympe-2.4.0
[olympe-2.3.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.9...olympe-2.3.0
[olympe-2.2.9]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.8...olympe-2.2.9
[olympe-2.2.8]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.7...olympe-2.2.8
[olympe-2.2.7]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.6...olympe-2.2.7
[olympe-2.2.6]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.11...olympe-2.2.6
[olympe-2.1.11]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.5...olympe-2.1.11
[olympe-2.2.5]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.4...olympe-2.2.5
[olympe-2.2.4]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.3...olympe-2.2.4
[olympe-2.2.3]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.2...olympe-2.2.3
[olympe-2.2.2]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.10...olympe-2.2.2
[olympe-2.1.10]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.1...olympe-2.1.10
[olympe-2.2.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.9...olympe-2.2.1
[olympe-2.1.9]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.2.0...olympe-2.1.9
[olympe-2.2.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.8...olympe-2.2.0
[olympe-2.1.8]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.7...olympe-2.1.8
[olympe-2.1.7]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.6...olympe-2.1.7
[olympe-2.1.6]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.5...olympe-2.1.6
[olympe-2.1.5]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.4...olympe-2.1.5
[olympe-2.1.4]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.3...olympe-2.1.4
[olympe-2.1.3]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.2...olympe-2.1.3
[olympe-2.1.2]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.1...olympe-2.1.2
[olympe-2.1.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.1.0...olympe-2.1.1
[olympe-2.1.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.0.1...olympe-2.1.0
[olympe-2.0.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-2.0.0...olympe-2.0.1
[olympe-2.0.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.4.1...olympe-2.0.0
[olympe-1.4.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.4.0...olympe-1.4.1
[olympe-1.4.0]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.1-SNAPSHOT-SNAPSHOT...olympe-1.4.0
[olympe-1.3.1-SNAPSHOT-SNAPSHOT]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.1-SNAPSHOT...olympe-1.3.1-SNAPSHOT-SNAPSHOT
[olympe-1.3.1-SNAPSHOT]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.7...olympe-1.3.1-SNAPSHOT
[olympe-1.3.7]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.6...olympe-1.3.7
[olympe-1.3.6]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.5...olympe-1.3.6
[olympe-1.3.5]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.4...olympe-1.3.5
[olympe-1.3.4]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.3...olympe-1.3.4
[olympe-1.3.3]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.2...olympe-1.3.3
[olympe-1.3.2]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.1...olympe-1.3.2
[olympe-1.3.1]: https://github.com/olympeio/olympe-helm-test.git/compare/olympe-1.3.0...olympe-1.3.1
