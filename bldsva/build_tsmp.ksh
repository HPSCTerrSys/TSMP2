#! /bin/ksh

check(){
  if [[ $? == 0  ]] then
     print "    ... ${cgreen}OK!${cnormal}" | tee -a $stdout_file
  else
     print "    ... ${cred}error!!! - aborting...${cnormal}"  | tee -a $stdout_file
     print "See $log_file and $err_file" | tee -a $stdout_file
     exit 1
   fi
}

terminate(){
  print ""
  print "Terminating $call. No changes were made...${cnormal}"
  rm -f $err_file
  rm -f $log_file
  rm -f $stdout_file
  exit 0
}

patch(){
  print -n "${ccyan}\npatching $1 into $2 ${cnormal}" | tee -a $stdout_file
  cp -r -v $1 $2 >> $patchlog_file 2>> $err_file
}

comment(){
  print -n "$1" | tee -a $stdout_file
}

route(){
  print "$1" | tee -a $stdout_file
}

warning(){
  print "Warning!!! - $wmessage"
  print "This could lead to errors or wrong behaviour. Would you like to continue anyway?"
  PS3="Your selection(1-2)?"
  select ret in "yes" "no, exit"
  do
    if [[ -n $ret ]]; then
       case $ret in
          "yes") break ;;
          "no, exit") terminate ;;
       esac
       break
    fi
  done
}


  

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

  #automatically determine root dir
  cpwd=`pwd`
  if [[ "$0" == '/'*  ]] ; then
    #absolute path
    estdir=`echo "$0" | sed 's@/bldsva/build_tsmp.ksh@@'` #remove bldsva/configure machine to get rootpath
    call=$0
  else
    #relative path
    call=`echo $0 | sed 's@^\.@@'`                    #clean call from leading dot
    call=`echo $call | sed 's@^/@@'`                  #clean call from leading /
    call=`echo "/$call" | sed 's@^/\./@/\.\./@'`      #if script is called without leading ./ replace /./ by /../
    curr=`echo $cpwd | sed 's@^/@@'`                   #current directory without leading /   
    call=`echo $call | sed "s@$curr@@"`               #remove current directory from call if absolute path was called
    estdir=`echo "/$curr$call" | sed 's@/bldsva/build_tsmp.ksh@@'` #remove bldsva/configure machine to get rootpath
    call="$estdir/bldsva$call"
  fi
  rootdir=$estdir

  # Log files
  log_file=$cpwd/log_all_${date}.txt
  err_file=$cpwd/err_all_${date}.txt
  stdout_file=$cpwd/stdout_all_${date}.txt
  patchlog_file=$cpwd/patch_all_${date}.txt
  rm -f $log_file $err_file $stdout_file $patchlog_file

  # Component model configuration
  withOAS="false"
  withCOS="false"
  withICON="false"
  withPFL="true"
  withCLM="true"
  withOASMCT="true"
  withPCLM="false"
#DA
  withDA="true"
  withPDAF="true"

  comment "   init lmod functionality"
  # "jurecadc", "juwels"
  . /p/software/jurecadc/lmod/lmod/init/ksh >> $log_file 2>> $err_file
  check

  comment "   source and load Modules $rootdir"
  . $rootdir/env/jsc.2023_Intel.ksh >> $log_file 2>> $err_file
  check


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

  bindir=$rootdir/bin/
  dadir=$rootdir/pdaf_changed/

  # libs directory
  mkdir -p $bindir/libs >> $log_file 2>> $err_file

  # oasis3-mct
  if [[ $withOAS == "true" ]] ; then
    oasdir=$rootdir/run/JURECADC_eCLM-ParFlow/OASIS3-MCT/
    libpsmile="$oasdir/lib/libpsmile.MPI1.a $oasdir/lib/libmct.a $oasdir/lib/libmpeu.a $oasdir/lib/libscrip.a"

    comment "    cp oas libs to $bindir/libs"
    cp $libpsmile $bindir/libs >> $log_file 2>> $err_file
    check
  fi

  # clm
  if [[ $withCLM == "true" ]] ; then
    clmdir=$rootdir/bld/JURECADC_eCLM-ParFlow/CLM3_5

    comment "    cd to clm build dir"
      cd $clmdir/bld >> $log_file 2>> $err_file
    check
    comment "    ar clm libs"
      ar rc libclm.a *.o >> $log_file 2>> $err_file
    check
    comment "    cp libs to $bindir/libs"
      cp $clmdir/bld/libclm.a $bindir/libs >> $log_file 2>> $err_file
    check
  fi

  # parflow
  if [[ $withPFL == "true" ]] ; then
    pfldir=$rootdir/run/JURECADC_eCLM-ParFlow

    comment "    cp libs to $bindir/libs"
      cp $pfldir/lib/* $bindir/libs >> $log_file 2>> $err_file
    check
    if [[ $processor == "GPU" ]]; then
      comment "    GPU: cp rmm libs to $bindir/libs"
        cp $pfldir/rmm/lib/* $bindir/libs >> $log_file 2>> $err_file
      check
    fi

    # Change pfldir to bld
    pfldir=$rootdir/parflow

  fi

#compile DA
  comment "  source da interface script"
    . ${rootdir}/bldsva/intf_DA/pdaf/arch/build_interface_pdaf.ksh >> $log_file 2>> $err_file
  check
  comment "  clear da dir: $dadir"
      rm -rf $dadir >> $log_file 2>> $err_file
  check
  comment "  backup ${rootdir}/pdaf to $dadir"
      cp -rf ${rootdir}/pdaf $dadir >> $log_file 2>> $err_file
  check

  substitutions_da
  configure_da 
  make_da

  mv -f $err_file $bindir
  mv -f $log_file $bindir
  mv -f $stdout_file $bindir
  rm -f $patchlog_file

  print ${cgreen}"build script finished sucessfully"${cnormal}
  print "Rootdir: ${rootdir}"
  print "Bindir: ${bindir}"


