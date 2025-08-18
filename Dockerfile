FROM harbor.budapest.hu/docker-hub/fphgov/helm:3.9.0

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
