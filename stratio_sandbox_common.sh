#################
## ENVIRONMENT ##
#################

export STRATIO_ENV="$(echo ${1:-PRE} | tr '[:lower:]' '[:upper:]')"
export STRATIO_MODULE=$2
export STRATIO_MODULE_BRANCH=$3
export STRATIO_MODULE_VERSION=$4

case "$STRATIO_ENV" in
	LOCAL) REPOSITORY="berilio.stratio.com/DEV/1.1"
		;;
	DEV) REPOSITORY="berilio.stratio.com/DEV/1.1"
		;;
	PRE) REPOSITORY="prerepository.stratio.com/TEST/1.4"
		;;
	PRO) REPOSITORY="repository.stratio.com/sds/stable"
		;;
	*) REPOSITORY="berilio.stratio.com/DEV/1.1"
		;;
esac		
export REPOSITORY

export WORK_MODULE_DIR=/home/vagrant/module
export DOWNLOADS_DIR=/home/vagrant/downloads

yum_install() {
	yum install -y -q $@
}

add_repo() {
cat >/etc/yum.repos.d/${1}.repo <<EOF
[${1}]
name=${2}
baseurl=${3}
gpgcheck=0
enabled=1
EOF
}

download() {
	url="$1"
	dest="$2"
	shift 2
	wget --no-check-certificate -q "$url" -O "$dest" $@
}

#############
## FOLDERS ##
#############
mkdir -p "${WORK_MODULE_DIR}"
mkdir -p "${DOWNLOADS_DIR}"

##################
## REPOSITORIES ##
##################

echo 'Loading repositories...'
yum_install --nogpgcheck http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
add_repo "mongodb" "MongoDB Repository" "http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/"
add_repo "stratio" "Stratio Repository" "http://$REPOSITORY/RHEL/6.x"

##########
## JAVA ##
##########

echo "Checking java..."
if type -p java; then
    echo "OK. Java is already installed"
else
    echo "Downloading Java 7 from Oracle..."
    curl -s -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.tar.gz > /tmp/jdk-7u71-linux-x64.tar.gz

    echo "Installing Java 7..."
    mkdir /usr/java && cd /usr/java
    tar -xzf /tmp/jdk-7u71-linux-x64.tar.gz
    chown -R root:root jdk1.7.0_71
    ln -s jdk1.7.0_71 default
    ln -s jdk1.7.0_71 latest
    update-alternatives --install /usr/bin/java java /usr/java/default/bin/java 1000
    update-alternatives --install /usr/bin/java java /usr/java/latest/bin/java 500
    update-alternatives --install /usr/bin/jps jps /usr/java/default/bin/jps 1000
    rm -f /tmp/jdk-7u71-linux-x64.tar.gz

    echo "Setting up Java..."
	
    cat >/etc/profile.d/java.sh <<EOF
# The first existing directory is used for JAVA_HOME if needed.
JVM_SEARCH_DIRS="/usr/java/default /usr/lib/jvm/jre-openjdk /usr/lib/jvm/jre /usr/lib/jvm/jre-1.7.* /usr/lib/jvm/java-1.7.*/jre"

# If JAVA_HOME has not been set, try to determine it.
if [ -z "\$JAVA_HOME" ]; then
    # If java is in PATH, use a JAVA_HOME that corresponds to that. This is
    # both consistent with how the upstream startup script works, and with
    # the use of alternatives to set a system JVM (as is done on Debian and
    # Red Hat derivatives).
    java="\`/usr/bin/which java 2>/dev/null\`"
    if [ -n "\$java" ]; then
        java=\`readlink --canonicalize "\$java"\`
        JAVA_HOME=\`dirname "\\\`dirname \\\$java\\\`"\`
    else
        # No JAVA_HOME set and no java found in PATH; search for a JVM.
        for jdir in \$JVM_SEARCH_DIRS; do
            if [ -x "\$jdir/bin/java" ]; then
                JAVA_HOME="\$jdir"
                break
            fi
        done
        # if JAVA_HOME is still empty here, punt.
    fi
fi
JAVA="\$JAVA_HOME/bin/java"
export JAVA_HOME JAVA
EOF
fi


###################
## MISCELLANEOUS ##
###################

# TODO: MODIFY WITH CORPORATE MESSAGE
grep -qi stratio /home/vagrant/.bash_profile || cat >>/home/vagrant/.bash_profile <<EOF
ipaddress_eth0=\$(ip -4 addr show dev eth0 | grep inet | sed -e 's/^.*inet \\(.*\\)\\/.*$/\\1/g')
ipaddress_eth1=\$(ip -4 addr show dev eth1 | grep inet | sed -e 's/^.*inet \\(.*\\)\\/.*$/\\1/g')

echo "Welcome to"
echo "\$(figlet -f slant -c Stratio)"

echo "Your IP addresses seem to be:"
echo "   eth0: \$ipaddress_eth0"
echo "   eth1: \$ipaddress_eth1"
EOF

echo "Adding IP to /etc/hosts..."
ipaddress=$(ip -4 addr show dev eth0 | grep inet | sed -e 's/^.*inet \(.*\)\/.*$/\1/g')
hostname=$(hostname --fqdn)
grep -v 127.0.0.1 /etc/hosts | grep -q $hostname || echo "$ipaddress   $hostname" >> /etc/hosts
# Adds ip address to /etc/hosts with every reboot, very convenient with DHCP network
cat >/etc/init.d/ipaddress <<EOF
#!/bin/bash
#
# /etc/init.d/ipaddress
#
# chkconfig: 345 40 60
# description: Just adds local ip address to /etc/hosts

ipaddress=\$(ip -4 addr show dev eth0 | grep inet | sed -e 's/^.*inet \\(.*\\)\\/.*$/\\1/g')
hostname=\$(hostname --fqdn)

grep -v 127.0.0.1 /etc/hosts | grep -q \$hostname
ipexists=\$?

if [ \$ipexists -eq 0 ]; then
  sed -i "s/^.*\$hostname$/\$ipaddress   \$hostname/" /etc/hosts
else
  echo "\$ipaddress   \$hostname" >> /etc/hosts
fi

exit 0
EOF
chmod 755 /etc/init.d/ipaddress
chkconfig --add ipaddress
chkconfig ipaddress on

echo "Installing additional packages..."
yum -y -q --nogpgcheck install figlet git man grep curl

##############
## SERVICES ##
##############

echo "Installing common services..."
yum -y -q --nogpgcheck install stratio-scala stratio-kafka stratio-zookeeper stratio-cassandra stratio-elasticsearch mongodb-org
chkconfig --add zookeeper
chkconfig zookeeper off
chkconfig --add kafka
chkconfig kafka off
chkconfig --add cassandra
chkconfig cassandra off
chkconfig --add elasticsearch
chkconfig elasticsearch off


#### CONFIG ElasticSearch ####
## TODO: remove this first line when modules accept cluster name
sed -i 's/cluster.name: "Stratio ElasticSearch"/#cluster.name: "Stratio ElasticSearch"/g' /etc/sds/elasticsearch/elasticsearch.yml
sed -i 's/discovery.zen.minimum_master_nodes: 2/discovery.zen.minimum_master_nodes: 1/g' /etc/sds/elasticsearch/elasticsearch.yml
sed -i 's/gateway.recover_after_nodes: 2/gateway.recover_after_nodes: 1/g' /etc/sds/elasticsearch/elasticsearch.yml
sed -i 's/gateway.recover_after_master_nodes: 2/gateway.recover_after_master_nodes: 1/g' /etc/sds/elasticsearch/elasticsearch.yml
sed -i 's/index.number_of_replicas: 2/index.number_of_replicas: 1/g' /etc/sds/elasticsearch/elasticsearch.yml


####################################
## DOWNLOAD & RUN SPECIFIC MODULE ##
####################################

DOWNLOAD_MODULE_SH_URL="https://raw.githubusercontent.com/Stratio/${STRATIO_MODULE}/${STRATIO_MODULE_BRANCH}/sandbox/stratio_sandbox_module"
MODULE_SH_PATH="${WORK_MODULE_DIR}/stratio_sandbox_module"

echo "Downloading module script from ${DOWNLOAD_MODULE_SH_URL}"
download "${DOWNLOAD_MODULE_SH_URL}" "${MODULE_SH_PATH}"
curl -f -s -m 5 http://www.stratio.com/CheckUpdate/${STRATIO_MODULE}/${STRATIO_MODULE_VERSION}

echo "Executing module script..."
. "${MODULE_SH_PATH}"
