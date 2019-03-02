workflow "Trigger Jenkins Jobs" {
  on = "push"
  resolves = [
    "Trigger New Job",
  ]
}

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
