#################
## ENVIRONMENT ##
#################

export STRATIO_MODULE_NAME=$1
export STRATIO_MODULE_FULLNAME=$2
export STRATIO_MODULE_VERSION=$3
export STRATIO_MODULES_HOSTNAMES_IPS=$4
export STRATIO_MODULE_BANNER=$5

echo 'Loading repositories...'
yum install -y --nogpgcheck http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm 

##ADDING STRATIO REPO
echo 'Stratio inconming'
wget "http://sodio.stratio.com/nexus/service/local/artifact/maven/content?r=releases-art&g=stratio&a=stratio-releases&c=noarch&p=rpm&v=LATEST" -O tmpfile.rpm
yum -y localinstall tmpfile.rpm
yum update 
rm tmpfile.rpm

if [ STRATIO_MODULE == "streaming" ]; then
    echo "Installing Stratio streaming packages"    
    yum -y install stratio-"${STRATIO_MODULE_NAME}"-"${STRATIO_MODULE_VERSION}" 
    yum -y install stratio-"${STRATIO_MODULE_NAME}"-shell-"${STRATIO_MODULE_VERSION}" 
else
    echo "Installing your Stratio module package..."
    yum -y install stratio-"${STRATIO_MODULE_NAME}"-"${STRATIO_MODULE_VERSION}"
fi

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

##Figlet installation to show welcome message
echo "Installing additional shell packages..."
yum -y install figlet
figlet -f slant -c Stratio > /home/welcome
figlet -f slant -c ${STRATIO_MODULE_NAME} >> /home/welcome
figlet -c ${STRATIO_MODULE_VERSION} >> /home/welcome
echo ""
#Welcome with usefull network info 
grep -qi stratio /home/vagrant/.bash_profile || cat >> /home/vagrant/.bash_profile <<EOF
ipaddress_eth0=\$(ip -4 addr show dev eth0 | grep inet | sed -e 's/^.*inet \\(.*\\)\\/.*$/\\1/g')
ipaddress_eth1=\$(ip -4 addr show dev eth1 | grep inet | sed -e 's/^.*inet \\(.*\\)\\/.*$/\\1/g')
ipaddress_eth2=\$(ip -4 addr show dev eth2 | grep inet | sed -e 's/^.*inet \\(.*\\)\\/.*$/\\1/g')
echo "Welcome to"
echo "\$(cat /home/welcome)"
echo ""
echo "Your IP addresses seem to be:"
echo "(nat/internal use) eth0: \$ipaddress_eth0   "
echo "(hostonly/fixed)   eth1: \$ipaddress_eth1   "
echo "(bridged/dhcp)     eth2: \$ipaddress_eth2   "    
echo ""
echo "${STRATIO_MODULE_BANNER}"
sudo /etc/init.d/${STRATIO_MODULE_NAME} start
EOF

## Add fixed ips to hosts
echo "Adding IP to /etc/hosts..."
echo -e $STRATIO_MODULES_HOSTNAMES_IPS >> /etc/hosts
##Setting hostname 
sed -i 's/^HOSTNAME=.*$/HOSTNAME='${STRATIO_MODULE_NAME}'.box.stratio.com/g' /etc/sysconfig/network
##Delete net rules
sed -i 's/^SUBSYSTEM/#SUBSYSTEM/g' /etc/udev/rules.d/70-persistent-net.rules 
history -c
