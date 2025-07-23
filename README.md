# Terrestrial Systems Modeling Platform v2 (TSMP2)

[![docs](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/docs.yml/badge.svg)](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/docs.yml)
[![build](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/CI.yml/badge.svg)](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/CI.yml)
[![doi](https://img.shields.io/badge/rsd-tsmp2-00a3e3)](https://helmholtz.software/software/tsmp2)

## Introduction 

The Terrestrial System Modeling Platform v2 (TSMP2, https://www.terrsysmp.org) is an open source scale-consistent, highly modular, massively parallel regional Earth system model. TSMP essentially consists of an interface which couples dedicated versions of the ICOsahedral Nonhydrostatic ([ICON](https://www.icon-model.org/)) atmospheric model in NWP or climate mode, the encore Community Land Model ([eCLM](https://hpscterrsys.github.io/eCLM)), and the hydrologic model [ParFlow](https://www.parflow.org) through the [OASIS3](https://oasis.cerfacs.fr/en/)-[MCT](https://www.mcs.anl.gov/research/projects/mct/) coupler.

TSMP allows for a physically-based representation of transport processes of mass, energy and momentum and interactions between the different compartments of the geo-ecosystem across scales, explicitly reproducing feedbacks in the hydrological cycle from the groundwater into the atmosphere.

TSMP development has been driven by groups within the [Center for High-Performance Scientific Computing in Terrestrial Systems](http://www.hpsc-terrsys.de) (HPSC-TerrSys).

## Quickstart

Please see [quickstart section](./docs/users_guide/building_TSMP2/Quickstart.md) for guided steps on how the model can be build.

## Usage / Documentation

Please check the documentation at https://hpscterrsys.github.io/TSMP2

## License
TSMP is open source software and is licensed under the [MIT-License](https://github.com/HPSCTerrSys/TSMP2/blob/master/LICENSE.txt).

