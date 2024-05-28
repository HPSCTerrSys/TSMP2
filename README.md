## Quickstart

1. Clone this repository.

```bash
git clone https://github.com/HPSCTerrSys/TSMP2.git
export TSMP2_DIR=$(realpath TSMP2)
cd $TSMP2_DIR
```

2. Load the environment variables required for the build.

```bash
source env/jsc.2023_Intel.sh
```

3. Specify build and install directories.

```bash
# Name of the coupled model (e.g. ICON-eCLM, CLM3.5-COSMO-ParFlow, CLM3.5-ParFlow, CLM3.5-ParFlow-PDAF)
MODEL_ID="ICON-eCLM-ParFlow"

# Build artifacts will be generated in this folder. It can be deleted after build.
BUILD_DIR="./bld/${SYSTEMNAME^^}_${MODEL_ID}"

# Model executables and libraries will be installed here
INSTALL_DIR="./run/${SYSTEMNAME^^}_${MODEL_ID}"

# Create build and install directories
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}
```

4. Download the OASIS3-MCT coupling library and the component models that you wish
   to use. Then save the full path to each model source code to `<model-name>_SRC`.

```bash
## NOTE: Download only the component models that you need! ##

# eCLM
git clone https://github.com/HPSCTerrSys/eCLM.git
eCLM_SRC=`realpath eCLM`

# ICON
git clone https://icg4geo.icg.kfa-juelich.de/spoll/icon2.6.4_oascoup.git
ICON_SRC=`realpath icon2.6.4_oascoup`

# ParFlow
git clone -b v3.12.0 https://github.com/parflow/parflow.git
PARFLOW_SRC=`realpath parflow`

# ParFlow (PDAF-patched)
git clone -b v3.12.0-tsmp https://github.com/HPSCTerrSys/parflow
PARFLOW_SRC=`realpath parflow`

# CLM3.5
git clone -b tsmp-patches-v0.1 https://github.com/HPSCTerrSys/CLM3.5.git
CLM35_SRC=`realpath CLM3.5`

# COSMO5.01
git clone -b tsmp-oasis https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git
COSMO_SRC=`realpath cosmo5.01_fresh`

# OASIS3-MCT (required for coupled models)
git clone -b tsmp-patches-v0.1 https://icg4geo.icg.kfa-juelich.de/ExternalReposPublic/oasis3-mct
OASIS_SRC=`realpath oasis3-mct`

# PDAF
git clone -b PDAF_V2.2.1-tsmp https://github.com/HPSCTerrSys/pdaf.git
PDAF_SRC=`realpath pdaf`
```

5. Run CMake configure step for the model combination that you wish to build. The
   examples below show different CMake configure commands for each model combination. 

```bash
#
# Coupled models requires the option -DOASIS_SRC=${OASIS_SRC}.
#

# ICON-eCLM
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DeCLM_SRC=${eCLM_SRC}                  \
      -DICON_SRC=${ICON_SRC}

# eCLM-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DeCLM_SRC=${eCLM_SRC}                  \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# ICON-eCLM-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DeCLM_SRC=${eCLM_SRC}                  \
      -DICON_SRC=${ICON_SRC}		          \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# CLM3.5-COSMO5.01-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DCLM35_SRC=${CLM35_SRC}                \
      -DCOSMO_SRC=${COSMO_SRC}                \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# CLM3.5-ParFlow
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DCLM35_SRC=${CLM35_SRC}                \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# CLM3.5-COSMO5.01
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DCLM35_SRC=${CLM35_SRC}                \
      -DCOSMO_SRC=${COSMO_SRC}

#
# For standalone models, remove -DOASIS_SRC=${OASIS_SRC}
# and pass the path to the component model (i.e. -D<model-name>_SRC=${<model-name>_SRC}).
#

# CLM3.5 standalone
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35_SRC=${CLM35_SRC}

# eCLM standalone
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM_SRC=${eCLM_SRC}

# ParFlow standalone
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DPARFLOW_SRC=${PARFLOW_SRC}

#
# For TSMP-PDAF builds, add -PDAF_SRC=${PDAF_SRC}
#

# CLM3.5-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DCLM35_SRC=${CLM35_SRC}                \
      -DPDAF_SRC=${PDAF_SRC}

# CLM3.5-ParFlow-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DCLM35_SRC=${CLM35_SRC}                \
      -DPARFLOW_SRC=${PARFLOW_SRC}            \
      -DPDAF_SRC=${PDAF_SRC}

# eCLM-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DeCLM_SRC=${eCLM_SRC}                \
      -DPDAF_SRC=${PDAF_SRC}

# eCLM-ParFlow-PDAF
cmake -S . -B ${BUILD_DIR}                    \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      -DOASIS_SRC=${OASIS_SRC}                \
      -DeCLM_SRC=${eCLM_SRC}                \
      -DPARFLOW_SRC=${PARFLOW_SRC}            \
      -DPDAF_SRC=${PDAF_SRC}

```

6. Build and install the models.

```bash
cmake --build ${BUILD_DIR}
cmake --install ${BUILD_DIR}
```

### Resuming a failed build

When the build gets interrupted or fails for some reason, it can be resumed by simply running Step 6:

```bash
cmake --build ${BUILD_DIR}
cmake --install ${BUILD_DIR}
```

Note that this works only if the required environment variables are already set. If you are resuming
the build from a fresh terminal session, first you need to run `source env/jsc.2023_Intel.sh`  (Step 2), specify `BUILD_DIR` (Step 3) and set `<model-name>_SRC` (Step 4) before you can run Step 6.

### Rebuilding specific component models

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
