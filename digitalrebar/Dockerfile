FROM digitalrebar/provision:v4.6.5

ENV DATA_DIRECTORY=/provision/drp-data
ENV SEED_DIRECTORY=/provision/seed-data

COPY ./scripts/with_seed_server.sh ./scripts/seed_config.sh ./scripts/is_healthy.sh ./scripts/
RUN ./scripts/with_seed_server.sh ./scripts/seed_config.sh

HEALTHCHECK --interval=30s --timeout=3s CMD /scripts/is_healthy.sh

COPY ./scripts/entrypoint.sh ./scripts/
ENTRYPOINT ["/scripts/entrypoint.sh"]

COPY ./scripts/seed_content.sh ./scripts/
COPY ./base ./base
RUN ./scripts/with_seed_server.sh ./scripts/seed_content.sh
