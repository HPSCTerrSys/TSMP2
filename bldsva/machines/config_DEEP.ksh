#! /bin/ksh


getMachineDefaults(){
route "${cyellow}>> getMachineDefaults${cnormal}"
  comment "   init lmod functionality"
  . /beegfs/usr_local/software/lmod/lmod/init/ksh >> $log_file 2>> $err_file
  check
  comment "   source and load Modules on DEEP: jsc.2023_Intel.sh"
  . $rootdir/env/jsc.2023_Intel.sh >> $log_file 2>> $err_file
  check

  defaultMpiPath="$EBROOTPSMPI"
  defaultNcdfPath="$EBROOTNETCDFMINFORTRAN"
  defaultGrib1Path=""
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
  cuda_architectures="-DCMAKE_CUDA_ARCHITECTURES=70"
#
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
  defaultQ="dp-cn"

  # DEEP only (because of problems with the perl path in CLM 3.5)
  if [[ $platform == "DEEP" ]]; then
      echo
      echo "Platform: $platform"
      echo
      
      sed -i -e 's+/usr/bin/env perl+/usr/bin/perl+' ${rootdir}/clm3_5/bld/mkDepends
      sed -i -e 's+/usr/bin/env perl+/usr/bin/perl+' ${rootdir}/clm3_5/bld/configure
      sed -i -e 's+/usr/bin/env perl+/usr/bin/perl+' ${rootdir}/clm3_5/bld/mkSrcfiles
      sed -i -e 's+/usr/bin/env perl+/usr/bin/perl+' ${rootdir}/clm3_5/bld/queryDefaultNamelist.pl
      sed -i -e 's+/usr/bin/env perl+/usr/bin/perl+' ${rootdir}/bldsva/intf_oas3/clm3_5/arch/config/configure
  fi
  
  route "${cyellow}<< getMachineDefaults${cnormal}"
}

# computes nodes based on number of processors and resources
computeNodes(){
processes=$1
resources=$2
echo $((processes%resources?processes/resources+1:processes/resources))
}


Npp=24
Ngp=1

PFLProcXg=1
PFLProcYg=1
CLMProcXg=3
CLMProcYg=8
COSProcXg=12
COSProcYg=16
if [[ $refSetup == "cordex" ]] then
	PFLProcX=9
	PFLProcY=8
	CLMProcX=3
	CLMProcY=8
	COSProcX=12
	COSProcY=16
	elif [[ $refSetup == "nrw" ]] then
	PFLProcX=4
	PFLProcY=6
	CLMProcX=8
	CLMProcY=3
	COSProcX=12
	COSProcY=16
	elif [[ $refSetup == "idealRTD" ]] then
	PFLProcX=2
	PFLProcY=2
	CLMProcX=2
	CLMProcY=6
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

