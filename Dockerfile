FROM ghcr.io/appleboy/drone-jenkins:1.6.0

COPY entrypoint.sh /entrypoint.sh

USER nobody

ENTRYPOINT ["/entrypoint.sh"]
