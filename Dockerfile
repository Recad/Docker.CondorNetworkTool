#Imagen Base
 FROM ubuntu:16.04

#Actualización e instalación 
#traceroute -tcptraceroute
#ping-hping3
#tcpdump-nmap


 RUN apt-get update && apt-get -y install \
 inetutils-traceroute \
 tcptraceroute \
 iputils-ping \
 hping3 \
 tcpdump \
 nmap \
 curl \
 sudo
 
CMD setcap cap_net_raw,cap_net_admin=eip /usr/sbin/hping3
CMD setcap cap_net_raw,cap_net_admin=eip /usr/bin/nmap
 
ADD condornet.sh /usr/bin

CMD chown root /usr/bin/condornet.sh 
CMD chmod u+s /usr/bin/condornet.sh 
