###################################################################################################################
#                                       - NOTICE -
#                                       AT&T Proprietary
#                               Use Pursuant to Company Instructions
####################################################################################################################
#       Name     : Svn_build_lsrv_order.sh
#       Location :
#       Authors  : Gilad Sagi
#       Usage    : Single_module_pipeline_build.sh [ModuleName] (used from Jenkins)
#       Purpose  :
#                    Creates LSRV build package
####################################################################################################################

#!/usr/bin/ksh

## Step # 0
# check if the svn_env file exists
# check the if the variables SVNBIN and SVNROOT have been setup or not
if [ "$SVNBIN" != "" ]
then
                if [ "$SVNROOT" != "" ]
                then
                                . $SVNBIN/svn_functions
                #                svn_login_check_for_build
                else
                                echo "The required SVN environment variable SVNROOT has not been set."
                                echo "Now exiting"
                                exit 1
                fi
else
                echo "The required SVN environment variable SVNBIN has not been set."
                echo "Now exiting"
                exit 1
fi


export BASEDIR=`pwd`
cd $BASEDIR
echo
echo "BASEDIR is $BASEDIR "
echo

. /LSRV/lsrv/conf/lsrv_env_single_pipeline

. ${RT_BIN}/build_lsrv_artix5_5_JAX_WS_JDK8_single_pipeline.env

#appened the DEPO/lib jars into the original CLASSPATH to take the new jars first, only if not existing take from the original lib

CLASSPATH=$(echo "$CLASSPATH" | sed 's@'"$LSRV_HOME2"'@'"$LSRV_HOME"'@g'):$CLASSPATH
echo "CLASSPATH3 is $CLASSPATH "

ModuleName=$1
Release=$2
SubApp=$3

filename=${ModuleName}_${Release}.tar

WORKSPACE=/appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace

MDL_PATH=$WORKSPACE/SingleModule_Pipeline/${ModuleName}

echo "MDL_PATH is $MDL_PATH"
rm -rf DEPO

mkdir -p DEPO/lib
mkdir -p DEPO/bin


if [ "$ModuleName" != "lsrv_conf" ] && [ "$ModuleName" != "lsrv_schema" ]
then

  cd $WORKSPACE/SingleModule_Pipeline/lsrv_conf
  ./build.sh

  cd $WORKSPACE/SingleModule_Pipeline/lsrv_schema
  ./build.sh
fi


cd $MDL_PATH

for script in `find . -name  build.sh -print | grep build.sh` ; do
  cd $MDL_PATH
  DIR=`dirname $script`
  cd $DIR
  if [ -f build.sh ]
  then
    chmod +x build.sh
    echo
    echo "Working at $script"
    echo "-------------------------------------------------------------------------------"
    echo
    ./build.sh
    echo
    echo "-------------------------------------------------------------------------------"
  else
    echo "No need to build..."
    echo
    echo "-------------------------------------------------------------------------------"
  fi
done

cd $LSRV_HOME
echo $SubApp > SubApp.txt

if [ "$ModuleName" != "lsrv_conf" ] && [ "$ModuleName" != "lsrv_schema" ]
then
  rm -rf conf/*
  rm -rf schema/*
fi

chmod -R 775 *
tar -cf $filename *
gzip $filename
echo
echo "Package is: $LSRV_HOME/$filename.gz "


