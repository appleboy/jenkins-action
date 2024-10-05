FROM ghcr.io/appleboy/drone-jenkins:1.3.3

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
