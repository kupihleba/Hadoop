#!/bin/bash

# Note that SSH should be configured

# Remember 
# $ chmod +x make_lab1.sh

set -e;

# env -i /bin/bash

if [ "${UID}" -eq 0 ]
then
    echo "Oh, don't run it as root!";
    exit 1;
fi

if [ -d lab1 ]; then
	echo "Preparing your lab...";
else
	echo "lab1 folder should be located near the script!";
	exit 1;
fi
if [ -d configs ]; then
	echo "Preparing your lab...";
else
	echo "lab1 folder should be located near the script!";
	exit 1;
fi

# Installation dirs:
JAVA_JDK=~;
MVN=~;
HADOOP=~;

echo "Unpacking Java JDK [...]";
cp lab1/jdk-8u181-linux-x64.tar.gz $JAVA_JDK;
tar xf $JAVA_JDK/jdk-8u181-linux-x64.tar.gz;
rm $JAVA_JDK/jdk-8u181-linux-x64.tar.gz;
echo "Unpacking Java JDK [DONE]";

echo "Unpacking Maven [...]";
cp lab1/apache-maven-3.3.3-bin.tar.gz $MVN;
tar xf $MVN/apache-maven-3.3.3-bin.tar.gz;
rm $MVN/apache-maven-3.3.3-bin.tar.gz;
echo "Unpacking Maven [DONE]";

echo "Exporting environment variables";
echo "export JAVA_HOME=$JAVA_JDK/jdk1.8.0_181;" >> ~/.bashrc;
echo "export MAVEN_HOME=$MVN/apache-maven-3.3.3;" >> ~/.bashrc;
echo 'export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH;' >> ~/.bashrc;

source .bashrc;

java -version;
mvn -v;

echo "Unpacking Hadoop [...]";
cp lab1/hadoop-2.9.1.tar.gz $HADOOP;
tar xf $HADOOP/hadoop-2.9.1.tar.gz;
rm $HADOOP/hadoop-2.9.1.tar.gz;
echo "Unpacking Hadoop [DONE]";

echo "Writing Hadoop environment variables";
echo "export HADOOP_INSTALL=$HADOOP/hadoop-2.9.1;" >> ~/.bashrc;
echo 'export HADOOP_PREFIX=$HADOOP_INSTALL;' >> ~/.bashrc;
echo 'export PATH=$PATH:$HADOOP_INSTALL/bin;' >> ~/.bashrc;
echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin;' >> ~/.bashrc;
echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL;' >> ~/.bashrc;
echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL;' >> ~/.bashrc;
echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL;' >> ~/.bashrc;
echo 'export YARN_HOME=$HADOOP_INSTALL;' >> ~/.bashrc;
echo 'export HADOOP_CONF_DIR=$HADOOP_INSTALL/etc/hadoop;' >> ~/.bashrc;
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native;' >> ~/.bashrc;
echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib";' >> ~/.bashrc;

source ~/.bashrc;

echo "Copying configuration files";
\cp configs/yarn-site.xml $HADOOP/hadoop-2.9.1/etc/hadoop/;
\cp configs/mapred-site.xml $HADOOP/hadoop-2.9.1/etc/hadoop/;
\cp configs/core-site.xml $HADOOP/hadoop-2.9.1/etc/hadoop/;
\cp configs/hdfs-site.xml $HADOOP/hadoop-2.9.1/etc/hadoop/;
\cp configs/hadoop-env.sh $HADOOP/hadoop-2.9.1/etc/hadoop/;

mkdir ~/mydata;
mkdir ~/mydata/namenode;
mkdir ~/mydata/datanode;

CMD='s/MY_USERNAME/'$(whoami)'/g';
sed -i $CMD $HADOOP/hadoop-2.9.1/etc/hadoop/hdfs-site.xml;

CMD='s,MY_JAVA_HOME_HERE,'$JAVA_JDK/jdk1.8.0_181',g';
sed -i $CMD $HADOOP/hadoop-2.9.1/etc/hadoop/hadoop-env.sh;

hdfs namenode -format;
read -p "> start-dfs - Press enter to continue";
start-dfs.sh;
read -p "> start-yarn - Press enter to continue";
start-yarn.sh;
read -p "> check hadoop - Press enter to continue";

echo "Checking Hadoop";
hadoop jar $HADOOP/hadoop-2.9.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.9.1.jar pi 2 5;

read -r -p "Stop hadoop services? [y/n] " response
case "$response" in
    [yY][eE][sS]|[yY])
        stop-yarn.sh;
	stop-dfs.sh;
	;;
    *)
	    ;;
esac
