# Building TSMP2 with CMake

> [!NOTE]
> For experienced users.
> The result of the following commands may be different from the Quickstart above, most notably because the branches/commits in the `git clone` commands are not kept in sync with those in the `build_tsmp2.sh` script.
> The [Quickstart](#Quickstart) is the tested and supported method.

1. Clone this repository.

```bash
git clone https://github.com/HPSCTerrSys/TSMP2.git
export TSMP2_DIR=$(realpath TSMP2)
cd $TSMP2_DIR
```

2. Load the environment variables required for the build.

```bash
source env/jsc.2024_Intel.sh
```

3. Specify build and install directories.

```bash
# Name of the coupled model (e.g. ICON-eCLM, CLM3.5-COSMO-ParFlow, CLM3.5-ParFlow, CLM3.5-ParFlow-PDAF)
MODEL_ID="ICON-eCLM-ParFlow"

# Build artifacts will be generated in this folder. It can be deleted after build.
BUILD_DIR="./bld/${SYSTEMNAME^^}_${MODEL_ID}"

# Model executables and libraries will be installed here
INSTALL_DIR="./bin/${SYSTEMNAME^^}_${MODEL_ID}"

# Create build and install directories
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}
```

4. Download the OASIS3-MCT coupling library and the component models
you wish to use. You can check out the supported submodule commits
using

```bash
# eCLM
git submodule update --init -- models/eCLM

# ICON
git submodule update --init -- models/icon

# ParFlow
git submodule update --init -- models/parflow

# ParFlow (PDAF-patched)
git submodule update --init -- models/parflow_pdaf

# CLM3.5
git submodule update --init -- models/CLM3.5

# COSMO5.01
git submodule update --init -- models/cosmo5.01_fresh

# OASIS3-MCT (required for coupled models)
git submodule update --init -- models/oasis3-mct

# PDAF
git submodule update --init -- models/pdaf
```

If you wish to use alternative (possibly unsupported) commits of
component models, clone them explicitly. Then save the full path to
each model source code to `<model-name>_SRC`. Examples are given
below:

```bash
## NOTE: Download only the component models that you need! ##

# eCLM
git clone -b beta-0.2 https://github.com/HPSCTerrSys/eCLM.git models/eCLM
eCLM_SRC=`realpath models/eCLM`

# ICON
git clone https://icg4geo.icg.kfa-juelich.de/spoll/icon2.6.4_oascoup.git models/icon
ICON_SRC=`realpath models/icon`

# ParFlow
git clone https://github.com/parflow/parflow.git models/parflow
PARFLOW_SRC=`realpath models/parflow`

# ParFlow (PDAF-patched)
git clone -b v3.13.0-pdaf https://github.com/HPSCTerrSys/parflow models/parflow_pdaf
PARFLOW_SRC=`realpath models/parflow_pdaf`

# CLM3.5
git clone -b tsmp-patches-v0.1 https://github.com/HPSCTerrSys/CLM3.5.git models/CLM3.5
CLM35_SRC=`realpath models/CLM3.5`

# COSMO5.01
git clone -b tsmp-oasis https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git models/cosmo5.01_fresh
COSMO_SRC=`realpath models/cosmo5.01_fresh`

# OASIS3-MCT (required for coupled models)
git clone -b tsmp-patches-v0.1 https://icg4geo.icg.kfa-juelich.de/ExternalReposPublic/oasis3-mct models/oasis3-mct
OASIS_SRC=`realpath models/oasis3-mct`

# PDAF
git clone -b PDAF_V2.2.1-tsmp https://github.com/HPSCTerrSys/pdaf.git models/pdaf
PDAF_SRC=`realpath models/pdaf`
```

5. Run CMake configure step for the model combination that you wish to build. The
   examples below show different CMake configure commands for each model combination. 

```bash
#
#  The component source is searched in models/component by default but there is also the possibility to choose the path to the source code of components with -D<COMP>_SRC=${<COMP>_SRC}. OASIS is taken by default when coupled models are chosen.
#

# ICON-eCLM
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM=ON                               \
      -DICON=ON

# eCLM-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM=ON                               \
      -DPARFLOW_SRC=ON

# ICON-eCLM-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM=ON                               \
      -DICON=ON                               \
      -DPARFLOW=ON

# CLM3.5-COSMO5.01-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35=ON                              \
      -DCOSMO=ON                              \
      -DPARFLOW=ON

# CLM3.5-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35=ON                          \
      -DPARFLOW=ON

# CLM3.5-COSMO5.01
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35=ON                          \
      -DCOSMO=ON

#
# For standalone models
# pass the component model name (i.e. -D<model-name>=ON).
#

# CLM3.5 standalone
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35=ON

# eCLM standalone
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM=ON

# ParFlow standalone
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DPARFLOW=ON

#
# For TSMP-PDAF builds, add -PDAF=ON
#

# CLM3.5-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35=ON                              \
      -DPDAF=ON

# CLM3.5-ParFlow-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35=ON                              \
      -DPARFLOW=ON                            \
      -DPDAF=ON

# eCLM-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM=ON                               \
      -DPDAF=ON

# eCLM-ParFlow-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM=ON                               \
      -DPARFLOW=ON                            \
      -DPDAF=ON

```

6. Build and install the models.

```bash
cmake --build ${BUILD_DIR}
cmake --install ${BUILD_DIR}
```

## Resuming a failed build

When the build gets interrupted or fails for some reason, it can be resumed by simply running Step 6:

```bash
cmake --build ${BUILD_DIR}
cmake --install ${BUILD_DIR}
```

Note that this works only if the required environment variables are already set. If you are resuming
the build from a fresh terminal session, first you need to run `source env/jsc.2023_Intel.sh`  (Step 2), specify `BUILD_DIR` (Step 3) and set `<model-name>_SRC` (Step 4) before you can run Step 6.

## Rebuilding specific component models

TSMP2 can rebuild a specific component model via the `cmake --build ${BUILD_DIR} --target ${MODEL}` command.
This may be useful when you need to recompile a component model that has been modified or updated.

```bash
# Rebuilding examples

cmake --build ${BUILD_DIR} --target eCLM && cmake --install ${BUILD_DIR}                  # Rebuilds eCLM
cmake --build ${BUILD_DIR} --target ICON && cmake --install ${BUILD_DIR}                  # Rebuilds ICON
cmake --build ${BUILD_DIR} --clean-first --target ParFlow && cmake --install ${BUILD_DIR} # Does a clean rebuild of ParFlow
```

Only component models specified during CMake configure step (see Step 5) can be rebuilt. For instance, if you
configured TSMP2 to build `eCLM-ParFlow`, then rebuilding `ICON` would of course be not possible.

The list below shows all component models supported by TSMP2. To rebuild a component model(s),
run one or more commands below, wait until the build succeeds, then finally run 
`cmake --install ${BUILD_DIR}` so that the generated libraries and executables are copied to `${INSTALL_DIR}`.

- `cmake --build ${BUILD_DIR} --target eCLM`
- `cmake --build ${BUILD_DIR} --target ParFlow`
- `cmake --build ${BUILD_DIR} --target ICON`
- `cmake --build ${BUILD_DIR} --target OASIS3_MCT`
- `cmake --build ${BUILD_DIR} --target CLM3_5`
- `cmake --build ${BUILD_DIR} --target COSMO5_1`

