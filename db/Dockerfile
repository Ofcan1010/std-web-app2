FROM mysql:8.0
ENV MYSQL_ROOT_PASSWORD=root \
    MYSQL_DATABASE=studentdb \
    MYSQL_USER=student \
    MYSQL_PASSWORD=s3cr3t
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql