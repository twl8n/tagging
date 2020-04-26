FROM gitpod/workspace-full:latest
                    
USER gitpod

# Install PostgreSQL
RUN sudo apt-get update \
 && sudo apt-get install -y postgresql-12 postgresql-contrib-12 \
 && sudo apt-get install -y clojure rlwrap \
 && sudo apt-get clean \
 && sudo rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

# Setup PostgreSQL server for user gitpod
ENV PATH="$PATH:/usr/lib/postgresql/12/bin"
ENV PGDATA="/workspace/.pgsql/data"
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets \
 && printf '#!/bin/bash\n[ ! -d $PGDATA ] && mkdir -p $PGDATA && initdb -D $PGDATA\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start\n' > ~/.pg_ctl/bin/pg_start \
 && printf '#!/bin/bash\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop\n' > ~/.pg_ctl/bin/pg_stop \
 && chmod +x ~/.pg_ctl/bin/*
ENV PATH="$PATH:$HOME/.pg_ctl/bin"
ENV DATABASE_URL="postgresql://gitpod@localhost"
ENV PGHOSTADDR="127.0.0.1"
ENV PGDATABASE="postgres"


# 2020-04-26 Disable auto run of pg server. I grabbed the Pg dockerfile here, and removed a line I don't want.
# I might have been able to use perl/sed to hack the .bashrc after the line below was added, but frankly, copy+paste is easier.
# https://raw.githubusercontent.com/gitpod-io/workspace-images/master/postgres/Dockerfile

# # This is a bit of a hack. At the moment we have no means of starting background
# # tasks from a Dockerfile. This workaround checks, on each bashrc eval, if the
# # PostgreSQL server is running, and if not starts it.
# RUN printf "\n# Auto-start PostgreSQL server.\n[[ \$(pg_ctl status | grep PID) ]] || pg_start > /dev/null\n" >> ~/.bashrc
