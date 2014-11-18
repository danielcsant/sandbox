
export STRATIO_ENV="$(echo ${STRATIO_ENV:-PRE} | tr '[:lower:]' '[:upper:]')"
export STRATIO_MODULE_GITHUB_NAME="${STRATIO_MODULE_GITHUB_NAME:-sandbox}"

case "$STRATIO_ENV" in
	LOCAL) REPOSITORY="berilio.stratio.com/DEV/1.0.0"
		;;
	DEV) REPOSITORY="berilio.stratio.com/DEV/1.0.0"
		;;
	PRE) REPOSITORY="prerepository.stratio.com/TEST/1.0.0"
		;;
	PRO) REPOSITORY="repository.stratio.com/stable"
		;;
	*) REPOSITORY="berilio.stratio.com/DEV/1.0.0"
		;;
esac		
		
REPOSITORY_URL="deb http://${REPOSITORY}/ubuntu/13.10/ binary/"

export DEBIAN_FRONTEND=noninteractive

#############
## FOLDERS ##
#############
mkdir -p /home/vagrant/downloads

##################
## REPOSITORIES ##
##################

echo 'Loading repositories...'

wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
add-apt-repository 'deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main'

echo "deb http://${REPOSITORY}/ubuntu/13.10/ binary/" | sudo tee -a /etc/apt/sources.list

add-apt-repository ppa:webupd8team/java

echo 'Updating repositories...'
apt-get update -q -y


##########
## JAVA ##
##########

echo 'Installing Java 7 oracle...'

curl -s -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.tar.gz > /tmp/jdk-7u71-linux-x64.tar.gz
mkdir /usr/java && cd /usr/java
tar -xzf /tmp/jdk-7u71-linux-x64.tar.gz
chown -R root:root jdk1.7.0_71
ln -s jdk1.7.0_71 default
ln -s jdk1.7.0_71 latest
update-alternatives --install /usr/bin/java java /usr/java/default/bin/java 1000
update-alternatives --install /usr/bin/java java /usr/java/latest/bin/java 500
rm -f /tmp/jdk-7u71-linux-x64.tar.gz


##############
## SERVICES ##
##############

echo 'Installing common services...'
apt-get install stratio-kafka stratio-zookeeper stratio-cassandra elasticsearch mongodb-org git -q -y --force-yes


####################################
## DOWNLOAD & RUN SPECIFIC MODULE ##
####################################

echo 'Installing common services...'
mkdir -p /home/vagrant/module
DOWNLOAD_MODULE_SH_URL="https://raw.githubusercontent.com/Stratio/${STRATIO_MODULE_GITHUB_NAME}/master/sandbox/stratio_sandbox_module"
curl $DOWNLOAD_MODULE_SH_URL > /home/vagrant/module/stratio_sandbox_module
bash /home/vagrant/module/stratio_sandbox_module

