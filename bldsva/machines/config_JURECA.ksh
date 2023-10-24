#! /bin/ksh


getMachineDefaults(){
route "${cyellow}>> getMachineDefaults${cnormal}"
  comment "   init lmod functionality"
  . /p/software/jurecadc/lmod/lmod/init/ksh >> $log_file 2>> $err_file
  check
  comment "   source and load Modules on JURECA"
  . $rootdir/env/jsc.2023_Intel.sh >> $log_file 2>> $err_file
  check


  defaultMpiPath="$EBROOTPSMPI"
  defaultNcdfPath="$EBROOTNETCDFMINFORTRAN"
  if [[ $compiler == "Gnu" ]] ; then
    defaultGrib1Path="/p/project/cslts/local/jureca/DWD-libgrib1_20110128_Gnu/lib/"
  elif [[ $compiler == "Intel" ]] ; then
    defaultGrib1Path="/p/project/cslts/local/jureca/DWD-libgrib1_20110128_Intel/lib/"
  else
    defaultGrib1Path="/p/project/cslts/local/jureca/DWD-libgrib1_20110128_Intel/lib/"
  fi
  defaultGribPath="$EBROOTECCODES"
  defaultGribapiPath="$EBROOTECCODES"
  defaultJasperPath="$EBROOTJASPER"
  defaultTclPath="$EBROOTTCL"
  defaultHyprePath="$EBROOTHYPRE"
  defaultSiloPath="$EBROOTSILO"
  defaultLapackPath="$EBROOTIMKL"
  defaultPncdfPath="$EBROOTPARALLELMINNETCDF"
  # Additional option for GPU compilation  
  gpuMpiSettings=
  cuda_architectures=""

  # Default Compiler/Linker optimization
  if [[ $compiler == "Gnu" ]] ; then
      defaultOptC="-O2" # Gnu
  elif [[ $compiler == "Intel" ]] ; then
      defaultOptC="-O2 -xHost" # Intel
  else
      defaultOptC="-O2" # Default
  fi

  profilingImpl=" no scalasca "  
  if [[ $profiling == "scalasca" ]] ; then ; profComp="" ; profRun="scalasca -analyse" ; profVar=""  ;fi

  # Default Processor settings
  defaultwtime="01:00:00"
  defaultQ="dc-cpu-devel"

route "${cyellow}<< getMachineDefaults${cnormal}"
}

# computes nodes based on number of processors and resources
computeNodes(){
processes=$1
resources=$2
echo $((processes%resources?processes/resources+1:processes/resources))
}

Npp=128
Ngp=4

PFLProcXg=1
PFLProcYg=4
CLMProcXg=6
CLMProcYg=8
COSProcXg=16
COSProcYg=16
if [[ $refSetup == "cordex" ]] then
	PFLProcX=9
	PFLProcY=8
	CLMProcX=3
	CLMProcY=8
	COSProcX=16
	COSProcY=18
	elif [[ $refSetup == "nrw" ]] then
	PFLProcX=5
	PFLProcY=8
	CLMProcX=4
	CLMProcY=4
	COSProcX=6
	COSProcY=12
	elif [[ $refSetup == "idealRTD" ]] then
	PFLProcX=2
	PFLProcY=2
	CLMProcX=2
	CLMProcY=2
	COSProcX=6
	COSProcY=5
	else 
	PFLProcX=4
	PFLProcY=4
	CLMProcX=4
	CLMProcY=2
	COSProcX=8
	COSProcY=8
fi
