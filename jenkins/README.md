# Usage
> Its necessary to be loged in dockerHub using CLI
```
docker login -u <dockerHubUser>
```

Open runJenkins.sh file and change the variables:
JENKINS_VERSION
JENKINS_IMAGENAME

You can choose if want to build and run, just change the script by commenting the steps inside the main function.
```
  build
  run
  getPaswd
```

To build and push to Docker, run:
```
./runJenkins.sh <dockerHubUser>
```

To run localy run:
```
./runJenkins.sh <dockerHubUser>
```