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
 curl
 
 

ADD condornet.sh /usr/bin
