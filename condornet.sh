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
salidaTrace=''

## Function definitions



##funcion de error con menu
function errorMess {
	 
	
	echo "				
				$1
	
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
	
	

}

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
		errorMess
			
	fi
}
#Valida cantidad de flags y opciones
function existArguments {
	
	if (( $args <1 )); then
	
		
		
		errorMess "No options detected"
		
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
function tracerouteFull {
	
	
	if [[ $firewall == true ]]; then
			

		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			echo "se corre solo con host"
			
			salidaTrace=$(tcptraceroute "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "con interface y puerto"
			
			salidaTrace=$(tcptraceroute -i "$3" "$1" "$2" )
		
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then
		
			salidaTrace=$(tcptraceroute "$1" -i "$3")
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
			salidaTrace=$(tcptraceroute "$1" "$2")
		else 
			errorMess "error de opciones -i -p"
		fi
		
		
	else
		
		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			
			
			salidaTrace=$(traceroute "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "con interface y puerto"
			
			salidaTrace=$(traceroute "$1" "$2" "$3")
			
		else
			errorMess "error de opciones -i -p"
			
		fi
		
		
	fi
	

}
##Funcion para hacer ping
# entrada (host port interface)
function PingDetection {
	
	if [[ $firewall == true ]]; then
			

		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			echo "se corre solo con host"
			
			salidaPing=$(hping3 "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "con interface y puerto"
			
			salidaTrace=$(hping3 -S -p "$2" -c 6 -I "$3" "$1"  )
		
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then
		##Se debe integrar esta parte con la busqueda de puertos activos
			salidaTrace=$(hping3 -S -p 22 -c 6 -I "$3" "$1"  )
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
		
			salidaTrace=$(hping3 -S -p "$2" -c 6 "$1"  )
		
		else 
			errorMess "error de opciones -i -p"
		fi
		
		
	else
		
		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			
			
			salidaTrace=$(ping -c 6 "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "El ping se realizara sin puerto especifico
				Para hacer ping a un puerto especifico use el flag -f"
			
			salidaTrace=$(ping -c 6  -I "$3" "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
			echo "El ping se realizara sin puerto especifico
				Para hacer ping a un puerto especifico use el flag -f"
			
			salidaTrace=$(ping -c 6  "$1")
			
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then
			
			salidaTrace=$(ping -c 6  -I "$3" "$1")
			
		else
			errorMess "error de opciones -i -p"
			
		fi
		
		
	fi
	



}

function AutomaticMode {
	if [[ $host == 0 ]]; then
		echo 'Introduzca un host:'
		#leer el dato del teclado y guardarlo en la variable de usuario var1
		read var1
		host=$var1
	else 
	
	 echo $host	
	fi
	
	
	tracerouteFull $host $port $interface
	
	#PingDetection $host $port $interface
	
}

##funcion que detecta interfaces y compara si una interfaz 
#ingresada esta en el sistema

function validateinterfaces {
	
	validinterfaces=$(ls /sys/class/net)
	
	if echo $validinterfaces | grep -w $1 ; then
	  interface=$1
	 else 
		echo "interfaces validas:"
		echo $validinterfaces
		errorMess "Interface de red no valida"
		
		
	 
	fi
	
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
			#echo "The value of -f is $OPTARG"
			
			#echo $interface
			validateinterfaces $OPTARG
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
			#echo "The value of -f is $OPTARG"
			
			
			if [[ $OPTARG > 0 ]] && [[ $OPTARG < 65535 ]]; then 
				port=$OPTARG
				
			else 		
				errorMess "No es un puerto valido: "$OPTARG
			fi
			
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
	
else 
 #se debe verificar el host pendiente
	tracerouteFull $host $port $interface

fi

