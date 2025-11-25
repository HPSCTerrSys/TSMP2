Modify "config_autom_builds.in". Write components and environments to build.
To use:
./autom_builds.sh

This will create a matrix of builds with the components and environments specified in "config_autom_builds.in" file.
For instance, if below components are: ICON, eCLM, ICON eCLM; and below environments: jsc.2025.intel.psmpi and jsc.2025.gnu.openmpi as:

The optinos specified under `OPTIONS` will be used in the `./build_tsmp2.sh` command of each build in the matrix.

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

It will build each combination twice (one for each environment).
The `bin` and `bld` folders are named as:
<SYSTEMNAME-UPPERCASE_combination_environment>
