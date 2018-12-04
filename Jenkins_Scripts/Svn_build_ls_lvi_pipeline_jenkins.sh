###################################################################################################################
#                                       - NOTICE -
#                                       AT&T Proprietary
#                               Use Pursuant to Company Instructions
####################################################################################################################
#       Name     : Svn_build_ls_lvi.sh
#       Location :
#       Authors  : Shivani Suri
#       Usage    : Svn_build_ls_lvi.sh [Release Name] 
#       Purpose  :
#                    Creates LS LVI build package 
#                          Executes following steps
#                       a) Import svn_function script that have common functions.
#                       b) Run the svn login command to SVN login for specific user id.
#						c) Proceed if Current Directory is empty
#						d) Check out the code for given release
#						e) Proceed if file containing Module List for this release is checked out properly
#						f) Compile the code by running build.sh script of each module
#						g) Create build package   
####################################################################################################################

#!/usr/bin/ksh

if [ "$#" -ne 1 ]
then
    echo "Usage: Svn_build_ls_lvi.sh [Release Name]"
    exit 2
fi

## Step # 0
# check if the svn_env file exists
# check the if the variables SVNBIN and SVNROOT have been setup or not
. svn_env
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
#currently it is pointing to build_ls_lvi_6.env file
#will be changed as SVN is ready
. ${RT_BIN}/build_ls_lvi_8.env


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
	filename=ls_lvi_HEAD_${bld_time}.tar
	rel_version=ls_lvi_HEAD_${bld_time}
	release=HEAD
#	. ${SVNBIN}/svn_get_code.sh HEAD LS-LVI
else
	echo "In Release "
	rel_mon=`echo $1 | cut -c6-7`
        rel_year=`echo $1 | cut -c2-5`
        rel_date=`echo $1 | cut -c8-9`
        rel_name=`echo $1 | cut  -c2-9`
	filename=ls_lvi_$release_name.tar
	rel_version=ls_lvi_${rel_name}_${bld_time}
	release=${rel_year}_${rel_mon}${rel_date}
#	. ${SVNBIN}/svn_get_code.sh $release_name LS_LVI
	echo "After Release"
fi

	
echo
echo "CLASSPATH is :"
echo $CLASSPATH
echo

module_list=`ls build_system/LS_LVI.lst.dat`
if [ "$module_list" = ""  ]
then
    echo "Could not find file $BASEDIR/build_system/LS_LVI.lst.dat"
   exit 2
fi

# Following section is responsible for code compile
for i in `cat build_system/LS_LVI.lst.dat` ; do
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

echo
echo "Starting tomcat web server at port 16080 for JSP and HTML Precompile process. Please wait ... "
echo
echo "before cp RT_BIN=$RT_BIN LS_HOME=$LS_HOME"
cp -f ${RT_BIN}/ls_server.xml.16080 $LS_HOME/tomcat/conf/server.xml
cp -f $LS_HOME/tomcat/conf/prod_conf/web.xml $LS_HOME/tomcat/conf/
mkdir -p $LS_HOME/tomcat/logs 
echo "after cp"
ls -l $LS_HOME/tomcat/conf
cd $LS_HOME/tomcat/bin/
./startup.sh
sleep 40

echo
cd $LS_HOME/tomcat/webapps/
ord_jsp=`find LsOrder/COMMON/jsp -type d`
clec_jsp=`find LsOrder/CLEC/jsp -type d`
att_jsp=`find LsOrder/ATT_TELCO/jsp -type d`
attse_jsp=`find LsOrder/ATT_SE/jsp -type d`
sfe_jsp=`find Sfe/jsp -type d`
pt_jsp=`find LsPt/jsp -type d`
precomp_ls.sh $ord_jsp $clec_jsp $att_jsp $attse_jsp $sfe_jsp $pt_jsp

echo
echo "Shutting down tomcat web server. Please wait ... "
cd $LS_HOME/tomcat/bin/
./shutdown.sh

sleep 5
mv catalina.sh_6 catalina.sh
echo "Restoring production configuration file ..."
cd $LS_HOME/tomcat/conf
rm server.xml  2>/dev/null
rm web.xml  2>/dev/null

cd $LS_HOME

echo "RELEASE:$release" > $LS_HOME/tomcat/webapps/LsOrder/conf/Release
echo "RELEASE:$rel_version" > $LS_HOME/conf/Version

chmod -R 775 *
tar -cf $filename *
gzip $filename
echo
echo "Package is: $LS_HOME/$filename.gz "
echo
echo "LS LVI package build process finished. Verify log file for errors. "
