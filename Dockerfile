FROM python:3.6-stretch

RUN mkdir -p /usr/share/man/man7 \
    && mkdir -p /usr/share/postgresql/9.4/man/man1 \
    && mkdir -p /usr/share/man/man1 \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs npm \
        apt-transport-https \
        build-essential \
        curl \
        git \
        libssl-dev \
        libffi-dev \
        openssh-server \
        openssh-client

RUN npm install -g n \
    && n 9.2.1 \
    && ln -sf /usr/local/n/versions/node/$nver/bin/node /usr/bin/nodejs

RUN pip3 install \
        jupyterlab nbdime \
        ipywidgets jupyterlab-widgets \
        qgrid \
        jupyter_contrib_nbextensions \
    && jupyter serverextension enable --sys-prefix --py jupyterlab \
    && jupyter nbextension enable --py --sys-prefix widgetsnbextension  

RUN mkdir /notebooks /jupyter-init.d \
    && chmod 777 /notebooks
COPY scripts /scripts
COPY settings /settings

# Enable Jupyter extensions
RUN jupyter nbextensions_configurator enable --user \
    && mkdir -p $(jupyter --data-dir)/nbextensions

# Install Jupyter extensions
RUN cd $(jupyter --data-dir)/nbextensions \
    && git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding \
    && chmod -R go-w vim_binding

EXPOSE 8888

ENTRYPOINT ["/scripts/launch.sh"]
