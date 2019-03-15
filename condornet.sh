#!/usr/bin/env bash

##Var definitions
automatic=false
firewall=false
Os='None'
host=0
port=0
interface=0
args=$#
last=${*: -1:1}

## Function definitions

##Funcion para definir SO- Por ahora solo ubuntu
function isUbuntu {
	release=$(cat /etc/*-release | grep "ID_LIKE\|DISTRIB_ID")
	if [[ $release =~ .*ubuntu.* ]] || [[ $release =~ .*debian.* ]]; then
       Os='Ubuntu'
       

	else
        echo "This script only works under Ubuntu or Debian based OS"
        exit
	fi
}

##Funcion para defnir validez de una ip- Se debe cambiar para usar nombres
function isHost {
	if [[  $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] ; then
		host=$1
		
	else
		echo "Invalid Host"
		echo "Usage: condor_net [-a] [-f] [-m] [-s] [-Tp] [-N] [-c] [-i Interface] [-p Port] [-o Name] [-h IP_OUTSIDE]
	Use <command> ? for help
			"
        exit
	fi
}
#Valida cantidad de flags y opciones
function existArguments {
	
	if (( $args <1 )); then
	
		
		echo "No options detected
			Usage: condor_net [-a] [-f] [-m] [-s] [-Tp] [-N] [-c] [-i Interface] [-p Port] [-o Name] [-h IP_OUTSIDE]
			Use <command> ? for help
		"
		exit 
		
	elif (( $args == 1 )) && [[ $last == '?' ]]; then
		echo "
				Usage: condor_net [-a] [-f] [-m] [-s] [-Tp] [-N] [-c] [-i Interface] [-p Port] [-o Name] [-h IP_OUTSIDE]

				-a Automatic	make a report automatically.
				-f Firewall	was configured to run through most firewalls.
				-m Master	runs on a condor master node.
				-s Node		runs on a condor node.        
				-i Interface	define network interface to use for utilities.
				-p Port		specify a port for use of the tools
				-t Test port	try to detect blocked ports in a firewall.
				-N Internet	define if my resource goes directly to the internet.
				-c condor_sub	runs this tool in the entire HTCondor pool as a task.
				-o Outputfile	Name of outputfile.
				-h Ip_outside	Ip outside of network
				


				?              Help
			"
			exit
		
	fi


}
##Funcion para traceroute
# entrada (host port interface)
function traceroute {
	
	
	if [[ $firewall == true ]]; then
			

		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			echo "se corre solo con host"
			
			salida=$(tcptraceroute "$1")
			echo $salida
		fi
		
		
	else
		#echo "holi"
		#if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			
			
		#	salida=$(traceroute "$1")
		#	echo $salida
		#fi
		
		salida=$(traceroute "$1")
		echo $salida
	fi
	

}

function AutomaticMode {
	if [[ $host == 0 ]]; then
		echo 'Introduzca un host:'
		#leer el dato del teclado y guardarlo en la variable de usuario var1
		read var1
		host=$var1
		
	fi
	echo "voy a entrar a traceroute"
	traceroute $host $port $interface
	
}

##Control use
existArguments
isUbuntu

while getopts "afmsNco:i:p:h:" OPTION
do
	case $OPTION in
		
		
		f)
			echo "Firewall mode"
			firewall=true
			;;
		
		a)
			echo "Running in automatic Mode..."
			automatic=true
			
			
			;;
		
		m)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		s)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		i)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		t)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		N)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		c)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		p)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		o)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		h)
			echo ""
			isHost $OPTARG
			
			echo $MYOPTF
			exit
			;;
		\?)
			echo "
				Usage: condor_net [-a] [-f] [-m] [-s] [-Tp] [-N] [-c] [-i Interface] [-p Port] [-o Name] [-h IP_OUTSIDE]

				-a Automatic	make a report automatically.
				-f Firewall	was configured to run through most firewalls.
				-m Master	runs on a condor master node.
				-s Node		runs on a condor node.        
				-i Interface	define network interface to use for utilities.
				-p Port		specify a port for use of the tools
				-t Test port	try to detect blocked ports in a firewall.
				-N Internet	define if my resource goes directly to the internet.
				-c condor_sub	runs this tool in the entire HTCondor pool as a task.
				-o Outputfile	Name of outputfile.
				-h Ip_outside	Ip outside of network.
				
				


				?              Help
			"
			exit
			;;
	esac
	
done


if [[ $automatic == true ]]; then
	
	AutomaticMode
fi

