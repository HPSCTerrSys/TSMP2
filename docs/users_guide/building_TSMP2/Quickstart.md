# Quickstart

```{tip}
`build_tsmp2.sh` is a lightweight shell-script calling the CMake-based build-system. During execution of `build_tsmp2.sh`, the executed CMake-command is printed out. For advanced build use-cases, users can modify the outputted CMake command or directly head over to {doc}`BuildingTSMP2wCMake`.
```

1. Clone this repository.

```bash
git clone https://github.com/HPSCTerrSys/TSMP2.git
cd TSMP2
```

2. Build model components with TSMP2 framework

To build a model component one need to activate the component model `<COMP>`. The options are not case-sensitive and do not need to be in an specific order.

```{note}
The component models (git submodules) are cloned during the execution of `build_tsmp2.sh`. If the component model (`models/<COMP>`) are already exists, the user is asked if the folder should be overwritten or not. If you do want to use the default model component source codes, one can use the option `<COMP_SRC>`.
```

```bash
# to see options
./build_tsmp2.sh --help

# Build the fully-coupled model (ICON-eCLM-ParFlow)
./build_tsmp2.sh icon eclm parflow

# Other possible model combinations
./build_tsmp2.sh eclm parflow
./build_tsmp2.sh icon eclm
./build_tsmp2.sh eclm pdaf

# Build ICON from a local source repo
./build_tsmp2.sh ICON --ICON_SRC ${ICON_SRC}

# Build ParFlow on Marvin (Uni Bonn)
./build_tsmp2.sh ParFlow --env env/uni-bonn.gnu.openmpi


# Fancy way of building a fully-coupled model
echo "eCLM ICON ParFlow" | xargs -t ./build_tsmp2.sh --no_update --clean_first

# Build multiple combinations (useful for CI)
cat << EOF > model_combinations.txt
icon eclm parflow
eclm parflowgpu
icon eclm
eclm pdaf
EOF
cat model_combinations.txt | xargs -t -L 1 ./build_tsmp2.sh --no_update
```

