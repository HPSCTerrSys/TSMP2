#! /bin/ksh

############################ 
#PDAF interface methods
############################


c_substitutions_pdaf(){
route "${cyellow}>>> c_substitutions_pdaf${cnormal}"

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

route "${cyellow}<<< c_substitutions_pdaf${cnormal}"
}

c_configure_pdaf_arch(){
route "${cyellow}>>> c_configure_pdaf_arch${cnormal}"

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

route "${cyellow}<<< c_configure_pdaf_arch${cnormal}"
}

c_configure_pdaf(){
route "${cyellow}>>> c_configure_pdaf${cnormal}"

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
    sed -i "s,__clmdir__,${mList[1]}," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed cosmo directory to Makefiles"
    sed -i "s,__cosdir__,${mList[2]}," $file1 $file2 >> $log_file 2>> $err_file
  check
  comment "   sed parflow directory to Makefiles"
    sed -i "s,__pfldir__,${mList[3]}," $file1 $file2 >> $log_file 2>> $err_file
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


route "${cyellow}<<< c_configure_pdaf${cnormal}"
}

c_make_pdaf(){
route "${cyellow}>>> c_make_pdaf${cnormal}"

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

route "${cyellow}<<< c_make_pdaf${cnormal}"
}



