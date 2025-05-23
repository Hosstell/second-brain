**Dockerfile**
```yml
version: "3.9"

pg-1:
    container_name: postgres_1
    image: docker.io/bitnami/postgresql-repmgr:14.9.0
    ports:
      - "6432:5432"
    volumes:
      - pg_1_data:/bitnami/postgresql
      - ./create_extensions.sql:/docker-entrypoint-initdb.d/create_extensions.sql:ro
    environment:
      - POSTGRESQL_POSTGRES_PASSWORD=adminpgpwd4habr
      - POSTGRESQL_USERNAME=habrpguser
      - POSTGRESQL_PASSWORD=pgpwd4habr
      - POSTGRESQL_DATABASE=habrdb
      - REPMGR_PASSWORD=repmgrpassword
      - REPMGR_PRIMARY_HOST=pg-1
      - REPMGR_PRIMARY_PORT=5432
      - REPMGR_PARTNER_NODES=pg-1,pg-2:5432
      - REPMGR_NODE_NAME=pg-1
      - REPMGR_NODE_NETWORK_NAME=pg-1
      - REPMGR_PORT_NUMBER=5432
      - REPMGR_CONNECT_TIMEOUT=1
      - REPMGR_RECONNECT_ATTEMPTS=2
      - REPMGR_RECONNECT_INTERVAL=1
      - REPMGR_MASTER_RESPONSE_TIMEOUT=5
    restart: unless-stopped
    networks:
      - postgres-ha

  pg-2:
    container_name: postgres_2
    image: docker.io/bitnami/postgresql-repmgr:14.9.0
    ports:
      - "6433:5432"
    volumes:
      - pg_2_data:/bitnami/postgresql
      - ./create_extensions.sql:/docker-entrypoint-initdb.d/create_extensions.sql:ro
    environment:
      - POSTGRESQL_POSTGRES_PASSWORD=adminpgpwd4habr
      - POSTGRESQL_USERNAME=habrpguser
      - POSTGRESQL_PASSWORD=pgpwd4habr
      - POSTGRESQL_DATABASE=habrdb
      - REPMGR_PASSWORD=repmgrpassword
      - REPMGR_PRIMARY_HOST=pg-1
      - REPMGR_PRIMARY_PORT=5432
      - REPMGR_PARTNER_NODES=pg-1,pg-2:5432
      - REPMGR_NODE_NAME=pg-2
      - REPMGR_NODE_NETWORK_NAME=pg-2
      - REPMGR_PORT_NUMBER=5432
      - REPMGR_CONNECT_TIMEOUT=1
      - REPMGR_RECONNECT_ATTEMPTS=2
      - REPMGR_RECONNECT_INTERVAL=1
      - REPMGR_MASTER_RESPONSE_TIMEOUT=5
    restart: unless-stopped
    networks:
      - postgres-ha

  pg_exporter-1:
    container_name: pg_exporter_1
    image: prometheuscommunity/postgres-exporter:v0.11.1
    command: --log.level=debug
    environment:
      DATA_SOURCE_URI: "pg-1:5432/habrdb?sslmode=disable"
      DATA_SOURCE_USER: habrpguser
      DATA_SOURCE_PASS: pgpwd4habr
      PG_EXPORTER_EXTEND_QUERY_PATH: "/etc/postgres_exporter/queries.yaml"
    volumes:
      - ./queries.yaml:/etc/postgres_exporter/queries.yaml:ro
    ports:
      - "9187:9187"
    networks:
      - postgres-ha
    restart: unless-stopped
    depends_on:
      - pg-1

  pg_exporter-2:
    container_name: pg_exporter_2
    image: prometheuscommunity/postgres-exporter:v0.11.1
    command: --log.level=debug
    environment:
      DATA_SOURCE_URI: "pg-2:5432/habrdb?sslmode=disable"
      DATA_SOURCE_USER: habrpguser
      DATA_SOURCE_PASS: pgpwd4habr
      PG_EXPORTER_EXTEND_QUERY_PATH: "/etc/postgres_exporter/queries.yaml"
    volumes:
      - ./queries.yaml:/etc/postgres_exporter/queries.yaml:ro
    ports:
      - "9188:9187"
    networks:
      - postgres-ha
    restart: unless-stopped
    depends_on:
      - pg-2

networks:
  postgres-ha:
    driver: bridge

volumes:
  pg_1_data:
  pg_2_data:
```
