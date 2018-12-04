
###################################################################################################################
#                                       - NOTICE -
#                                       AT&T Proprietary
#                               Use Pursuant to Company Instructions
####################################################################################################################
#       Name     : Svn_build_lvi.sh
#       Location :
#       Authors  : Rupali Goyal
#       Usage    : Svn_build_lvi.sh [Release Name]
#       Purpose  :
#                    Creates LVI Classic build package
#                          Executes following steps
#                       a) Import svn_function script that have common functions.
#                       b) Run the svn login command to SVN login for specific user id.
#                       c) Proceed if Current Directory is empty
#                       d) Check out the code for given release
#                       e) Proceed if file containing Module List for this release is checked out properly
#                       f) Compile the code by running build.sh script of each module
#                       g) Create build package
####################################################################################################################

#!/usr/bin/ksh

if [ "$#" -ne 1 ]
then
    echo "Usage: Svn_build_lvi.sh [Release Name]"
    exit 2
fi

## Step # 0
# check if the svn_env file exists
# check the if the variables SVNBIN and SVNROOT have been setup or not
. $SVNBIN/svn_env
if [ "$SVNBIN" != "" ]
then
                if [ "$SVNROOT" != "" ]
                then
                                . $SVNBIN/svn_functions
                                #svn_login
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

#Place holder for .env file
#currently it is pointing to build_lvi_6.env file
#will be changed as SVN is ready
ARTIX_HOME=/opt/artix_5.5
PATH=$JAVA_HOME/bin:$ARTIX_HOME/java/bin:$ARTIX_HOME/cxx_java/bin:$PATH
export PATH ARTIX_HOME
. ${RT_BIN}/build_lvi_8.env
export ORBIX_WEB_ROOT=/appl/shared/iona
# Following section checks whether current directory is empty or not
# If it is empty then it checked out information for releases and modules.
#files=`ls | grep -v nohup | grep -v .out`
#if [ "$files" != ""  ]
#then
#    echo "Current Directory is not clean."
# exit 2
#fi

#Check out code
mkdir -p DEPO/log
bld_time=`date "+%m%d%H"`
release_name=$1
if [ "$release_name" = "HEAD" ]
then
        filename=lvi_HEAD_${bld_time}.tar
        rel_version=lvi_HEAD_${bld_time}
        release=HEAD
#        . ${SVNBIN}/svn_get_code.sh HEAD LVI
else
        echo "In Release "
        rel_mon=`echo $1 | cut -c6-7` 
        rel_year=`echo $1 | cut -c2-5`
        rel_date=`echo $1 | cut -c8-9`
        rel_name=`echo $1 | cut  -c2-9`
	filename=lvi_${release_name}.tar
        rel_version=lvi_${rel_name}_${bld_time}
        release=${rel_year}_${rel_mon}${rel_date}
#        . ${SVNBIN}/svn_get_code.sh $release_name LVI
        echo "After Release"
fi


echo
echo "CLASSPATH is :"
echo $CLASSPATH
echo

module_list=`ls build_system/LVI.lst.dat`
if [ "$module_list" = ""  ]
then
    echo "Could not find file $BASEDIR/build_system/LVI.lst.dat"
   exit 2
fi

# Following section is responsible for code compile
for i in `cat build_system/LVI.lst.dat` ; do
    echo
    cd $BASEDIR
        echo "Locating $i ..."
    cd $i
        echo "Present Directory"
        echo | pwd
    echo
    for script in `find . -name  build.sh -print | grep build.sh` ; do
        cd $BASEDIR
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

##Creating links for Orbix jar files for PreOrder
##This is used in catalina.sh JAVA_ENDORSED_DIRS
cd $LVI_HOME/lib
mkdir endorsed
cd endorsed
ln -s ../OrbixNames.jar OrbixNames.jar
ln -s ../OrbixWeb.jar OrbixWeb.jar
ln -s ../OrbixNamesUtils.jar OrbixNamesUtils.jar
#################################################

echo
echo "Starting tomcat web server at port 15080 for JSP and HTML Precompile process. Please wait ... "
echo
cp -f ${RT_BIN}/server.xml.15080 $LVI_HOME/tomcat/conf/server.xml
cp -f $LVI_HOME/tomcat/conf/prod_conf/web.xml $LVI_HOME/tomcat/conf/
mkdir -p $LVI_HOME/tomcat/logs
cd $LVI_HOME/tomcat/bin/
./startup.sh
sleep 40

echo
cd $LVI_HOME/tomcat/webapps/
ord_jsp=`find Order/jsp -type d`
precomp.sh $ord_jsp porequest/jsp Drt/jsp Pt/jsp LsrvPt/jsp


echo
echo "Shutting down tomcat web server. Please wait ... "
cd $LVI_HOME/tomcat/bin/
./shutdown.sh

sleep 5
mv catalina.sh_6 catalina.sh
echo "Restoring production configuration file ..."
cd $LVI_HOME/tomcat/conf
rm server.xml web.xml 2>/dev/null

echo "Creating production package, please wait ..."
rm $LVI_HOME/tomcat/logs/*

cd $LVI_HOME

echo "RELEASE:$release" > conf/Release
echo "RELEASE:$rel_version" > conf/Version
echo "RELEASE:$release" > $LVI_HOME/tomcat/webapps/Order/conf/Release
chmod -R 775 *
tar -cf $filename *
gzip $filename
echo
echo "Package is: $LVI_HOME/$filename.gz "
echo
echo "LVI package build process finished. Verify log file for errors".
