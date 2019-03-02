FROM appleboy/drone-jenkins:1.3.1-linux-amd64

# Github labels
LABEL "com.github.actions.name"="Trigger Jenkins Job"
LABEL "com.github.actions.description"="Triggering Jenkins Job through the API"
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="green"

LABEL "repository"="https://github.com/appleboy/jenkins-action"
LABEL "homepage"="https://github.com/appleboy"
LABEL "maintainer"="Bo-Yi Wu <appleboy.tw@gmail.com>"
LABEL "version"="0.0.1"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
