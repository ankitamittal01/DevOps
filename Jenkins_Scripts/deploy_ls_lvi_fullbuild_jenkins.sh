#!/bin/ksh

release=$1

version=0
### Calculate Version ###

#if grep "$release" /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi.txt
#then
#   version=`grep $release /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi.txt | cut -d "@" -f2`
#   versionN=$((version+1))
#   sed 's/'"$release"'@'"$version"'/'"$release"'@'"$versionN"'/' /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi.txt > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi_tmp.txt
#   mv /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi_tmp.txt /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi.txt
#else
#   echo "$release@0" >> /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_ls_lvi.txt
#fi

$releaseN=`echo $release | cut -d "r" -f2`

releaseV=$release.$(date +"%Y%m%d.%H%M%S")

echo "$releaseV" > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/ls_lvi_swm_versions.txt

### Deploy tar.gz to Nexus ###

       mvn deploy:deploy-file \
       -Durl=http://mavencentral.it.att.com:8084/nexus/content/repositories/att-repository-3rd-party \
       -DrepositoryId=nexus \
       -DgroupId=com.att.lsrv \
       -DartifactId=LSRV_LS_LVI_FullBuild \
       -Dversion=$releaseV  \
       -Dpackaging=tar.gz \
       -Dfile=/appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/LS_LVI_Pipeline/DEPO/ls_lvi_$release.tar.gz
