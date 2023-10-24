#! /bin/ksh
#

substitutions_da(){
route "${cyellow}>> substitutions_da${cnormal}"

  comment "   mkdir  $dadir/interface"
    mkdir -p $dadir/interface  >> $log_file 2>> $err_file
  check

  comment "   cp pdaf interface model to $dadir/interface"
    patch $rootdir/bldsva/intf_DA/pdaf/model $dadir/interface
  check

  comment "   cp pdaf interface framework to $dadir/interface"
    patch $rootdir/bldsva/intf_DA/pdaf/framework $dadir/interface
  check

  comment "   mkdir $dadir/lib"
    mkdir -p $dadir/lib >> $log_file 2>> $err_file
  check

route "${cyellow}<< substitutions_da${cnormal}"
}

configure_da(){
route "${cyellow}>> configure_da${cnormal}"

#PDAF part configuration variables
  export PDAF_DIR=$dadir
  if [[ $compiler == "Gnu" ]]; then
    export PDAF_ARCH=linux_gfortran_openmpi
  else
    export PDAF_ARCH=linux_ifort
  fi

  if [[ $profiling == "scalasca" ]]; then
    comFC="scorep-mpif90"
    comCC="scorep-mpicc"
  else
    comFC="${mpiPath}/bin/mpif90"
    comCC="${mpiPath}/bin/mpicc"
  fi

#    libs_src=" -L$lapackPath -L${mpiPath}/lib64"
#    libs_src=" -L$lapackPath -lopenblas -L${mpiPath}/lib64"
#    libs_src=" $lapackPath/mkl/lib/intel64/libmkl_intel_lp64.a $lapackPath/mkl/lib/intel64/libmkl_intel_thread.a $lapackPath/mkl/lib/intel64/libmkl_core.a -L${mpiPath}/lib64"
#    libs_src=" -L$lapackPath -llapack -lblas -L${mpiPath}/lib64"
#    libs_src=" -L$lapackPath/mkl/lib/intel64 -Wl,--no-as-needed -lmkl_scalapack_ilp64 -lmkl_cdft_core -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_ilp64 -lm -ldl -L${mpiPath}/lib64 -lirc -lintlc"
  if [[ $compiler == "Gnu" ]]; then
    libs_src=" -ldl $lapackPath/mkl/latest/lib/intel64/libmkl_gf_lp64.a $lapackPath/mkl/latest/lib/intel64/libmkl_gnu_thread.a $lapackPath/mkl/latest/lib/intel64/libmkl_core.a -L${mpiPath}/lib64"
  else
    libs_src=" $lapackPath/mkl/latest/lib/intel64/libmkl_intel_lp64.a $lapackPath/mkl/latest/lib/intel64/libmkl_intel_thread.a $lapackPath/mkl/latest/lib/intel64/libmkl_core.a -L${mpiPath}/lib64"
  fi

#PDAF arch part
  file=$dadir/make.arch/${PDAF_ARCH}.h

  comment "   cp pdaf config to $dadir"
    cp $rootdir/bldsva/intf_DA/pdaf/arch/config/${PDAF_ARCH}.h $file >> $log_file 2>> $err_file
  check

  comment "   sed comFC dir to $file"
  sed -i "s@__comFC__@${comFC}@" $file >> $log_file 2>> $err_file
  check

  comment "   sed comCC dir to $file"
  sed -i "s@__comCC__@${comCC}@" $file >> $log_file 2>> $err_file
  check

  comment "   sed MPI dir to $file"
    sed -i "s@__MPI_INC__@-I${mpiPath}/include@" $file >> $log_file 2>> $err_file
  check

  comment "   sed LIBS to $file"
    sed -i "s@__LIBS__@${libs_src}@" $file >> $log_file 2>> $err_file
  check

  comment "   sed optimizations to $file"
    sed -i "s@__OPT__@${optComp}@" $file >> $log_file 2>> $err_file
  check

  comment "   cd to $dadir/src"
    cd $dadir/src >> $log_file 2>> $err_file
  check
  comment "   make clean pdaf"
    make clean >> $log_file 2>> $err_file
  check

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
    #  comment "Needs to be updated with eCLM coupling configuration, but have to have something here otherwise compilation complains about the if / fi construct "
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
  #     comment "Not yet implemented combination of pdaf and models (clm5_0)"
  #     exit 1
  #   fi
  #   if [[ ${mList[1]} == eclm ]] ; then
  #     comment "Not yet implemented combination of pdaf and models (eclm)"
  #     exit 1
  #   fi

  #    importFlags+=$importFlagsCLM
  #    importFlags+=$importFlagsOAS
  #    importFlags+=$importFlagsCOS
  #    importFlags+=$importFlagsDA
  #    cppdefs+=" ${pf}-Duse_comm_da ${pf}-DCOUP_OAS_COS ${pf}-DGRIBDWD ${pf}-DNETCDF ${pf}-DHYMACS ${pf}-DMAXPATCH_PFT=1 "
  #    if [[ $cplscheme == "true" ]] ; then ; cppdefs+=" ${pf}-DCPL_SCHEME_F " ; fi
  #    if [[ $readCLM == "true" ]] ; then ; cppdefs+=" ${pf}-DREADCLM " ; fi
  #    libs+=$libsCLM
  #    libs+=$libsCOS
  #    libs+=$libsOAS
  #    obj+=' $(OBJCLM) $(OBJCOSMO) '
  # fi

  if [[ $withCLM == "true" && $withCOS == "false" && $withPFL == "true" ]] ; then
    
    # if [[ ${mList[1]} == clm5_0 ]] ; then
    #   comment "Not yet implemented combination of pdaf and models (clm5_0)"
    #   exit 1
    # fi
    # if [[ ${mList[1]} == eclm ]] ; then
    #   comment "Not yet implemented combination of pdaf and models (eclm)"
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
    #   comment "Not yet implemented combination of pdaf and models (clm5_0)"
    #   exit 1
    # fi
    # if [[ ${mList[1]} == eclm ]] ; then
    #   comment "Not yet implemented combination of pdaf and models (eclm)"
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
  comment "   cp pdaf interface Makefiles to $dadir"
    cp $rootdir/bldsva/intf_DA/pdaf/model/Makefile  $file1 >> $log_file 2>> $err_file
  check
    cp $rootdir/bldsva/intf_DA/pdaf/framework/Makefile  $file2 >> $log_file 2>> $err_file
  check

  comment "   sed bindir to Makefiles"
    sed -i "s,__bindir__,$bindir," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed comp flags to Makefiles"
    sed -i "s,__fflags__,-cpp -I$dadir/interface/model -I$ncdfPath/include $importFlags," $file1 $file2 >> $log_file 2>> $err_file
  check
    sed -i "s,__ccflags__,-I$dadir/interface/model -I$ncdfPath/include $importFlags," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed preproc flags to Makefiles"
    sed -i "s,__cpp_defs__,$cppdefs," $file1 $file2 >> $log_file 2>> $err_file
  check
    sed -i "s,__fcpp_defs__,$cppdefs," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed libs to Makefiles"
    sed -i "s,__libs__,$libs," $file2 >> $log_file 2>> $err_file
  check
  comment "   sed obj to Makefiles"
    sed -i "s,__obj__,$obj," $file1 >> $log_file 2>> $err_file
  check
  comment "   sed -D prefix to Makefiles"
    sed -i "s,__pf__,$pf," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed clm directory to Makefiles"
    sed -i "s,__clmdir__,clm3_5," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed cosmo directory to Makefiles"
    sed -i "s,__cosdir__,cosmo5_1," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed parflow directory to Makefiles"
    sed -i "s,__pfldir__,parflow," $file1 $file2 >> $log_file 2>> $err_file
  check

  comment "   cd to $dadir/interface/model"
    cd $dadir/interface/model >> $log_file 2>> $err_file
  check
  comment "   make clean model"
    make clean >> $log_file 2>> $err_file
  check
  comment "   cd to $dadir/src/interface/framework"
    cd $dadir/interface/framework >> $log_file 2>> $err_file
  check
  comment "   make clean framework"
    make clean >> $log_file 2>> $err_file
  check

route "${cyellow}<< configure_da${cnormal}"
}

make_da(){
route "${cyellow}>> make_da${cnormal}"

  comment "   cd to $dadir/src"
    cd $dadir/src >> $log_file 2>> $err_file
  check
  comment "   make pdaf"
    make >> $log_file 2>> $err_file
  check

  comment "   cd to $dadir/interface/model"
    cd $dadir/interface/model >> $log_file 2>> $err_file
  check
  comment "   make pdaf model"
    make >> $log_file 2>> $err_file
  check

  comment "   cd to $dadir/interface/framework"
    cd $dadir/interface/framework >> $log_file 2>> $err_file
  check
  comment "   make pdaf framework"
    make >> $log_file 2>> $err_file
  check

route "${cyellow}<< make_da${cnormal}"
}
