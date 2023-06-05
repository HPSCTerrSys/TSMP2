## Quickstart

1. Clone this repository.

```bash
git clone https://github.com/HPSCTerrSys/eTSMP.git
cd eTSMP
```

2. Load the environment variables required for the build.

```bash
source env/jsc.2022_Intel.sh
```

3. Specify build and install directories.

```bash
# Name of the coupled model (e.g. eCLM-ICON, CLM3.5-COSMO-ParFlow, CLM3.5-ParFlow)
MODEL_ID="eCLM-ParFlow"

# Build artifacts will be generated in this folder. It can be deleted after build.
BUILD_DIR="./bld/${SYSTEMNAME^^}_${MODEL_ID}"

# Model executables and libraries will be installed here
INSTALL_DIR="./bin/${SYSTEMNAME^^}_${MODEL_ID}"

# Create build and install directories
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}
```

4. Download component models that you wish to build. Then store the
path of each model to `<model-name>_SRC` variable.

```bash
# NOTE: Clone only the component models that you need!

# eCLM
git clone https://github.com/HPSCTerrSys/eCLM.git
eCLM_SRC=`realpath eCLM`

# ICON
git clone https://icg4geo.icg.kfa-juelich.de/spoll/icon2.6.4_oascoup.git
ICON_SRC=`realpath icon2.6.4_oascoup`

# ParFlow
git clone -b v3.12.0 https://github.com/parflow/parflow.git
PARFLOW_SRC=`realpath parflow`

# CLM3.5
git clone https://github.com/HPSCTerrSys/CLM3.5.git
CLM35_SRC=`realpath CLM3.5`

# COSMO5.01
git clone -b tsmp-oasis https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git
COSMO_SRC=`realpath cosmo5.01_fresh`
```

5. Supply the build and install directories (step 2) and the paths to component models (step 3) to CMake. 
CMake will only build the models specified by the user. Supported coupled models are listed below.

```bash
# eCLM-ICON
cmake -S . -B ${BUILD_DIR}                  \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DeCLM_SRC=${eCLM_SRC}                \
      -DICON_SRC=${ICON_SRC}

# eCLM-ParFlow
cmake -S . -B ${BUILD_DIR}                  \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DeCLM_SRC=${eCLM_SRC}                \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# eCLM-ICON-ParFlow
cmake -S . -B ${BUILD_DIR}                  \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DeCLM_SRC=${eCLM_SRC}                \
      -DICON_SRC=${ICON_SRC}		      \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# CLM3.5-COSMO5.01-ParFlow
cmake -S . -B ${BUILD_DIR}                  \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DCLM35_SRC=${CLM35_SRC}              \
      -DCOSMO_SRC=${COSMO_SRC}              \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# CLM3.5-ParFlow
cmake -S . -B ${BUILD_DIR}                  \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DCLM35_SRC=${CLM35_SRC}              \
      -DPARFLOW_SRC=${PARFLOW_SRC}

# CLM3.5-COSMO5.01
cmake -S . -B ${BUILD_DIR}                  \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DCLM35_SRC=${CLM35_SRC}              \
      -DCOSMO_SRC=${COSMO_SRC}
```

6. Build and install the models.

```bash
cmake --build ${BUILD_DIR}
cmake --install ${BUILD_DIR}
```
