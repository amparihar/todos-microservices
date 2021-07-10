
FROM mysql:5.7

# ENV MYSQL_ROOT_PASSWORD Password123
# ENV MYSQL_DATABASE todosdb
# ENV MYSQL_USER admin
# ENV MYSQL_PASSWORD Password123
# ENV DATABASE_HOST localhost

EXPOSE 3306

# we copy all files in the scripts folder and not the folder itself
COPY ./scripts /docker-entrypoint-initdb.d/