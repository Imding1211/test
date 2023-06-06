#!bin/bash

################################################################################
# File Name          : creat_xrd_mgm.sh
# Last Modified Date : 2023-06-05
# Author             : Ding
# Description        : This script is used to creat xrd.cf.mgm for EOS5.
# Version            : 1.0
# Dependencies       : None
# License            : None
# Contact            : None
################################################################################

hostname=${1}

cat > /etc/xrd.cf.mgm << EOF
###########################################################
xrootd.fslib libXrdEosMgm.so
xrootd.seclib libXrdSec.so
xrootd.async off nosf
xrootd.chksum adler32
###########################################################
xrd.sched mint 8 maxt 256 idle 64
###########################################################
all.export / nolock
all.role manager
###########################################################
oss.fdlimit 16384 32768
###########################################################
# UNIX authentication
sec.protocol unix
# SSS authentication
sec.protocol sss -c /etc/eos.keytab -s /etc/eos.keytab
# GSI authentication
sec.protocol gsi -crl:0 -cert:/etc/grid-security/daemon/hostcert.pem -key:/etc/grid-security/daemon/hostkey.pem -d:1 -gmapopt:2 -vomsat:1 -moninfo:1 -vomsfun:libXrdVoms-5.so
# Host authentication
sec.protocol host

###########################################################
sec.protbind * only gsi sss unix
sec.protbind localhost unix sss
sec.protbind localhost.localdomain unix sss
###########################################################
mgmofs.fs /
mgmofs.targetport 1095
# mgmofs.authlib libXrdAliceTokenAcc.so
# mgmofs.authorize 1
###########################################################
# mgmofs.trace all debug
# this URL can be overwritten by EOS_BROKER_URL defined in /etc/sysconfig/eos

mgmofs.broker root://$hostname:1097//eos/

# this name can be overwritten by EOS_INSTANCE_NAME defined in /etc/sysconfig/eos

mgmofs.instance eostest

# configuration, namespace , transfer and authentication export directory
mgmofs.configdir /var/eos/config
mgmofs.metalog /var/eos/md
mgmofs.txdir /var/eos/tx
mgmofs.authdir /var/eos/auth
mgmofs.archivedir /var/eos/archive
mgmofs.qosdir /var/eos/qos

# report store path
mgmofs.reportstorepath /var/eos/report

# this defines the default config to load
mgmofs.autoloadconfig default

# QoS configuration file
mgmofs.qoscfg /var/eos/qos/qos.conf

#-------------------------------------------------------------------------------
# Config Engine Configuration
#-------------------------------------------------------------------------------
mgmofs.cfgtype file

# this has to be defined if we have a failover configuration via alias - can be overwritten by EOS_MGM_ALIAS in /etc/sysconfig/eos
# mgmofs.alias eosdev.cern.ch

#-------------------------------------------------------------------------------
# Configuration for the authentication plugin EosAuth
#-------------------------------------------------------------------------------
# Set the number of authentication worker threads running on the MGM
# mgmofs.auththreads 10

# Set the front end port number for incoming authentication requests
# mgmofs.authport 15555

###########################################################
# Set the FST gateway host and port
# mgmofs.fstgw someproxy.cern.ch:3001

#-------------------------------------------------------------------------------
# Configuration for the authentication plugin EosAuth
#-------------------------------------------------------------------------------
# Set the number of authentication worker threads running on the MGM
# mgmofs.auththreads 10

# Set the front end port number for incoming authentication requests
# mgmofs.authport 15555

#-------------------------------------------------------------------------------
# Set the namespace plugin implementation
#-------------------------------------------------------------------------------
mgmofs.nslib /usr/lib64/libEosNsQuarkdb.so
mgmofs.qdbcluster $hostname:7777
mgmofs.qdbpassword_file /etc/eos.keytab
mgmofs.cfgtype quarkdb

# Quarkdb custer configuration used for the namespace
# mgmofs.qdbcluster localhost:7777
# mgmofs.qdbpassword_file /etc/eos.keytab

#-------------------------------------------------------------------------------
# Configuration for the MGM workflow engine
#-------------------------------------------------------------------------------

# The SSI protocol buffer endpoint for notification messages from "proto" workflow actions
# mgmofs.protowfendpoint HOSTNAME.2NDLEVEL.TOPLEVEL:10955
# mgmofs.protowfresource /SSI_RESOURCE

#-------------------------------------------------------------------------------
# Confguration parameters for tape
#-------------------------------------------------------------------------------

# mgmofs.tapeenabled false
# mgmofs.prepare.dest.space default

#-------------------------------------------------------------------------------
# Configuration for the tape aware garbage collector
#-------------------------------------------------------------------------------

# EOS spaces for which the tape aware garbage collector should be enabled
# mgmofs.tgc.enablespace space1 space2 ...

xrd.protocol XrdHttp:9000 /usr/lib64/libXrdHttp-5.so
http.trace all
http.cadir /etc/grid-security/certificates/
http.cert /etc/grid-security/daemon/hostcert.pem
http.key /etc/grid-security/daemon/hostkey.pem
http.secxtractor /usr/lib64/libXrdHttpVOMS-5.so
http.exthandler xrdtpc /usr/lib64/libXrdHttpTPC-5.so
http.exthandler EosMgmHttp /usr/lib64/libEosMgmHttp-5.so eos::mgm::http::redirect-to-https=0
mgmofs.macaroonslib /usr/lib64/libXrdMacaroons.so /opt/eos/lib64/libXrdAccSciTokens.so
macaroons.secretkey /etc/eos.macaroon.secret
macaroons.trace all
all.sitename eostest
EOF
