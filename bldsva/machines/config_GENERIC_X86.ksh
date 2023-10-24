#! /bin/ksh


getMachineDefaults(){
route "${cyellow}>> getMachineDefaults${cnormal}"
  #defaultMpiPath="$rootdir/lib/openmpi"
  defaultMpiPath=/usr/lib/x86_64-linux-gnu
  defaultNcdfPath="$rootdir/lib/netcdf"
  defaultGribPath="$rootdir/lib/gribapi"
  defaultGribapiPath="$rootdir/lib/gribapi"
  defaultJasperPath=""
#  defaultTclPath="/usr/lib/x86_64-linux-gnu"
  defaultTclPath="$rootdir/lib/tcl"
  #defaultHyprePath="$rootdir/lib/hypre"
  defaultHyprePath=/usr/lib/x86_64-linux-gnu
  defaultSiloPath="$rootdir/lib/silo"
  hdf5path="$rootdir/lib/hdf5"
  defaultLapackPath=""
  defaultPncdfPath=""
  export PATH="$defaultTclPath/bin:$PATH"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$defaultSiloPath/lib"
  #echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  #echo "tclsh is loaded "

  # Default Compiler/Linker optimization
  defaultOptC="-O2"

  profilingImpl=" no scalasca "
  profComp=""
  profRun=""
  profVar=""

  # Default Processor settings
  defaultwtime=""
  defaultQ=""

route "${cyellow}<< getMachineDefaults${cnormal}"
}

Npp=4

PFLProcXg=1
PFLProcYg=1
CLMProcXg=1
CLMProcYg=1
COSProcXg=1
COSProcYg=1
if [[ $refSetup == "cordex" ]] then
	PFLProcX=1
	PFLProcY=1
	CLMProcX=1
	CLMProcY=1
	COSProcX=1
	COSProcY=1
	elif [[ $refSetup == "nrw" ]] then
	PFLProcX=1
	PFLProcY=1
	CLMProcX=1
	CLMProcY=1
	COSProcX=1
	COSProcY=1
	elif [[ $refSetup == "idealRTD" ]] then
	PFLProcX=1
	PFLProcY=1
	CLMProcX=1
	CLMProcY=1
	COSProcX=1
	COSProcY=1
	else 
	PFLProcX=1
	PFLProcY=1
	CLMProcX=1
	CLMProcY=1
	COSProcX=1
	COSProcY=1
fi

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$rootdir/lib/silo/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$rootdir/lib/hdf5/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$rootdir/lib/hypre/lib"
