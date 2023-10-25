#! /bin/ksh

#######################################
#		Main
#######################################

  # Colors
  cyellow=$(tput setaf 3)
  cnormal=$(tput sgr0)   #9
  cred=$(tput setaf 1)
  cgreen=$(tput setaf 2)
  cmagenta=$(tput setaf 5)
  ccyan=$(tput setaf 6)

  date=`date +%d%m%y-%H%M%S`

  rootdir=/p/scratch/cjibg36/jibg3683/DATAASSIMILATION/TSMP-PDAF/eTSMP

  # Log files
  log_file=$cpwd/log_all_${date}.txt
  err_file=$cpwd/err_all_${date}.txt
  stdout_file=$cpwd/stdout_all_${date}.txt
  rm -f $log_file $err_file $stdout_file

  # Component model configuration
  withOAS="true"
  withCOS="false"
  withICON="false"
  withPFL="true"
  withCLM="true"
  withOASMCT="true"
  withPCLM="false"
#DA
  withDA="true"
  withPDAF="true"

  print "   init lmod functionality"
  # "jurecadc", "juwels"
  . /p/software/jurecadc/lmod/lmod/init/ksh >> $log_file 2>> $err_file

  print "   source and load Modules $rootdir"
  . $rootdir/env/jsc.2023_Intel.ksh >> $log_file 2>> $err_file

  defaultMpiPath="$EBROOTPSMPI"
  defaultNcdfPath="$EBROOTNETCDFMINFORTRAN"
  # "jureca", "juwels"
  defaultGrib1Path="/p/project/cslts/local/jureca/DWD-libgrib1_20110128_Intel/lib/"
  defaultGribPath="$EBROOTECCODES"
  defaultGribapiPath="$EBROOTECCODES"
  defaultJasperPath="$EBROOTJASPER"
  defaultTclPath="$EBROOTTCL"
  defaultHyprePath="$EBROOTHYPRE"
  defaultSiloPath="$EBROOTSILO"
  defaultLapackPath="$EBROOTIMKL"
  defaultPncdfPath="$EBROOTPARALLELMINNETCDF"

  # Default Compiler/Linker optimization
  if [[ $compiler == "Gnu" ]] ; then
      defaultOptC="-O2" # Gnu
  elif [[ $compiler == "Intel" ]] ; then
      defaultOptC="-O2 -xHost" # Intel
  else
      defaultOptC="-O2" # Default
  fi

  if [[ $mpiPath == "" ]] then ; mpiPath=$defaultMpiPath ; fi
  if [[ $ncdfPath == "" ]] then ; ncdfPath=$defaultNcdfPath  ; fi
  if [[ $grib1Path == "" ]] then ; grib1Path=$defaultGrib1Path ; fi
  if [[ $gribPath == "" ]] then ; gribPath=$defaultGribPath ; fi
  if [[ $tclPath == "" ]] then ; tclPath=$defaultTclPath ; fi
  if [[ $hyprePath == "" ]] then ; hyprePath=$defaultHyprePath ; fi
  if [[ $siloPath == "" ]] then ; siloPath=$defaultSiloPath ; fi
  if [[ $pnetcdfPath == "" ]] then ; pncdfPath=$defaultPncdfPath ; fi
  if [[ $lapackPath == "" ]] then ; lapackPath=$defaultLapackPath ; fi

  #compiler optimization
  if [[ $optComp == "" ]] then ; optComp=$defaultOptC ; fi
  
  #compiler selection
  if [[ $compiler == "" ]] then ; compiler=$defaultcompiler ; fi
  if [[ $processor == "" ]] then ; processor=$defaultprocessor ; fi

  #  binary directory
  bindir=$rootdir/bin/

  # libs directory
  mkdir -p $bindir/libs >> $log_file 2>> $err_file

  # oasis3-mct
  if [[ $withOAS == "true" ]] ; then
    oasdir=$rootdir/run/JURECADC_eCLM-ParFlow/OASIS3-MCT/
    libpsmile="$oasdir/lib/libpsmile.MPI1.a $oasdir/lib/libmct.a $oasdir/lib/libmpeu.a $oasdir/lib/libscrip.a"

    print "    cp oas libs to $bindir/libs"
    cp $libpsmile $bindir/libs >> $log_file 2>> $err_file
  fi

  # clm
  if [[ $withCLM == "true" ]] ; then
    clmdir=$rootdir/bld/JURECADC_eCLM-ParFlow/CLM3_5

    print "    cd to clm build dir"
      cd $clmdir/bld >> $log_file 2>> $err_file
    print "    ar clm libs"
      ar rc libclm.a *.o >> $log_file 2>> $err_file
    print "    cp libs to $bindir/libs"
      cp $clmdir/bld/libclm.a $bindir/libs >> $log_file 2>> $err_file
  fi

  # parflow
  if [[ $withPFL == "true" ]] ; then
    pfldir=$rootdir/run/JURECADC_eCLM-ParFlow

    print "    cp libs to $bindir/libs"
      cp $pfldir/lib/* $bindir/libs >> $log_file 2>> $err_file
    if [[ $processor == "GPU" ]]; then
      print "    GPU: cp rmm libs to $bindir/libs"
        cp $pfldir/rmm/lib/* $bindir/libs >> $log_file 2>> $err_file
    fi

    # Change pfldir to bld
    pfldir=$rootdir/parflow

  fi

  # directory for pdaf
  dadir=$rootdir/pdaf/

  #compile DA
  print "  source da interface script"
    . ${rootdir}/bldsva/intf_DA/pdaf/arch/build_interface_pdaf.ksh >> $log_file 2>> $err_file

#PDAF part configuration variables
  export PDAF_DIR=$dadir
  export PDAF_ARCH=linux_ifort # "linux_ifort", "linux_gfortran_openmpi"

  comFC="${mpiPath}/bin/mpif90" # "${mpiPath}/bin/mpif90", "scorep-mpif90"
  comCC="${mpiPath}/bin/mpicc"  # "${mpiPath}/bin/mpicc", "scorep-mpicc"

#    libs_src=" -L$lapackPath -L${mpiPath}/lib64"
#    libs_src=" -L$lapackPath -lopenblas -L${mpiPath}/lib64"
#    libs_src=" $lapackPath/mkl/lib/intel64/libmkl_intel_lp64.a $lapackPath/mkl/lib/intel64/libmkl_intel_thread.a $lapackPath/mkl/lib/intel64/libmkl_core.a -L${mpiPath}/lib64"
#    libs_src=" -L$lapackPath -llapack -lblas -L${mpiPath}/lib64"
#    libs_src=" -L$lapackPath/mkl/lib/intel64 -Wl,--no-as-needed -lmkl_scalapack_ilp64 -lmkl_cdft_core -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_ilp64 -lm -ldl -L${mpiPath}/lib64 -lirc -lintlc"
#    libs_src=" -ldl $lapackPath/mkl/latest/lib/intel64/libmkl_gf_lp64.a $lapackPath/mkl/latest/lib/intel64/libmkl_gnu_thread.a $lapackPath/mkl/latest/lib/intel64/libmkl_core.a -L${mpiPath}/lib64"
  libs_src=" $lapackPath/mkl/latest/lib/intel64/libmkl_intel_lp64.a $lapackPath/mkl/latest/lib/intel64/libmkl_intel_thread.a $lapackPath/mkl/latest/lib/intel64/libmkl_core.a -L${mpiPath}/lib64"

#PDAF arch part
  file=$dadir/make.arch/${PDAF_ARCH}.h

  print "   sed comFC dir to $file"
  sed -i "s@__comFC__@${comFC}@" $file >> $log_file 2>> $err_file

  print "   sed comCC dir to $file"
  sed -i "s@__comCC__@${comCC}@" $file >> $log_file 2>> $err_file

  print "   sed MPI dir to $file"
    sed -i "s@__MPI_INC__@-I${mpiPath}/include@" $file >> $log_file 2>> $err_file

  print "   sed LIBS to $file"
    sed -i "s@__LIBS__@${libs_src}@" $file >> $log_file 2>> $err_file

  print "   sed optimizations to $file"
    sed -i "s@__OPT__@${optComp}@" $file >> $log_file 2>> $err_file

  print "   cd to $dadir/src"
    cd $dadir/src >> $log_file 2>> $err_file

  print "   make clean pdaf"
    make clean >> $log_file 2>> $err_file

#PDAF interface part configuration variables
  importFlags=" "
  importFlagsOAS=" "
  importFlagsPFL=" "
  importFlagsCLM=" "
  importFlagsCOS=" "
  importFlagsDA=" "
  cppdefs=" "
  obj=' '
  libs=" -L$mpiPath -lmpich -L$netcdfPath/lib/ -lnetcdff -lnetcdf "
  libsOAS=" "
  libsPFL=" "
  libsCLM=" "
  libsCOS=" "
  pf=""

  # Oasis include dirs
  importFlagsOAS+="-I$oasdir/JURECA/build/lib/psmile.MPI1 "
  importFlagsOAS+="-I$oasdir/JURECA/build/lib/scrip "
  importFlagsOAS+="-I$rootdir/run/JURECADC_eCLM-ParFlow/OASIS3-MCT/include "

  # CLM include dirs
  importFlagsCLM+="-I$clmdir/build/ "
  importFlagsCLM+="-I$rootdir/bld/JURECADC_eCLM-ParFlow/CLM3_5/bld/ "

  # COSMO include dirs
  importFlagsCOS+="-I$cosdir/obj "

  # ParFlow include dirs
  importFlagsPFL+="-I$pfldir/pfsimulator/parflow_lib "
  importFlagsPFL+="-I$pfldir/pfsimulator/amps/oas3 "
  importFlagsPFL+="-I$pfldir/pfsimulator/amps/common "
  importFlagsPFL+="-I$rootdir/bld/JURECADC_eCLM-ParFlow/ParFlow/src/ParFlow-build/include/ "
  importFlagsPFL+="-I$pfldir/build/include "
  if [[ $processor == "GPU" ]]; then
    importFlagsPFL+="-I$pfldir/rmm/include/rmm "
  fi

  # DA include dirs
  importFlagsDA+="-I$dadir/interface/model/common "
  if [[ $withPFL == "true" ]] ; then
    importFlagsDA+="-I$dadir/interface/model/parflow "
  fi

  # Oasis libraries
  libsOAS+="-lpsmile.MPI1 "
  libsOAS+="-lmct "
  libsOAS+="-lmpeu "
  libsOAS+="-lscrip "

  # CLM libraries
  libsCLM+="-lclm "

  # COSMO libraries
  libsCOS+="-lcosmo "
  libsCOS+="-L$gribPath/lib/ "
  libsCOS+="-leccodes_f90 "
  libsCOS+="-leccodes "

  # ParFlow library paths and libraries
  libsPFL+="-lpfsimulator "
  libsPFL+="-lamps "
  libsPFL+="-lpfkinsol "
  libsPFL+="-lgfortran "
  libsPFL+="-lcjson "
  if [[ $processor == "GPU" ]]; then
    libsPFL+="-lstdc++ "
    libsPFL+="-lcudart "
    libsPFL+="-lrmm "
    libsPFL+="-lnvToolsExt "
  fi
  libsPFL+="-L$hyprePath/lib -lHYPRE "
  libsPFL+="-L$siloPath/lib -lsilo "

  if [[ $withOAS == "false" && $withPFL == "true" ]] ; then
     importFlags+=$importFlagsPFL
     importFlags+=$importFlagsDA
     cppdefs+=" ${pf}-DPARFLOW_STAND_ALONE "
     libs+=$libsPFL
     obj+=' $(OBJPF) '
  fi

  if [[ $withOAS == "false" && $withCLM == "true" ]] ; then
    importFlags+=$importFlagsCLM
    importFlags+=$importFlagsDA
    cppdefs+=" ${pf}-DCLMSA "
    libs+=$libsCLM
    obj+=' $(OBJCLM) print_update_clm.o'
    
    # if [[ ${mList[1]} == clm5_0 ]] ; then
    #  importFlags+=$importFlagsDA
    #  importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/include "
    #  importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/c1a1l1i1o1r1g1w1e1/include "
    #  importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/include "
    #  importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/clm/obj "
    #  importFlags+=" -I$clmdir/build/atm/obj "
    #  importFlags+=" -I$clmdir/build/ice/obj "
    #  importFlags+=" -I$clmdir/build/ocn/obj "
    #  importFlags+=" -I$clmdir/build/glc/obj "
    #  importFlags+=" -I$clmdir/build/rof/obj "
    #  importFlags+=" -I$clmdir/build/wav/obj "
    #  importFlags+=" -I$clmdir/build/esp/obj "
    #  importFlags+=" -I$clmdir/build/cpl/obj "
    #  importFlags+=" -I$clmdir/build/lib/include "
    #  importFlags+=" -I$clmdir/build/ "
    #  cppdefs+=" ${pf}-DCLMSA ${pf}-DCLMFIVE "
    #  libs+=" -L$clmdir/build/lib/ -lcpl "
    #  libs+=" -L$clmdir/build/lib/ -latm -lice "
    #  libs+=" -L$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/lib/ -lclm "
    #  libs+=" -L$clmdir/build/lib/ -locn -lrof -lglc -lwav -lesp "
    #  libs+=" -L$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/c1a1l1i1o1r1g1w1e1/lib -lcsm_share "
    #  libs+=" -L$clmdir/build/intel/mpi/nodebug/nothreads/lib -lpio -lgptl -lmct -lmpeu  "
    #  libs+=" -lpnetcdf  -mkl -lnetcdff -lnetcdf "
    #  obj+=' $(OBJCLM5)'
    # fi
    # if [[ ${mList[1]} == eclm ]] ; then
    #  print "Needs to be updated with eCLM coupling configuration, but have to have something here otherwise compilation complains about the if / fi construct "
    #  #importFlags+=$importFlagsDA
    #  # importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/include "
    #  # importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/c1a1l1i1o1r1g1w1e1/include "
    #  # importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/include "
    #  # importFlags+=" -I$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/clm/obj "
    #  # importFlags+=" -I$clmdir/build/atm/obj "
    #  # importFlags+=" -I$clmdir/build/ice/obj "
    #  # importFlags+=" -I$clmdir/build/ocn/obj "
    #  # importFlags+=" -I$clmdir/build/glc/obj "
    #  # importFlags+=" -I$clmdir/build/rof/obj "
    #  # importFlags+=" -I$clmdir/build/wav/obj "
    #  # importFlags+=" -I$clmdir/build/esp/obj "
    #  # importFlags+=" -I$clmdir/build/cpl/obj "
    #  # importFlags+=" -I$clmdir/build/lib/include "
    #  # importFlags+=" -I$clmdir/build/ "
    #  # cppdefs+=" ${pf} -DCLMFIVE"
    #  # libs+=" -L$clmdir/build/lib/ -lcpl "
    #  # libs+=" -L$clmdir/build/lib/ -latm -lice "
    #  # libs+=" -L$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/lib/ -lclm "
    #  # libs+=" -L$clmdir/build/lib/ -locn -lrof -lglc -lwav -lesp "
    #  # libs+=" -L$clmdir/build/intel/mpi/nodebug/nothreads/mct/noesmf/c1a1l1i1o1r1g1w1e1/lib -lcsm_share "
    #  # libs+=" -L$clmdir/build/intel/mpi/nodebug/nothreads/lib -lpio -lgptl -lmct -lmpeu  "
    #  # libs+=" -lpnetcdf  -mkl -lnetcdff -lnetcdf "
    #  # obj+=' $(OBJCLM5)'
    # fi
  fi

  if [[ $withCLM == "true" && $withCOS == "true" && $withPFL == "false" ]] ; then

  #   if [[ ${mList[1]} == clm5_0 ]] ; then
  #     print "Not yet implemented combination of pdaf and models (clm5_0)"
  #     exit 1
  #   fi
  #   if [[ ${mList[1]} == eclm ]] ; then
  #     print "Not yet implemented combination of pdaf and models (eclm)"
  #     exit 1
  #   fi

     importFlags+=$importFlagsCLM
     importFlags+=$importFlagsOAS
     importFlags+=$importFlagsCOS
     importFlags+=$importFlagsDA
     cppdefs+=" ${pf}-Duse_comm_da ${pf}-DCOUP_OAS_COS ${pf}-DGRIBDWD ${pf}-DNETCDF ${pf}-DHYMACS ${pf}-DMAXPATCH_PFT=1 "
     if [[ $cplscheme == "true" ]] ; then ; cppdefs+=" ${pf}-DCPL_SCHEME_F " ; fi
     if [[ $readCLM == "true" ]] ; then ; cppdefs+=" ${pf}-DREADCLM " ; fi
     libs+=$libsCLM
     libs+=$libsCOS
     libs+=$libsOAS
     obj+=' $(OBJCLM) $(OBJCOSMO) '
  fi

  if [[ $withCLM == "true" && $withCOS == "false" && $withPFL == "true" ]] ; then
    
    # if [[ ${mList[1]} == clm5_0 ]] ; then
    #   print "Not yet implemented combination of pdaf and models (clm5_0)"
    #   exit 1
    # fi
    # if [[ ${mList[1]} == eclm ]] ; then
    #   print "Not yet implemented combination of pdaf and models (eclm)"
    #   exit 1
    # fi

     importFlags+=$importFlagsCLM
     importFlags+=$importFlagsOAS
     importFlags+=$importFlagsPFL
     importFlags+=$importFlagsDA
     cppdefs+=" ${pf}-Duse_comm_da ${pf}-DCOUP_OAS_PFL ${pf}-DMAXPATCH_PFT=1 "
     cppdefs+=" ${pf}-DOBS_ONLY_PARFLOW " # Remove for observations from both ParFlow + CLM
     if [[ $readCLM == "true" ]] ; then ; cppdefs+=" ${pf}-DREADCLM " ; fi
     if [[ $freeDrain == "true" ]] ; then ; cppdefs+=" ${pf}-DFREEDRAINAGE " ; fi
     libs+=$libsCLM
     libs+=$libsOAS
     libs+=$libsPFL
     obj+=' $(OBJCLM) $(OBJPF) '
  fi
  if [[ $withCLM == "true" && $withCOS == "true" && $withPFL == "true" ]] ; then

    # if [[ ${mList[1]} == clm5_0 ]] ; then
    #   print "Not yet implemented combination of pdaf and models (clm5_0)"
    #   exit 1
    # fi
    # if [[ ${mList[1]} == eclm ]] ; then
    #   print "Not yet implemented combination of pdaf and models (eclm)"
    #   exit 1
    # fi

     importFlags+=$importFlagsCLM
     importFlags+=$importFlagsOAS
     importFlags+=$importFlagsPFL
     importFlags+=$importFlagsCOS
     importFlags+=$importFlagsDA
     cppdefs+=" ${pf}-Duse_comm_da ${pf}-DCOUP_OAS_COS ${pf}-DGRIBDWD ${pf}-DNETCDF ${pf}-DHYMACS ${pf}-DMAXPATCH_PFT=1 ${pf}-DCOUP_OAS_PFL "
     if [[ $cplscheme == "true" ]] ; then ; cppdefs+=" ${pf}-DCPL_SCHEME_F " ; fi
     if [[ $readCLM == "true" ]] ; then ; cppdefs+=" ${pf}-DREADCLM " ; fi
     if [[ $freeDrain == "true" ]] ; then ; cppdefs+=" ${pf}-DFREEDRAINAGE " ; fi
     libs+=$libsCLM
     libs+=$libsOAS
     libs+=$libsCOS
     libs+=$libsPFL
     obj+=' $(OBJCLM) $(OBJCOSMO) $(OBJPF) '
  fi

#PDAF interface part
  file1=$dadir/interface/model/Makefile
  file2=$dadir/interface/framework/Makefile
  print "   cp pdaf interface Makefiles to $dadir"
    cp $rootdir/bldsva/intf_DA/pdaf/model/Makefile  $file1 >> $log_file 2>> $err_file
    cp $rootdir/bldsva/intf_DA/pdaf/framework/Makefile  $file2 >> $log_file 2>> $err_file

  print "   sed bindir to Makefiles"
    sed -i "s,__bindir__,$bindir," $file1 $file2 >> $log_file 2>> $err_file
  print "   sed comp flags to Makefiles"
    sed -i "s,__fflags__,-cpp -I$dadir/interface/model -I$ncdfPath/include $importFlags," $file1 $file2 >> $log_file 2>> $err_file
    sed -i "s,__ccflags__,-I$dadir/interface/model -I$ncdfPath/include $importFlags," $file1 $file2 >> $log_file 2>> $err_file
  print "   sed preproc flags to Makefiles"
    sed -i "s,__cpp_defs__,$cppdefs," $file1 $file2 >> $log_file 2>> $err_file
    sed -i "s,__fcpp_defs__,$cppdefs," $file1 $file2 >> $log_file 2>> $err_file
  print "   sed libs to Makefiles"
    sed -i "s,__libs__,$libs," $file2 >> $log_file 2>> $err_file
  print "   sed obj to Makefiles"
    sed -i "s,__obj__,$obj," $file1 >> $log_file 2>> $err_file
  print "   sed -D prefix to Makefiles"
    sed -i "s,__pf__,$pf," $file1 $file2 >> $log_file 2>> $err_file
  print "   sed clm directory to Makefiles"
    sed -i "s,__clmdir__,clm3_5," $file1 $file2 >> $log_file 2>> $err_file
  print "   sed cosmo directory to Makefiles"
    sed -i "s,__cosdir__,cosmo5_1," $file1 $file2 >> $log_file 2>> $err_file
  print "   sed parflow directory to Makefiles"
    sed -i "s,__pfldir__,parflow," $file1 $file2 >> $log_file 2>> $err_file

  print "   cd to $dadir/interface/model"
    cd $dadir/interface/model >> $log_file 2>> $err_file
  print "   make clean model"
    make clean >> $log_file 2>> $err_file
  print "   cd to $dadir/src/interface/framework"
    cd $dadir/interface/framework >> $log_file 2>> $err_file
  print "   make clean framework"
    make clean >> $log_file 2>> $err_file


  print "   cd to $dadir/src"
    cd $dadir/src >> $log_file 2>> $err_file
  print "   make pdaf"
    make >> $log_file 2>> $err_file

  print "   cd to $dadir/interface/model"
    cd $dadir/interface/model >> $log_file 2>> $err_file
  print "   make pdaf model"
    make >> $log_file 2>> $err_file

  print "   cd to $dadir/interface/framework"
    cd $dadir/interface/framework >> $log_file 2>> $err_file
  print "   make pdaf framework"
    make >> $log_file 2>> $err_file

  mv -f $err_file $bindir
  mv -f $log_file $bindir
  mv -f $stdout_file $bindir

  print ${cgreen}"build script finished sucessfully"${cnormal}
  print "Rootdir: ${rootdir}"
  print "Bindir: ${bindir}"


