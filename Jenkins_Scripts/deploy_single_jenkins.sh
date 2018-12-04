#!/bin/ksh

mdl=$1
release=$2
version=0

### Calculate Version ###

#if grep "$release" build_versions.txt
#then
#   version=`grep $release build_versions.txt | cut -d "@" -f2`
#   versionN=$((version+1))
#   sed 's/'"$release"'@'"$version"'/'"$release"'@'"$versionN"'/' build_versions.txt > build_versions_tmp.txt
#   mv build_versions_tmp.txt build_versions.txt
#else
#   echo "$release@0" >> build_versions.txt
#fi

#releaseN=`echo $release | cut -d "r" -f2`

releaseV=$release.$(date +"%Y%m%d.%H%M%S")

echo "$releaseV" > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/single_swm_versions.txt

### Deploy tar.gz to Nexus ###

       mvn deploy:deploy-file \
       -Durl=http://mavencentral.it.att.com:8084/nexus/content/repositories/att-repository-3rd-party \
       -DrepositoryId=nexus \
       -DgroupId=com.att.lsrv \
       -DartifactId=$mdl \
       -Dversion=$releaseV  \
       -Dpackaging=tar.gz \
       -Dfile=/appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SingleModule_Pipeline/DEPO/${mdl}_${release}.tar.gz

