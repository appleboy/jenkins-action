FROM ghcr.io/appleboy/drone-jenkins:1.6.0

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER nobody

ENTRYPOINT ["/entrypoint.sh"]
