# jupyter-neuron
Source code for the o<sup>2</sup>S<sup>2</sup>PARC JupyterLab NEURON Service, based on [jupyter-math](https://github.com/ITISFoundation/jupyter-math). It also contains NEURON-based packages, including:
  - [NEURON](https://neuron.yale.edu/neuron/)
  - [NEST](https://nest-simulator.readthedocs.io/en/stable/ref_material/pynest_apis.html)
  - [TVB](https://pypi.org/project/tvb/)
  - [PyNN](https://neuralensemble.org/PyNN/)
  - [BluePyOpt](https://github.com/BlueBrain/BluePyOpt#readme)
  - [Brian2](https://brian2.readthedocs.io/en/stable/) 
  - [brian2tools](https://pypi.org/project/brian2tools/)
  - [NetPyNE](http://netpyne.org/)
  - [pyNeuroML](https://docs.neuroml.org/Userdocs/Software/pyNeuroML.html)


for the Python kernel.

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
