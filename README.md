# How to: install, setup and start the Stratio Sandbox



## **1. Vagrant Setup**


To get an operating virtual machine with stratio streaming distribution up and running, we use [Vagrant](https://www.vagrantup.com/).



*   Download and install Vagrant: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)



*   Download and install VirtualBox: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)



*   Download [the Stratio Streaming Vagrantfile](https://github.com/Stratio/streaming-cep-engine/raw/release/0.5.x/examples/Vagrantfile).



*   If you are in a windows machine, we will install [Cygwin](https://cygwin.com/install.html)



## **2. Running the sandbox**



Copy [the Stratio Streaming Vagrantfile](https://github.com/Stratio/streaming-cep-engine/raw/release/0.5.x/examples/Vagrantfile) into any system folder with exactly the same name, **Vagrantfile**, without filename extension.

* To facilitate the reading of the document , we will refer to this directory as /install-folder.

* Inside this directory, execute **vagrant up**


Please, be patient the first time it runs.


## **3. What you will find in the sandbox**


*   **Hostname: <strong>stratio-streaming**</strong>

*   user: "**vagrant**", password: "**vagrant**"




<table>
<tbody>
<tr>
<td>

**Name**

</td>
<td>

**Version**

</td>
<td>

**Service name**

</td>
<td>

**Other**

</td>
</tr>
<tr>
<td>

Stratio Streaming

</td>
<td>

0.5.0

</td>
<td>

stratio-streaming

</td>
<td>

service streaming start

</td>
</tr>
<tr>
<td>

Stratio Streaming Shell

</td>
<td>

0.5.0

</td>
<td>

-

</td>
<td>

/opt/sds/streaming-shell/bin

</td>
</tr>
<tr>
<td>

Apache Kafka

</td>
<td>

0.8.1.1

</td>
<td>

kafka

</td>
<td>

service kafka start

</td>
</tr>
<tr>
<td>

Apache Zookeeper

</td>
<td>

3.4.6

</td>
<td>

zookeeper

</td>
<td>

service zookeeper start

</td>
</tr>
<tr>
<td>

Stratio Cassandra

</td>
<td>

2.1.05

</td>
<td>

cassandra

</td>
<td>

service cassandra start

</td>
</tr>
<tr>
<td>

Elasticsearch

</td>
<td>

1.3.2

</td>
<td>

elasticsearch

</td>
<td>

service elasticsearch start

</td>
</tr>
<tr>
<td>

Kibana

</td>
<td>

3.1.0

</td>
<td>

-

</td>
<td>

http://10.10.10.10/kibana

</td>
</tr>
<tr>
<td>

Mongodb

</td>
<td>

2.6.5

</td>
<td>

mongod

</td>
<td>

service mongod start

</td>
</tr>
<tr>
<td>

Apache Web Server

</td>
<td>

2

</td>
<td>

apache

</td>
<td>

service apache2 start

</td>
</tr>
</tbody>
</table>



## **4. Access to the sandbox and other useful commands**



**Useful commands **


*   Start the sandbox

    vagrant up

*   Shut down the sandbox

    vagrant halt

*   In the sandbox, to exit to the host

    exit


**Accessing the sandbox**


1.  Located in /install-folder
2.  **vagrant ssh**

