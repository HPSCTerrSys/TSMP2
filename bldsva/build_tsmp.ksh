#! /bin/ksh


setSelection(){

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
}

#DA
compileDA(){
route "${cyellow}> c_compileDA${cnormal}"
  comment "  source da interface script"
    . ${rootdir}/bldsva/intf_DA/${mList[4]}/arch/build_interface_${mList[4]}.ksh >> $log_file 2>> $err_file
  check
  comment "  clear da dir: $dadir"
      rm -rf $dadir >> $log_file 2>> $err_file
  check
  comment "  backup ${rootdir}/${mList[4]} to $dadir"
      cp -rf ${rootdir}/${mList[4]} $dadir >> $log_file 2>> $err_file
  check

      substitutions_da
      configure_da 
      make_da
route "${cyellow}< c_compileDA${cnormal}"
}


runCompilation(){

  bindir=$rootdir/bin/${platform}_${combination}
  dadir=$rootdir/${mList[4]}_${platform}_${combination}

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

#DA
  if [[ $withDA == "true" ]] ; then ; compileDA ; fi

}


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


getRoot(){
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
  
}


#######################################
#		Main
#######################################

  cyellow=$(tput setaf 3)
  cnormal=$(tput sgr0)   #9
  cred=$(tput setaf 1)
  cgreen=$(tput setaf 2)
  cmagenta=$(tput setaf 5)
  ccyan=$(tput setaf 6)

  typeset -A options
  typeset -A def_options

  date=`date +%d%m%y-%H%M%S`
  getRoot 

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

  comment "  source machine build interface for $platform"
    . ${rootdir}/bldsva/machines/config_${platform}.ksh >> $log_file 2>> $err_file
  check

  getMachineDefaults
  setSelection

  runCompilation

  mv -f $err_file $bindir
  mv -f $log_file $bindir
  mv -f $stdout_file $bindir
  rm -f $patchlog_file

  print ${cgreen}"build script finished sucessfully"${cnormal}
  print "Rootdir: ${rootdir}"
  print "Bindir: ${bindir}"


