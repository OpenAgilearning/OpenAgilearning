FROM registry

MAINTAINER wen777 <shih777577@gmail.com>

ENV SEARCH_BACKEND sqlalchemy

ENV SQLALCHEMY_INDEX_DATABASE sqlite:////opt/sqlitedb/reg.db

ENV STORAGE_PATH /opt/registry/

ENV GUNICORN_OPTS \
    ['--certfile','/ssl/registry.crt',\
    '--keyfile','/ssl/registry.key',\
    '--ca-certs','/ssl/ca.cert',\
    '--ssl-version',3]

# VOLUME ["/opt/sqlitedb", "/ssl", "/opt/registry"]
