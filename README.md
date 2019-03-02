# 🚀 Trigger Jenkins Job for GitHub Actions

[GitHub Action](https://developer.github.com/actions/) for trigger [jenkins](https://jenkins.io/) jobs.

<img src="./images/trigger-jenkins.png">

## Usage 

Trigger New Jenkins Job.

```
action "Trigger New Job" {
  uses = "appleboy/jenkins-action@master"
  env = {
    JENKINS_URL = "http://example.com"
    JENKINS_USER = "appleboy"
    JENKINS_JOB = "trigger"
  }
  secrets = [
    "JENKINS_TOKEN",
  ]
}
```

## Jenkins Setting

Setup the Jenkins server using the docker command:

```sh
$ docker run \
  --name jenkins \
  -d --restart always \
  -p 8080:8080 -p 50000:50000 \
  -v /data/jenkins:/var/jenkins_home \
  jenkins/jenkins:lts
```

Please make sure that you create the `/data/jenkins` before starting the Jenkins. Create the new API token as below:

<img src="images/jenkins-token.png">

## Example

Trigger multiple jenkins job:

```
action "Trigger New Job" {
  uses = "appleboy/jenkins-action@master"
  env = {
    JENKINS_URL = "http://example.com"
    JENKINS_USER = "appleboy"
    JENKINS_JOB = "job_1,job_2,job_3"
  }
  secrets = [
    "JENKINS_TOKEN",
  ]
}
```

## Environment variables

* JENKINS_URL - Required. jenkins base url.
* JENKINS_USER - Required. jenkins user.
* JENKINS_JOB - Required. jenkins job name.

## Secrets

* JENKINS_TOKEN - Required. User API Token.
