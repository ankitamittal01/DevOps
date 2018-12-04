#!/usr/bin/ksh

## Step # 0
# check if the svn_env file exists
# check the if the variables SVNBIN and SVNROOT have been setup or not

export BASEDIR=`pwd`
cd $BASEDIR
echo
echo "BASEDIR is $BASEDIR "
echo
release_name=$1
#bash svn_get_code.sh $release_name PreOrder
#. ${SVNBIN}/svn_get_code.sh $release_name PreOrder
#. ${RT_BIN}/build_lsrv_artix5_5_JAX_WS_JDK8.env
. /LSRV/po_lsrv/conf/po_lsrv_env
#store release tag in build_system/Tag This will be used in partial build
echo $release_name > build_system/Tag

mkdir -p DEPO/log
mkdir lib
bld_time=`date "+%m%d%H"`
if [ "$release_name" = "HEAD" ]
then
	filename=po_lsrv_HEAD_${bld_time}.tar
	rel_version=po_lsrv_HEAD_${bld_time}
	release=HEAD
	
else
	echo "In Release "
#	rel_mon=`echo $1 | cut -c13-14`
#	rel_year=`echo $1 | cut -c9-12`
#	rel_date=`echo $1 | cut -f2 -d'_' | cut -c2-3`
	rel_mon=`echo $1 | cut -c6-7`
        rel_year=`echo $1 | cut -c2-5`
        rel_date=`echo $1 | cut -c8-9`
	filename=po_lsrv_${release_name}.tar
	rel_version=po_lsrv_${rel_year}${rel_mon}${rel_date}_${bld_time}
	release=${rel_year}_${rel_mon}${rel_date}
	echo "After Release"
fi

#svn co $SVNROOT/build_system/branches/$release build_system 
#Place holder for .env file
#currently it is pointing to build_po_lsrv_artix5_5.env file
#will be changed as SVN is ready
#. ${RT_BIN}/build_po_lsrv_artix5_5.env
#export JAVA_HOME=/opt/jdk1.6.0_21
export JAVA_HOME=/appl/shared/jdk180
#PATH=$JAVA_HOME/bin:$PATH:/usr/ucb
PATH=$JAVA_HOME/bin:$PATH
LSRV_BASE=$BASEDIR
LSRV_HOME=$BASEDIR/DEPO
PO_BIN=$LSRV_HOME/bin
LVI_HOME=$BASEDIR
export  LVI_HOME
PO_LSRV_BASE=$BASEDIR
PO_LSRV_HOME=$BASEDIR
EDIDIR=$LSRV_HOME/edi
IT_CONFIG_PATH=$PO_LSRV_HOME/orbix_conf
LD_LIBRARY_PATH=/usr/lib:/usr/ucblib:$PO_LSRV_HOME/lib
ENCRYPTOR_HOME=$PO_LSRV_HOME/DEPO/bin
ORACLE_HOME=/opt/oracle/8.1.7
APACHE_LIB=$BASEDIR/po_lsrv_lib
export JAVA_HOME PATH LSRV_BASE LSRV_HOME PO_LSRV_BASE PO_LSRV_HOME EDIDIR LD_LIBRARY_PATH IT_CONFIG_PATH ENCRYPTOR_HOME ORACLE_HOME

CLASSPATH=$(echo "$CLASSPATH" | sed 's@'"$PREORDER_BIN"'@'"$PO_BIN"'@g'):$CLASSPATH

ARTIX_HOME=/opt/artix_5.5
export ARTIX_HOME
PATH=${ARTIX_HOME}/java/bin:${ARTIX_HOME}/cxx_java/bin:$PATH
PATH=$LSRV_HOME/bin:$PATH
export PATH
echo PATH= $PATH
CLASSPATH=$ORACLE_HOME/jdbc/lib/classes12.zip:$CLASSPATH
export CLASSPATH
export CLASSPATH=$PO_LSRV_HOME/lib/gateKeeper.jar:$CLASSPATH
export CLASSPATH=$PO_LSRV_HOME/lib/servlet.jar:$CLASSPATH
#export CLASSPATH=/LSRV/lsrv/lib/OrderComm.jar:$CLASSPATH

export CODE_DIR=$BASEDIR
#svn_get_code.sh $release_name PreOrder
echo CLASSPATH is : $CLASSPATH
for i in `cat ${CODE_DIR}/build_system/pre_order.lst.dat` ; do
    echo
    cd ${CODE_DIR}
	echo "Locating $i ..."
    cd $i
	echo "Present Directory"
	echo | pwd
    echo
    for script in `find . -name  build.sh -print | grep build.sh` ; do
	cd ${CODE_DIR}
	cd $i
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
            echo "No need to build $i. Skipping ..."
            echo
            echo "-------------------------------------------------------------------------------"
        fi
	done 
	# End of inner loop.
done
# End of outer loop.

#store release tag in build_system/Tag This will be used in partial build
#echo $release_name > build_system/Tag

cd $LSRV_HOME

echo "RELEASE:$release" > conf/Release
echo "RELEASE:$rel_version" > conf/Version

chmod -R 775 *
find . -name "SVN"|xargs rm -rf
tar -cf $filename *
gzip $filename
echo
echo "Package is: $LSRV_HOME/$filename.gz "
echo
echo "LSRV Preorder package build process finished. Verify log file for errors. "
