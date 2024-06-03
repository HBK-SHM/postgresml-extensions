FROM ghcr.io/postgresml/postgresml:2.8.2
COPY ./customised.entrypoint.sh /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]