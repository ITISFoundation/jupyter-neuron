FROM itisfoundation/jupyter-math:2.0.8 as base
LABEL maintainer="ordonez"
USER root

# copy and resolve dependecies to be up to date
COPY --chown=$NB_UID:$NB_GID requirements.in ${NOTEBOOK_BASE_DIR}/requirements.in
RUN .venv/bin/pip --no-cache install pip-tools && \
    ## rename the previously existing "requirements.txt" from the jupyter-math service (we want to keep it for user reference)
    mv ${NOTEBOOK_BASE_DIR}/requirements.txt ${NOTEBOOK_BASE_DIR}/requirements_base_math.txt &&\
    .venv/bin/pip-compile --build-isolation --output-file ${NOTEBOOK_BASE_DIR}/requirements.txt ${NOTEBOOK_BASE_DIR}/requirements.in  && \
    .venv/bin/pip --no-cache install -r ${NOTEBOOK_BASE_DIR}/requirements.txt && \
    rm ${NOTEBOOK_BASE_DIR}/requirements.in && \
    echo "Your environment contains these python packages:" && \
    .venv/bin/pip list 

## this is needed before installing mpi4py
RUN apt update && apt-get install -y libopenmpi-dev &&\
    .venv/bin/pip --no-cache install mpi4py

## nrnutils imports neuron during install. I need to install it in a separate command
RUN .venv/bin/pip --no-cache install nrnutils 

# ### Install NEST Simulator (which includes PyNEST - python interface)
# RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common
# RUN sudo add-apt-repository ppa:nest-simulator/nest
# RUN sudo apt-get update
# # RUN sudo add-apt-repository -y ppa:nest-simulator/nest 
# # RUN apt-get update 
# RUN apt-get install -y nest

## create NEURON mechanisms; need to execute nrnivmodl in the appropriate folder
RUN cd ${HOME}/.venv/lib/python3.9/site-packages/pyNN/neuron/nmodl &&\
    ${HOME}/.venv/bin/nrnivmodl . && cd ${HOME}

# remove write permissions from files which are not supposed to be edited
RUN chmod gu-w ${NOTEBOOK_BASE_DIR}/requirements_base_math.txt &&\
    chmod gu-w ${NOTEBOOK_BASE_DIR}/requirements.txt

## change the name of the kernel (just for display) in the kernel JSON file
ENV PYTHON_KERNEL_NAME="python (NEURON)"
ENV KERNEL_DIR ${HOME}/.local/share/jupyter/kernels/python-maths
RUN sudo apt update && sudo apt install -y jq &&\
    jq --arg a "$PYTHON_KERNEL_NAME" '.display_name = $a' ${KERNEL_DIR}/kernel.json > ${KERNEL_DIR}/temp.json \
    && mv ${KERNEL_DIR}/temp.json ${KERNEL_DIR}/kernel.json

EXPOSE 8888
ENTRYPOINT [ "/bin/bash", "/docker/entrypoint.bash" ]