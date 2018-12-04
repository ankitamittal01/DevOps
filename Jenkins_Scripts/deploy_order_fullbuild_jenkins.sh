#!/bin/ksh

release=$1
version=0
### Calculate Version ###

#if grep "$release" /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order.txt
#then
#   version=`grep $release /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order.txt | cut -d "@" -f2`
#   versionN=$((version+1))
#   sed 's/'"$release"'@'"$version"'/'"$release"'@'"$versionN"'/' /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order.txt > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order_tmp.txt
#   mv /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order_tmp.txt /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order.txt
#else
#   echo "$release@0" >> /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/build_versions_order.txt
#fi

#releaseN=`echo $release | cut -d "r" -f2`

#echo "$releaseN.$version" > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/order_swm_versions.txt

releaseV=$release.$(date +"%Y%m%d.%H%M%S")

echo "$releaseV" > /appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/SCRIPTS/order_swm_versions.txt

### Deploy tar.gz to Nexus ###

       mvn deploy:deploy-file \
       -Durl=http://mavencentral.it.att.com:8084/nexus/content/repositories/att-repository-3rd-party \
       -DrepositoryId=nexus \
       -DgroupId=com.att.lsrv \
       -DartifactId=LSRV_Order_FullBuild \
       -Dversion=$releaseV  \
       -Dpackaging=tar.gz \
       -Dfile=/appl/LSRV/node/sdt-lsrv.vci.att.com/appl/LSRV/node/sdt-lsrv.vci.att.com/workspace/Order_pipeline/DEPO/lsrv_$release.tar.gz
