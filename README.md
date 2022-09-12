# jupyter-neuron
Source code for the o<sup>2</sup>S<sup>2</sup>PARC JupyterLab NEURON Service, based on [jupyter-neuron](https://github.com/ITISFoundation/jupyter-neuron). It also contains NEURON-based packages, including [NEURON](https://neuron.yale.edu/neuron/), [NetPyNE](http://netpyne.org/) and [Brian2](https://brian2.readthedocs.io/en/stable/) for the Python kernel.

Building the docker image:

```shell
make build
```


Test the built image locally:

```shell
make run-local
```
Note that the `validation` directory will be mounted inside the service.


Raising the version can be achieved via one for three methods. The `major`,`minor` or `patch` can be bumped, for example:

```shell
make version-patch
```


If you already have a local copy of **o<sup>2</sup>S<sup>2</sup>PARC** running and wish to push data to the local registry:

```shell
make publish-local
```
