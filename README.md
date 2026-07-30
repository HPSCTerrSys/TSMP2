# Terrestrial Systems Modeling Platform v2 (TSMP2)

[![helmholtz rsd](https://img.shields.io/badge/helmholtz.software-tsmp2-00a3e3)](https://helmholtz.software/software/tsmp2)
[![doi](https://img.shields.io/badge/doi-preprint-00a3e3)](https://doi.org/10.5194/egusphere-2025-5468)

## Introduction 

The [Terrestrial System Modeling Platform v2 (TSMP2)] is an open source scale-consistent, highly modular, massively parallel regional Earth system model. TSMP2 essentially consists of an interface which couples dedicated versions of the ICOsahedral Nonhydrostatic ([ICON]) atmospheric model in NWP or climate mode, the encore Community Land Model ([eCLM]), and the hydrologic model [ParFlow] through the [OASIS3-MCT] coupler.

TSMP2 allows for a physically-based representation of transport processes of mass, energy and momentum and interactions between the different compartments of the geo-ecosystem across scales, explicitly reproducing feedbacks in the hydrological cycle from the groundwater into the atmosphere.

TSMP2-PDAF describes the build commands of TSMP2 that can introduce data assimilation for an ensemble of TSMP2 simulations using the Parallel Data Assimilation Framework ([PDAF]). For more information, see the [TSMP-PDAF] documentation.

TSMP2 development has been driven by groups within the [Center for High-Performance Scientific Computing in Terrestrial Systems] (HPSC-TerrSys).

## Quickstart

Please see [quickstart section] for guided steps on how the model can be build.

## Usage / Documentation

Please check the documentation at https://hpscterrsys.github.io/TSMP2

## Contributing

Feel free to post your questions and problems via the [issue tracker]. We also welcome [pull requests]. Before opening an issue or a pull request, please review our **[contribution guidelines]**.

For general inquiries, leave us a message on our [TSMP2 Matrix channel].

## License
TSMP2 is open source software and is licensed under the [MIT-License](https://github.com/HPSCTerrSys/TSMP2/blob/master/LICENSE.txt).

[Terrestrial System Modeling Platform v2 (TSMP2)]: https://www.terrsysmp.org
[ICON]: https://www.icon-model.org
[eCLM]: https://github.com/HPSCTerrSys/eCLM
[ParFlow]: https://www.parflow.org
[OASIS3-MCT]: https://oasis.cerfacs.fr/en/home
[PDAF]: https://pdaf.awi.de/trac/wiki
[TSMP-PDAF]: https://hpscterrsys.github.io/pdaf
[Center for High-Performance Scientific Computing in Terrestrial Systems]: http://www.hpsc-terrsys.de
[quickstart section]: ./docs/users_guide/building_TSMP2/Quickstart.md
[issue tracker]: https://github.com/HPSCTerrSys/TSMP2/issues
[pull requests]: https://github.com/HPSCTerrSys/TSMP2/pulls
[contribution guidelines]: CONTRIBUTING.md
[TSMP2 Matrix channel]: https://matrix.to/#/!PIarBDtnbrOJHXiixi:fz-juelich.de?via=fz-juelich.de&via=matrix.org
