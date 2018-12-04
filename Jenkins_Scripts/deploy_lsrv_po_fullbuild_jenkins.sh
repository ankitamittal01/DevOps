#!/bin/ksh

release=$1

version=0
### Calculate Version ###

#if grep "$release" /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po.txt
#then
#   version=`grep $release /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po.txt | cut -d "@" -f2`
#   versionN=$((version+1))
#   sed 's/'"$release"'@'"$version"'/'"$release"'@'"$versionN"'/' /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po.txt > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po_tmp.txt
#   mv /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po_tmp.txt /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po.txt
#else
#   echo "$release@0" >> /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_lsrv_po.txt
#fi

#releaseN=`echo $release | cut -d "r" -f2`

releaseV=$release.$(date +"%Y%m%d.%H%M%S")

echo "$releaseV" > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/po_swm_versions.txt

### Deploy tar.gz to Nexus ###

       mvn deploy:deploy-file \
       -Durl=http://mavencentral.it.att.com:8084/nexus/content/repositories/att-repository-3rd-party \
       -DrepositoryId=nexus \
       -DgroupId=com.att.lsrv \
       -DartifactId=LSRV_PO_FullBuild \
       -Dversion=$releaseV  \
       -Dpackaging=tar.gz \
       -Dfile=/appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/LSRV_PO_Pipeline/DEPO/po_lsrv_$release.tar.gz
