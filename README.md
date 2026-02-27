# OMI version

PDAF-OMI for multivariate data assimiliaton. 
It is design to handle different observation types (currently soil moisture and TWS) automatically.
Additional to current observation files, the observation type has to be included (SM, GRACE). See also create observation script for details.

Both global and local filters can be used. To enable multi-scale data assimilation, different localization radii for different observation types can be passed. Note that the localization radius for SM is currently in km and for GRACE in #gridcells.

The framework generates a state vector for each type individually before the assimilation, some things would need to be adapted when mutliple observation types are assimilated at the same timestep. Currently, one observation file only consists of one observation type. As SM observations are usually assimilated at noon and GRACE observations are assimilated at the end of the month at midnight, this should not provide any problems.

If questions arise contact ewerdwalbesloh@geod.uni-bonn.de


Observation script: https://icg4geo.icg.kfa-juelich.de/ExternalRepos/tsmp-pdaf/tsmp-pdaf-observation-scripts/-/tree/main/omi_obs_data?ref_type=heads


# Terrestrial Systems Modeling Platform v2 (TSMP2)

[![docs](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/docs.yml/badge.svg)](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/docs.yml)
[![build](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/CI.yml/badge.svg)](https://github.com/HPSCTerrSys/TSMP2/actions/workflows/CI.yml)
[![doi](https://img.shields.io/badge/rsd-tsmp2-00a3e3)](https://helmholtz.software/software/tsmp2)

## Introduction 

The Terrestrial System Modeling Platform v2 (TSMP2, https://www.terrsysmp.org) is an open source scale-consistent, highly modular, massively parallel regional Earth system model. TSMP essentially consists of an interface which couples dedicated versions of the ICOsahedral Nonhydrostatic ([ICON](https://www.icon-model.org/)) atmospheric model in NWP or climate mode, the encore Community Land Model ([eCLM](https://hpscterrsys.github.io/eCLM)), and the hydrologic model [ParFlow](https://www.parflow.org) through the [OASIS3](https://oasis.cerfacs.fr/en/)-[MCT](https://www.mcs.anl.gov/research/projects/mct/) coupler.

TSMP allows for a physically-based representation of transport processes of mass, energy and momentum and interactions between the different compartments of the geo-ecosystem across scales, explicitly reproducing feedbacks in the hydrological cycle from the groundwater into the atmosphere.

TSMP-PDAF describes the build commands of TSMP that can introduce data
assimilation for an ensemble of TSMP simulations using the Parallel
	Data Assimilation Framework
([PDAF](https://pdaf.awi.de/trac/wiki)). For more information, see the
[documentation of TSMP-PDAF](https://hpscterrsys.github.io/pdaf).

TSMP development has been driven by groups within the [Center for High-Performance Scientific Computing in Terrestrial Systems](http://www.hpsc-terrsys.de) (HPSC-TerrSys).

## Quickstart

Please see [quickstart section](./docs/users_guide/building_TSMP2/Quickstart.md) for guided steps on how the model can be build.

## Usage / Documentation

Please check the documentation at https://hpscterrsys.github.io/TSMP2

## License
TSMP is open source software and is licensed under the [MIT-License](https://github.com/HPSCTerrSys/TSMP2/blob/master/LICENSE.txt).

