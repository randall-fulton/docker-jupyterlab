FROM python:3.6-slim

ENV DBHOST=database DBPORT=5432 DBUSER=postgres DBNAME=postgres DBPASS=

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

# Jupyter extensions
RUN mkdir -p $(jupyter --data-dir)/nbextentions

VOLUME /src

EXPOSE 8888

ENTRYPOINT ["/scripts/launch.sh"]
