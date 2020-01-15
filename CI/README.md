# Introduction

This is the main repository where OpenShift-Pipeline `midstream` gets build and validated.

This allows validating every night the `upstream` changes running on Red Hat
OpenShift Container Platform.


## Architecture

[![CRON Setup](docs/images/cron-setup.png)](docs/images/cron-setup.png)
###### [source](docs/diagrams/cron-setup.plantuml)


[![CRON Setup](docs/images/pipeline-cirun.png)](docs/images/pipeline-cirun.png)
###### [source](docs/diagrams/pipeline-cirun.plantuml)

[![CRON Setup](docs/images/run-test.png)](docs/images/run-test.png)
###### [source](docs/diagrams/run-test.plantuml)

[![CRON Setup](docs/images/cron-end.png)](docs/images/cron-end.png)
###### [source](docs/diagrams/cron-end.plantuml)
