#! /bin/ksh

######################################################
##################### Defaults #######################
######################################################

getDefaults(){
  def_platform="" 
  def_version="" 
  def_combination=""
  def_rootdir="$estdir" #This should be correct - change with caution

  def_bindir=""				#Will be set to $rootdir/bin/$platform_$version_$combination if empty
  def_oasdir=""				#Will be set to $rootdir/XXX_$platform_$combination if empty
  def_cosdir=""
  def_icondir=""
  def_clmdir=""
  def_pfldir=""
#DA
  def_dadir=""
  # pathes will be set to tested platform defaults if empty
  def_mpiPath=""
  def_ncdfPath=""
  def_grib1path=""
  def_gribPath=""
  def_tclPath=""
  def_hyprePath=""
  def_siloPath=""
  def_pncdfPath=""
  def_lapackPath=""

  def_cplscheme="true"
  def_readCLM="false"
  def_maxpft="1" # (CLM default is 4)
  def_freeDrain="false"

  #compiler optimization
  def_optComp=""   # will be set to platform defaults if empty

  #compiler options, CPS remove hardwiring of compilers
  def_compiler="Intel" # set Intel default if not explicitly set
  def_processor="CPU"

  #profiling
  def_profiling="no"

  # fresh build clean in new folder
  # build=build clean
  # make=(resume) make - no configure
  # configure= only configure - no make
  # skip=do nothing
  def_options+=(["oas"]="fresh")
  def_options+=(["clm"]="fresh")
  def_options+=(["pfl"]="fresh")
  def_options+=(["cos"]="fresh")
  def_options+=(["icon"]="fresh")
#DA
  def_options+=(["da"]="fresh")
}

#####################################################
# USERS SHOULD NOT EDIT BELOW THIS LINE
#####################################################

setDefaults(){
  #load the default values
  platform=$def_platform
  if [[ $platform == "" ]] then ; platform="JUWELS" ; fi #We need a hard default here
  version=$def_combination
  if [[ $version == "" ]] then ; version="" ; fi #We need a hard default here
  rootdir=$def_rootdir
  bindir=$def_bindir
  optComp=$def_optComp
  compiler=$def_compiler
  processor=$def_processor
  profiling=$def_profiling
  oasdir=$def_oasdir
  clmdir=$def_clmdir
  cosdir=$def_cosdir
  icondir=$def_icondir
  pfldir=$def_pfldir
#DA
  dadir=$def_dadir
  mpiPath=$def_mpiPath
  ncdfPath=$def_ncdfPath
  lapackPath=$def_lapackPath
  pncdfPath=$def_pncdfPath
  grib1Path=$def_grib1Path
  gribPath=$def_gribPath
  tclPath=$def_tclPath
  hyprePath=$def_hyprePath
  siloPath=$def_siloPath
  combination=$def_combination

  freeDrain=$def_freeDrain
  readCLM=$def_readCLM
  maxpft=${def_maxpft}
  cplscheme=$def_cplscheme

  log_file=$cpwd/log_all_${date}.txt
  err_file=$cpwd/err_all_${date}.txt
  stdout_file=$cpwd/stdout_all_${date}.txt
  patchlog_file=$cpwd/patch_all_${date}.txt
  rm -f $log_file $err_file $stdout_file $patchlog_file

  options+=(["oas"]=${def_options["oas"]})
  options+=(["cos"]=${def_options["cos"]})
  options+=(["icon"]=${def_options["icon"]})
  options+=(["clm"]=${def_options["clm"]})
  options+=(["pfl"]=${def_options["pfl"]})
#Da
  options+=(["da"]=${def_options["da"]})

  #profiling
  profComp=""
  profRun=""
  profVar=""

}


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

setCombination(){
   if echo "$combination" | grep -q 'pdaf'; then

     if echo "$combination" | grep -q 'clm5'; then

       mListgen="clm5-cos5-pfl-pdaf"

     else

       if echo "$combination" | grep -q 'cos4'; then
	 mListgen="clm3-cos4-pfl-pdaf"
       else
         mListgen="clm3-cos5-pfl-pdaf"
       fi

     fi

   elif echo "$combination" | grep -q 'clm5'; then
	mListgen="clm5-cos5-pfl"
   elif echo "$combination" | grep -q 'clm4' && echo "$combination" | grep -q 'cos4'; then
	mListgen="clm4-cos4-pfl"
   elif echo "$combination" | grep -q 'clm4'; then
	mListgen="clm4-cos5-pfl"
   
   elif echo "$combination" | grep -q 'icon21'; then
	mListgen="clm3-icon21-pfl"
   elif echo "$combination" | grep -q 'icon26'; then
	mListgen="clm3-icon26-pfl"
	   
   elif echo "$combination" | grep -q 'eclm'; then
	mListgen="eclm"
   elif echo "$combination" | grep -q 'eclm-mct'; then
	mListgen="eclm-mct"

   else 
	if echo "$combination" | grep -q 'cos4'; then
		mListgen="clm3-cos4-pfl"
	else
		mListgen="clm3-cos5-pfl"
	fi
  fi 

  version=$mListgen
  set -A mList ${modelVersion[$mListgen]}
  if [[ $oasdir == "" ]] then ;  oasdir=$rootdir/${mList[0]}_${platform}_${combination} ; fi
  if [[ $cosdir == "" ]] then ;  cosdir=$rootdir/${mList[2]}_${platform}_${combination} ; fi
  if [[ $icondir == "" ]] then ; icondir=$rootdir/${mList[2]}_${platform}_${combination} ; fi
  if [[ $clmdir == "" ]] then ;  clmdir=$rootdir/${mList[1]}_${platform}_${combination} ; fi
  if [[ $pfldir == "" ]] then ;  pfldir=$rootdir/${mList[3]}_${platform}_${combination} ; fi
#DA
  if [[ $dadir == "" ]] then ;  dadir=$rootdir/${mList[4]}_${platform}_${combination} ; fi  
  if [[ $bindir == "" ]] then ;  bindir=$rootdir/bin/${platform}_${combination} ;  fi 

  withOAS="false"
  withCOS="false"
  withICON="false"
  withPFL="false"
  withCLM="false"
  withOASMCT="false"
  withPCLM="false"
#DA
  withDA="false"
  withPDAF="false"


  case "$combination" in *clm*) withCLM="true" ;; esac
  case "$combination" in *cos*) withCOS="true" ;; esac
  case "$combination" in *icon*) withICON="true" ;; esac
  case "$combination" in *pfl*) withPFL="true" ;; esac
  if [[ $withCLM == "true" && ( $withCOS == "true" || $withICON == "true" || $withPFL == "true" )  ]]; then
    withOAS="true"
    withOASMCT="true"
  fi
#DA
  case "$combination" in *pdaf*) withDA="true" ; withPDAF="true" ;; esac
}

#DA
compileDA(){
route "${cyellow}> c_compileDA${cnormal}"
  comment "  source da interface script"
    . ${rootdir}/bldsva/intf_DA/${mList[4]}/arch/build_interface_${mList[4]}.ksh >> $log_file 2>> $err_file
  check
    if [[ ${options["da"]} == "skip" ]] ; then ; route "${cyellow}< c_compileDA${cnormal}" ;return  ;fi 
    if [[ ${options["da"]} == "fresh" ]] ; then 
  comment "  clear da dir: $dadir"
      rm -rf $dadir >> $log_file 2>> $err_file
  check
  comment "  backup ${rootdir}/${mList[4]} to $dadir"
      cp -rf ${rootdir}/${mList[4]} $dadir >> $log_file 2>> $err_file
  check
    fi  
    if [[ ${options["da"]} == "build" || ${options["da"]} == "fresh" ]] ; then
      substitutions_da
    fi  
    if [[ ${options["da"]} == "configure" || ${options["da"]} == "build" || ${options["da"]} == "fresh" ]] ; then
      configure_da 
    fi  

    if [[ ${options["da"]} == "make" || ${options["da"]} == "build" || ${options["da"]} == "fresh" ]] ; then
      make_da
    fi  
route "${cyellow}< c_compileDA${cnormal}"
}


runCompilation(){

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

hardSanityCheck(){

  if [[ "${platforms[${platform}]}" == ""  ]] then
      print "The selected platform '${platform}' is not available. run '$call --man' for help"
      terminate
  fi

}

deprecatedVersion(){
  if [[ "${version}" != ""  ]] then
      print "The use of the internal version with -v is deprecated. Please provide your desired combination with -c including version numbers (clm3-cos5-pfl). "
      terminate
  fi
}

softSanityCheck(){


  valid="false"
  case "${availability[${platform}]}" in *" ${version} "*) valid="true" ;; esac
  if [[ $valid != "true" ]] then; wmessage="This version is not supported on this machine" ; warning  ;fi

  valid="false"
  cstr="invalid"
  if [[ $withCLM == "true" &&  $withICON == "false" &&  $withCOS == "true" && $withPFL == "true"  ]]; then ;cstr=" clm-cos-pfl " ; fi
  if [[ $withCLM == "true" &&  $withICON == "true" &&  $withCOS == "false" && $withPFL == "true"  ]]; then ;cstr=" clm-icon-pfl " ; fi
  if [[ $withCLM == "true" &&  $withICON == "false" &&  $withCOS == "true" && $withPFL == "false"  ]]; then ;cstr=" clm-cos " ; fi
  if [[ $withCLM == "true" &&  $withICON == "true" &&  $withCOS == "false" && $withPFL == "false"  ]]; then ;cstr=" clm-icon " ; fi
  if [[ $withCLM == "true" &&  $withICON == "false" &&  $withCOS == "false" && $withPFL == "true"  ]]; then ;cstr=" clm-pfl " ; fi
  if [[ $withCLM == "true" &&  $withICON == "false" &&  $withCOS == "false" && $withPFL == "false"  ]]; then ;cstr=" clm " ; fi
  if [[ $withCLM == "false" &&  $withICON == "false" &&  $withCOS == "true" && $withPFL == "false"  ]]; then ;cstr=" cos " ; fi
  if [[ $withCLM == "false" &&  $withICON == "true" &&  $withCOS == "false" && $withPFL == "false"  ]]; then ;cstr=" icon " ; fi
  if [[ $withCLM == "false" &&  $withICON == "false" &&  $withCOS == "false" && $withPFL == "true"  ]]; then ;cstr=" pfl " ; fi
  case "${combinations[${version}]}" in *${cstr}*) valid="true" ;; esac
  if [[ $valid != "true" ]] then; wmessage="This combination is not supported in this version" ; warning  ;fi

  valid="false"
  case "${profilingImpl}" in *" ${profiling} "*) valid="true" ;; esac
  if [[ $valid != "true" ]] then; wmessage="This profiling tool is not supported on this machine" ; warning  ;fi

}



listAvailabilities(){
   
  print ${cyellow}"A list of all supported versions for a special platform."${cnormal}
  print ""
  for p in "${!platforms[@]}" ; do
    printf "%-20s #%s\n" "$p" "${platforms[$p]}"
    for a in ${availability[$p]} ; do
        print $'\t'"$a"
    done
  done
  print ""
  print ${cyellow}"A list of details for each version."${cnormal}	
  print ""
  for v in "${!versions[@]}" ; do
    printf "%-20s #%s\n" "$v" "${versions[$v]}"
    print ${cgreen}$'\t possible combinations:'${cnormal}
    print $'\t'${combinations[$v]}		
    print ${cgreen}$'\t componentmodel versions:'${cnormal}	
    for a in ${modelVersion[$v]} ; do
        print $'\t '"$a"
    done
  done

  exit 0
}

listTutorial(){
  print "1) The required component models need to be loaded in beforehand"
  print "2) The models must be named with their version name as specified in the supported_versions.ksh and in the intf-folder: for example cosmo4_21, parflow, clm3_5 or oasis3-mct in the root directory"
  print "2b) You can download oasis3-mct with: svn checkout http://oasis3mct.cerfacs.fr/svn/branches/OASIS3-MCT_2.0_branch/oasis3-mct"
  print "3) If not specified other, the component models will be copied to a working version with the name: MODEL_PLATFORM_COMBINATION"
  print "4) If a new version or platform is supported, edit the supported_versions.ksh and reflect all dependencies and constraints"
	
  exit 0
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
  getDefaults
  setDefaults

  #GetOpts definition
  USAGE=$'[-?\n@(#)$Id: TerrSysMP build script 1.0 - '
  USAGE+=$' date: 07.09.2015 $\n]'
  USAGE+="[-author?Fabian Gasper]"
  USAGE+="[+NAME?TerrSysMP build script]"
  USAGE+="[+DESCRIPTION?builds TSMP based on decisions for included modules]"
  USAGE+="[a:avail?Prints a listing of every machine with available versions. The script will exit afterwards.]"
  USAGE+="[t:tutorial?Prints a tutorial/description on how to add new versions and platforms to this script. The script will exit afterwards.]"
  USAGE+="[R:rootdir?Absolute path to TerrSysMP root directory.]:[path:='$def_rootdir']"
  USAGE+="[B:bindir?Absolute path to bin directory for the builded executables. bin/MACHINE_DATE will be taken if ''.]:[path:='$def_bindir']"
   
  USAGE+="[v:version?Deprecated. Please specify your desired combination with the -c option.]"
  USAGE+="[m:machine?Target Platform. Run option -a, --avail to get a listing.]:[machine:='$def_platform']"

  USAGE+="[p:profiling?Makes necessary changes to compile with a profiling tool if available.]:[profiling:='$def_profiling']"
  USAGE+="[o:optimization?Compiler optimisation flags.]:[optimization:='$def_optComp']"
  USAGE+="[O:compiler?Compiler option flags.]:[compiler:='$def_compiler']"
  USAGE+="[A:processor?Processor GPU or CPU.]:[processor:='$def_processor']"
  USAGE+="[c:combination? Combination of component models.]:[combination:='$def_combination']"
  USAGE+="[C:cplscheme? Couple-Scheme for CLM/COS coupling.]:[cplscheme:='$def_cplscheme']"
  USAGE+="[r:readclm? Flag to consistently read in CLM mask.]:[readclm:='$def_readCLM']"
  USAGE+="[f:maxpft? Flag to control maxpft per grid cell in CLM.]:[maxpft:='$def_maxpft']"
  USAGE+="[d:freedrain? Compiles ParFlow with free drainage feature.]:[freedrain:='$def_freeDrain']"

  USAGE+="[W:optoas?Build option for Oasis.]:[optoas:='${def_options["oas"]}']{"
  USAGE+=$(printf "[?%-12s #%s]" "fresh" "build from scratch in a new folder")
  USAGE+=$(printf "[?%-12s #%s]" "build" "build clean")
  USAGE+=$(printf "[?%-12s #%s]" "make" "only (resume) make and make install - no make clean and configure")
  USAGE+=$(printf "[?%-12s #%s]" "configure" "only make clean and configure - no make")
  USAGE+=$(printf "[?%-12s #%s]" "skip" "no build")
  USAGE+="}"
  USAGE+="[E:opticon?Build option for ICON.]:[opticon:='${def_options["icon"]}']"
  USAGE+="[Y:optcos?Build option for Cosmo.]:[optcos:='${def_options["cos"]}']"
  USAGE+="[X:optclm?Build option for CLM.]:[optclm:='${def_options["clm"]}']"
  USAGE+="[Z:optpfl?Build option for Parflow.]:[optpfl:='${def_options["pfl"]}']"
#DA
  USAGE+="[U:optda?Build option for Data Assimilation.]:[optda:='${def_options["da"]}']"  
  USAGE+="[u:dadir?Source directory for Data Assimilation. daV_MACHINE_VERSION_COMBINATION will be taken if ''.]:[dadir:='${def_dadir}']"   

  USAGE+="[e:icondir?Source directory for ICON. iconV_MACHINE_VERSION_COMBINATION will be taken if ''.]:[icondir:='${def_icondir}']"
  USAGE+="[w:oasdir?Source directory for Oasis3. oasisV_MACHINE_VERSION_COMBINATION will be taken if ''.]:[oasdir:='${def_oasdir}']"
  USAGE+="[y:cosdir?Source directory for Cosmo. cosmoV_MACHINE_VERSION_COMBINATION will be taken if ''.]:[cosdir:='${def_cosdir}']"
  USAGE+="[x:clmdir?Source directory for CLM. clmV_MACHINE_VERSION_COMBINATION will be taken if ''.]:[clmdir:='${def_clmdir}']"
  USAGE+="[z:pfldir?Source directory for Parflow. parflowV_MACHINE_VERSION_COMBINATION will be taken if ''.]:[pfldir:='${def_pfldir}']"

  USAGE+="[H:hyprepath?Include Path for Hypre. The machine default will be taken if ''.]:[hyprepath:='$hyprePath']"
  USAGE+="[S:silopath?Include Path for Silo. The machine default will be taken if ''.]:[silopath:='$siloPath']"
  USAGE+="[T:tclpath?Include Path for TCL. The machine default will be taken if ''.]:[tclpath:='$tclPath']"
  USAGE+="[G:gribpath?Include Path for Grib1. The machine default will be taken if ''.]:[gribpath:='$gribPath']"
  USAGE+="[M:mpipath?Include Path for MPI. The machine default will be taken if ''.]:[mpipath:='$mpiPath']"
  USAGE+="[N:ncdfpath?Include Path for NetCDF. The machine default will be taken if ''.]:[ncdfpath:='$ncdfPath']"
  USAGE+="[P:pncdfpath?Include Path for PNetCDF. The machine default will be taken if ''.]:[pncdfpath:='$pncdfPath']"
  USAGE+="[L:lapackpath?Include Path for LapackCDF. The machine default will be taken if ''.]:[lapackpath:='$lapackPath']"
  USAGE+=$'\n\n\n\n'



  args=0
  # parsing the command line arguments
  while getopts "$USAGE" optchar ; do
    case $optchar in
    m)  platform="$OPTARG" ; args=1 ;;
    p)  profiling="${OPTARG}" ; args=1 ;;
    o)  optComp="${OPTARG}" ; args=1 ;; 
    O)  compiler="${OPTARG}" ; args=1 ;;
    v)  version="$OPTARG"  ;  args=1 ;;
    a)  listA="true" ;;
    t)  listTutorial ;;
    R)  rootdir="$OPTARG" ; args=1 ;;
    B)  bindir="$OPTARG" ; args=1 ;;
    c)  combination="$OPTARG" ; args=1 ;;
    C)  cplscheme="$OPTARG" ; args=1 ;;
    r)  readCLM="$OPTARG" ; args=1 ;;
    f)  maxpft="$OPTARG" ; args=1 ;;
    d)  freeDrain="$OPTARG" ; args=1 ;;
#DA
    T)  options+=(["icon"]="$OPTARG") ; args=1 ;;
    U)  options+=(["da"]="$OPTARG") ; args=1 ;;
    W)  options+=(["oas"]="$OPTARG") ; args=1 ;;
    Y)  options+=(["cos"]="$OPTARG") ; args=1 ;;
    X)  options+=(["clm"]="$OPTARG") ; args=1 ;;
    Z)  options+=(["pfl"]="$OPTARG") ; args=1 ;;
#DA
    u)  dadir="$OPTARG" ; args=1 ;;
    w)  oasdir="$OPTARG" ; args=1 ;;
    y)  cosdir="$OPTARG"; args=1 ;;
    x)  clmdir="$OPTARG"; args=1 ;;
    z)  pfldir="$OPTARG"; args=1 ;;

    M)  mpiPath="$OPTARG" ; args=1 ;;
    N)  ncdfPath="$OPTARG" ; args=1 ;;
    G)  gribPath="$OPTARG" ; args=1 ;;
    T)  tclPath="$OPTARG" ; args=1 ;;
    H)  hyprePath="$OPTARG" ; args=1 ;;
    S)  siloPath="$OPTARG" ; args=1 ;; 
    P)  pnetcdfPath="$OPTARG" ; args=1 ;;
    L)  lapackPath="$OPTARG" ; args=1 ;;
    A)  processor="$OPTARG" ; args=1 ;;
    esac
  done

deprecatedVersion

comment "  source list with supported machines and configurations"
  . $rootdir/bldsva/supported_versions.ksh
check

  if [[ $listA == "true" ]] ; then ; listAvailabilities ; fi





  hardSanityCheck

  #if no combination is set, load first as default
  if [[ $combination == "" ]] ; then
    set -A array ${combinations[$version]}
    combination=${array[0]}
  fi

  setCombination
  comment "  source machine build interface for $platform"
    . ${rootdir}/bldsva/machines/config_${platform}.ksh >> $log_file 2>> $err_file
  check
  getMachineDefaults
  setSelection

printf "$platform\n$profiling\n$optComp\n$compiler\n$version\n$rootdir$bindir\n$combination\n$readCLM" > build_info_${date}.txt

  softSanityCheck
  # comment "  source common interface"
  #   . ${rootdir}/bldsva/intf_oas3/common_build_interface.ksh >> $log_file 2>> $err_file
  # check


  runCompilation

  echo "Patched files:  NOTE: sed substitutions are not listed" >> $log_file
  #cat $patchlog_file >> $log_file

  echo "" >> $log_file
  echo "Git:" >> $log_file
  cd $rootdir
  git rev-parse --abbrev-ref HEAD >> $log_file
  git rev-parse HEAD >> $log_file
  
  echo "" >> $log_file 
  echo "Selection:" >> $log_file

  #remove special charecters for coloring from logfiles
  sed -i "s,.\[32m,,g" $log_file
  sed -i "s,.\[31m,,g" $log_file
  sed -i "s,.\[34m,,g" $log_file
  sed -i "s,.\[36m,,g" $log_file
  sed -i "s,.[(]B.\[m,,g" $log_file

  sed -i "s,.\[32m,,g" $stdout_file
  sed -i "s,.\[31m,,g" $stdout_file
  sed -i "s,.\[34m,,g" $stdout_file
  sed -i "s,.\[36m,,g" $stdout_file
  sed -i "s,.[(]B.\[m,,g" $stdout_file

  echo "" >> $log_file
  echo "Call:" >> $log_file
  print "$call $*">> $log_file
  mv -f $err_file $bindir
  mv -f $log_file $bindir
  mv -f $stdout_file $bindir
  rm -f $patchlog_file

  print ${cgreen}"build script finished sucessfully"${cnormal}
  print "Rootdir: ${rootdir}"
  print "Bindir: ${bindir}"


