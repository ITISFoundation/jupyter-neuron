ARG JUPYTER_MINIMAL_VERSION=lab-3.3.2@sha256:a4bf48221bfa864759e0f248affec3df1af0a68ee3e43dfc7435d84926ec92e8
FROM jupyter/minimal-notebook:${JUPYTER_MINIMAL_VERSION}


LABEL maintainer="elisabettai"

ENV JUPYTER_ENABLE_LAB="yes"
# autentication is disabled for now
ENV NOTEBOOK_TOKEN=""
ENV NOTEBOOK_BASE_DIR="$HOME/work"

USER root

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ffmpeg \
  dvipng \
  gosu \
  software-properties-common \ 
  # NEW: to be able to then install NEST
  make \
  octave \
  gnuplot \
  liboctave-dev \
  bc \
  ghostscript \
  texlive-xetex \
  texlive-fonts-recommended \
  texlive-latex-recommended \
  # texlive-fonts-extra \
  zip \
  fonts-freefont-otf \
  && \
  apt-get clean && rm -rf /var/lib/apt/lists/* 

# Installing octave packages requires make
RUN octave --no-window-system --eval "pkg install -forge io" && \
  # octave --no-window-system --eval "pkg install -forge statistics" && \
  #### incompatibility issue - Octave is 5.2 by default (latest and only available versoin according to apt list -a octave, after apt(-get) update); statistics package requires 6.1. Therefore, do not install it
  octave --no-window-system --eval "pkg install -forge image"    

RUN pip --no-cache --quiet install --upgrade \
  pip \
  setuptools \
  wheel

USER $NB_UID

# --------------------------------------------------------------------

# Install kernel in virtual-env
ENV HOME="/home/$NB_USER"

USER root

WORKDIR ${HOME}

### Install NEST Simulator (which includes PyNEST - python interface)
RUN sudo add-apt-repository ppa:nest-simulator/nest
RUN sudo apt-get update
# RUN sudo add-apt-repository -y ppa:nest-simulator/nest 
# RUN apt-get update 
RUN apt-get install -y nest

RUN python3 -m venv .venv &&\
  .venv/bin/pip --no-cache --quiet install --upgrade pip~=21.3 wheel setuptools &&\
  .venv/bin/pip --no-cache --quiet install ipykernel &&\
  .venv/bin/python -m ipykernel install \
  --user \
  --name "python-neurons" \
  --display-name "python (NEURON)" \
  && \
  echo y | .venv/bin/python -m jupyter kernelspec uninstall python3 &&\
  .venv/bin/python -m jupyter kernelspec list

# copy and resolve dependecies to be up to date
COPY --chown=$NB_UID:$NB_GID kernels/python-neuron/requirements.in ${NOTEBOOK_BASE_DIR}/requirements.in
RUN .venv/bin/pip --no-cache install pip-tools && \
  .venv/bin/pip-compile --build-isolation --output-file ${NOTEBOOK_BASE_DIR}/requirements.txt ${NOTEBOOK_BASE_DIR}/requirements.in  && \
  .venv/bin/pip --no-cache install -r ${NOTEBOOK_BASE_DIR}/requirements.txt && \
  rm ${NOTEBOOK_BASE_DIR}/requirements.in && \
  echo "Your environment contains these python packages:" && \
  .venv/bin/pip list 

RUN jupyter serverextension enable voila && \
  jupyter server extension enable voila

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg .venv/bin/python -c "import matplotlib.pyplot" && \
  # run fix permissions only once
  fix-permissions /home/$NB_USER

# copy README and CHANGELOG
COPY --chown=$NB_UID:$NB_GID CHANGELOG.md ${NOTEBOOK_BASE_DIR}/CHANGELOG.md
COPY --chown=$NB_UID:$NB_GID README.ipynb ${NOTEBOOK_BASE_DIR}/README_Jupyter_oSPARC.ipynb
# remove write permissions from files which are not supposed to be edited
RUN chmod gu-w ${NOTEBOOK_BASE_DIR}/CHANGELOG.md && \
  chmod gu-w ${NOTEBOOK_BASE_DIR}/requirements.txt

RUN mkdir --parents "/home/${NB_USER}/.virtual_documents" && \
  chown --recursive "$NB_USER" "/home/${NB_USER}/.virtual_documents"
ENV JP_LSP_VIRTUAL_DIR="/home/${NB_USER}/.virtual_documents"

# Copying boot scripts
COPY --chown=$NB_UID:$NB_GID docker /docker

RUN echo 'export PATH="/home/${NB_USER}/.venv/bin:$PATH"' >> "/home/${NB_USER}/.bashrc"

EXPOSE 8888

ENTRYPOINT [ "/bin/bash", "/docker/entrypoint.bash" ]