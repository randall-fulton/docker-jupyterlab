FROM python:3.6-slim

ARG VAULT_ADDR
ARG VAULT_TOKEN
ARG ENVIRONMENT
ARG HEROKU_API_KEY
ARG SLACK_HANDLE
ENV VAULT_ADDR=${VAULT_ADDR} VAULT_TOKEN=${VAULT_TOKEN} \
    ENVIRONMENT=${ENVIRONMENT} HEROKU_API_KEY=${HEROKU_API_KEY} \
    SLACK_HANDLE=${SLACK_HANDLE} \
    DBHOST=database DBPORT=5432 DBUSER=postgres DBNAME=postgres DBPASS=

COPY requirements.txt requirements.txt

RUN mkdir -p /usr/share/man/man7 \
    && mkdir -p /usr/share/postgresql/9.4/man/man1 \
    && mkdir -p /usr/share/man/man1 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs npm \
        apt-transport-https \
        build-essential \
        curl \
        git \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        openssh-server \
        openssh-client \
    && ln -s /usr/bin/nodejs /usr/bin/node

ARG nver=9.2.1
RUN npm install -g n \
    && n $nver \
    && ln -sf /usr/local/n/versions/node/$nver/bin/node /usr/bin/nodejs \
    && ln -sf /usr/bin/nodejs /usr/bin/node

RUN pip3 install \
        jupyterlab nbdime \
        ipywidgets jupyterlab-widgets \
        qgrid \
        jupyter_contrib_nbextensions \
    && pip3 install -r requirements.txt \
        # plotly jupyterlab_plotly \
    # && jupyter labextension install --sys-prefix --py --symlink jupyterlab_plotly \
    # && jupyter labextension enable --sys-prefix --py jupyterlab_plotly \
    # && jupyter labextension install --sys-prefix --py jupyterlab_widgets \
    # && jupyter labextension enable --sys-prefix --py jupyterlab_widgets \
    && jupyter serverextension enable --sys-prefix --py jupyterlab \
    && jupyter nbextension enable --py --sys-prefix widgetsnbextension  

RUN mkdir /jupyter && chmod 777 /jupyter
COPY scripts /scripts
COPY settings /settings
# ADD jupyter_notebook_config.py /root/.jupyter/

# Enable Jupyter extensions
RUN jupyter nbextensions_configurator enable --user \
    && mkdir -p $(jupyter --data-dir)/nbextensions \
# Install Jupyter extensions
RUN cd $(jupyter --data-dir)/nbextensions \
    && git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding \
    && chmod -R go-w vim_binding

VOLUME /src

EXPOSE 8888

ENTRYPOINT ["/scripts/launch.sh"]
