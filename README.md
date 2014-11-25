

Vagrant setup
-------------


Sandboxes are generated with [Vagrant](https://www.vagrantup.com/). Here you will find the steps to install this software



*   Download and install Vagrant: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)



*   Download and install VirtualBox: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)



*   If you are in a windows machine, download and install [Cygwin](https://cygwin.com/install.html)






How to use this VagrantFile
---------------------------

1. Download the following files to a folder where you want to start the sandbox:

- VagrantFile
- vagrant_settings.yml
- stratio_sandbox_common.sh


2. Edit the vagrant_settings.yml:

- Uncomment the module you want to start up

3. Open a shell and type "vagrant up"

-  Your sandbox will be up&running in a few minutes
- Type "vagrant ssh" if you want to log in the sandbox


4. Other useful commands**

*   Start the sandbox:     **vagrant up**

*   Shut down the sandbox:     **vagrant halt**

*   In the sandbox, to exit to the host:     **exit**

*   Re-install the sandbox:    **vagrant provision**

*  Drop the sandbox:    **vagrant destroy**






General info about the sandboxes
--------------------------------

- The VM will be named **stratio-sandbox-module**, where module will be replaced by the module's name.

- Hostname will be **module.stratio.com**. Being module the property stratio_module_name setted in the vagrant_settings.yml

- Other settings are:

  - OS: CentOS 6.5
  - user: "**vagrant**", password: "**vagrant**"

- Regardless the sandbox, you will find these services ready to use:

<table>
<tbody>
<tr>
<td>**Name**</td>
<td>**Version**</td>
<td>**Service name**</td>
<td>**Other**</td>
</tr>
<tr>
<td>Apache Kafka</td>
<td>0.8.1.1</td>
<td>kafka</td>
<td>service kafka start</td>
</tr>
<tr>
<td>Apache Zookeeper</td>
<td>3.4.6</td>
<td>zookeeper</td>
<td>service zookeeper start</td>
</tr>
<tr>
<td>Stratio Cassandra</td>
<td>2.1.05</td>
<td>cassandra</td>
<td>service cassandra start</td>
</tr>
<tr>
<td>Elasticsearch</td>
<td>1.3.2</td>
<td>elasticsearch</td>
<td>service elasticsearch start</td>
</tr>
<tr>
<td>Mongodb</td>
<td>2.6.5</td>
<td>mongod</td>
<td>service mongod start</td>
</tr>
</tbody>
</table>


How this VagrantFile works
---------------------------

# vagrant_settings.yml

This file is used to choose and setup which sandbox you want to start up.

It is the only file you need to edit, there is no need to edit the VagrantFile.

The following properties should be edited in order to setup an specific module:

 - **Environment**: 

    *stratio_env: "PRE"*

 It should be [LOCAL|DEV|PRE|PRO]
 
 - **stratio_module_repository**

    *stratio_module_repository: "https://github.com/Stratio/streaming-cep-engine/tree/master"*

 This module will be fully installed in the sandbox. Please, you must always write the full github url (including /tree/branch).

 - **stratio_module_name**

    *stratio_module_name: streaming*

 Module's name in one word (used for hostname, for instance) 

 - **stratio_module_version**

    *stratio_module_version: "0.5.0"*

 This optional parameter will be the final version of the module. If not present, we will try to retrieve the version from the github url 


# VagrantFile

There is no need to know anything about Vagrant in order to use the sandboxes, all the setup is already coded for you.

Furthermore, all the VM settings can be edited by using the vagrant_settings.yml, such as memory or number of CPUs, among others.

# stratio_sandbox_common.sh

This is the common script for all the sandboxes. All the common packages and setup is executed by this script.







