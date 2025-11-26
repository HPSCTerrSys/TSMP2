HOW TO USE the `autom_builds.sh`

1) Modify `./scripts/ci/config_autom_builds.conf` file: 
- Write the components and environments to build below the `COMBINATIONS` and `ENVIRONMENTS` sections, respectively. These inputs are case sensitive, use as shown in the example below.
- Add other options to the build command below the OPTIONS section. The options specified under `OPTIONS` will be used in the `./build_tsmp2.sh` command of each build in the matrix.

2) Make a copy of `./scripts/ci/autom_builds.sh` file into the same folder as `build_tsmp2.sh` ($TSMP2_dir)

3) Work within the working directory $TSMP2_dir:
```
./autom_builds.sh
``` 

`autom_builds.sh` will create a matrix of builds with the components and environments specified in "config_autom_builds.conf" file.
For instance, if below components are: ICON, eCLM, ICON eCLM; and below environments: jsc.2025.intel.psmpi and jsc.2025.gnu.openmpi as:

#########################
COMBINATIONS:
ICON
eCLM
ICON eCLM

ENVIRONMENTS:
jsc.2025.intel.psmpi
jsc.2025.gnu.openmpi

OPTIONS:
--build_type RELEASE
################################

It will build each combination twice (one for each environment) with build type `RELEASE`.

The `bin` and `bld` folders are named as:
<SYSTEMNAME-UPPERCASE_combination_environment>

If one build fails, the build will be named as:
<SYSTEMNAME-UPPERCASE_combination_environment_FAILED>

A log-summary with the names of the builds will be created in `./scripts/ci/` folder.