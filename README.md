# jenkins
Repo with some ways/examples on how to install Jenkins

## docker
This folder contains one script to run Jenkins usning Docker and one folder where is possible see one example on how to customize a Jenkins image.
To run Jenkins using this Docker version, just run:
```bash
JENKINS_IMAGE=jenkins/jenkins:latest PORT=8080 CONTAINER_NAME=jenkins DRY_RUN=n ./install.sh
```

Where:
| Variable | Default | Description |
| - | - | - |
| JENKINS_IMAGE | jenkins/jenkins:latest | Configure which Jenkins image should be used |
| PORT | 8080 | The port where Jenkins will be exposed |
| CONTAINER_NAME | jenkins | The name of the container |

To customize a new image, just change the [Dockerfile](./docker/custom_image/Dockerfile) and run Docker commands to build and push, example:
```bash
docker build -t <docker_repo>/jenkins:latest .
docker push <docker_repo>/jenkins:latest
```

>**Uninstall**
```bash
docker stop jenkins
```

## kubernetes
The following projects were executed using [Minikube](https://minikube.sigs.k8s.io/docs/start/)
### helm installation
To install this version, you need to run the script [install.sh](./kubernetes/helm_installation/install.sh)
It's possible change the charts value by changing the [values.yaml](./kubernetes/helm_installation/values.yaml)

The following variables are considered to run the script:
| Variable | Default | Description |
| - | - | - |
| KUBE_CONTEXT | current k8s context | Set the Kubernetes context where the operations will be done |
| CHART_VERSION | 4.3.0 | Used to set the chart version |
| CHART_NAME | jenkinsci | The chart name. The namespace will be the same as the char name |
| DRY_RUN | y | Once set 'y' all the commands will run in dry run mode and won't be applied. Acceptable values: y/n |

Exemple:
```bash
KUBE_CONTEXT=minukube CHART_VERSION=4.3.0 CHART_NAME=jenkinsci DRY_RUN=n ./install.sh
```

The logs will show the initial user/password and URL to access Jenkins.

>**Uninstall**

To uninstall run:
```bash
helm uninstall jenkinsci # Change by the chart name that was chosen
```

### manual installation
To install this version, you need to run the script [install.sh](./kubernetes/manual_installation/install.sh)

This will create all necessary resources to run Jenkins, one by one, like:
- namespace
- serviceAccount
- cluster role/cluster role binding
- storageClass
- PV/PVC
- deployment
- service

The logs will show the initial password and URL to access Jenkins.
The following variables are considered to run the script:

| Variable | Default | Description |
| - | - | - |
| KUBE_CONTEXT | current k8s context | Set the Kubernetes context where the operations will be done |
| NAMESPACE | jenkinsci | Set a namespace where Jenkins will be deployed |
| DRY_RUN | y | Once set 'y' all the commands will run in dry run mode and won't be applied. Acceptable values: y/n |

Exemple:
```bash
KUBE_CONTEXT=minukube NAMESPACE=jenkins DRY_RUN=n ./install.sh
```

>**Uninstall**

To uninstall run:
```bash
kubectl delete ns jenkinsci #same as you configured on NAMESPACE variable (default is jenkinsci)
kubecel delete pv jenkins-pv
```