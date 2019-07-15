#!/usr/bin/env bash

##Var definitions
automatic=false
firewall=false
netmode=false
portmode=false
listFirewall=false
Os='None'
host=0
port=0
interface=0
args=$#
last=${*: -1:1}
#salidaTrace=''
#portExit=''
fileName='info.txt'

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
				-l List_firewall	Search firewalls in a route.
				


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

##Funcion para defnir validez de una ip
function isHost {
	
	hostresult=$(getent hosts "$1")
	
	if [[ $? == 0 ]] ; then
		
		host=$1
		##echo $host
		$(echo "El host es: $host" >> "$fileName")
		$(echo " " >> "$fileName")
		
	else
		echo "Invalid Host"
		errorMess
			
	fi
}



##FUncion que valida la existencia del software requerido y lo instala
function toolValidator {
	
	DRUSH_VERSION="$(traceroute --version)"
	
	
	
	if [[ $? != 0 ]]; then
		echo "Drush is installed"
	else
		echo "$(sudo apt-get install traceroute)"
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
				-h Ip_outside	Ip outside of network.
				-l List_firewall	Search firewalls in a route.
				


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
		
			
			salidaTrace=$(tcptraceroute "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "con interface y puerto"
			
			salidaTrace=$(tcptraceroute -i "$3" "$1" "$2" )
		
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then 
		
			salidaTrace=$(tcptraceroute -i "$3" "$1" )
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
			salidaTrace=$(tcptraceroute "$1" "$2" )
		else 
			errorMess "error de opciones -i -p"
		fi
		
		
	else
		
		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			
			
			salidaTrace=$(traceroute "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "con interface y puerto"
			
			salidaTrace=$(traceroute -i "$3" -p "$2" "$1"  )
			
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then 
		
			salidaTrace=$(traceroute -i "$3" "$1"  )
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
			
			salidaTrace=$(traceroute -p "$2" "$1"  )
		 
		else
			errorMess "error de opciones -i -p"
			
		fi
		
		
	fi
	$(echo "###################################################################" >> "$fileName")
	$(echo "Ruta tomada:" >> "$fileName")
	$(echo " " >> "$fileName")
	$(echo "$salidaTrace" >> "$fileName")
	$(echo " " >> "$fileName")
}
##Funcion para hacer ping
# entrada (host port interface)
function PingDetection {
	
	if [[ $firewall == true ]]; then
			

		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			
			
			salidaPing=$(sudo hping3 -S -p 22 -c 5 "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "con interface y puerto"
			
			salidaPing=$(sudo hping3 -S -p "$2" -c 5 -I "$3" "$1"  )
		
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then
		##Se debe integrar esta parte con la busqueda de puertos activos
			salidaPing=$(sudo hping3 -S -p 22 -c 5 -I "$3" "$1"  )
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
		
			salidaPing=$(sudo hping3 -S  -p "$2" -c 5 "$1" )
		
		else 
			errorMess "error de opciones -i -p"
		fi
		
		
	else
		
		if [[ $2 == 0 ]] && [[ $3 == 0 ]]; then
			
			
			salidaPing=$(ping -c 5  -q "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 != 0 ]]; then
			echo "El ping se realizara sin puerto especifico
				Para hacer ping a un puerto especifico use el flag -p"
			
			salidaPing=$(ping -c 5 -q -p "$2" -I "$3" "$1")
			
		elif [[ $2 != 0 ]] && [[ $3 == 0 ]]; then
			
			
			salidaPing=$(ping -c 5 -q -p "$2" "$1")
			
		elif [[ $2 == 0 ]] && [[ $3 != 0 ]]; then
			
			salidaPing=$(ping -c 5 -q -I "$3" "$1")
			
		else
			errorMess "error de opciones -i -p"
			
		fi
		
		
	fi
	
	if [[ $? == 0 ]] ; then
		$(echo "###################################################################" >> "$fileName")
		$(echo "Resultado de hacer ping:" >> "$fileName")
		$(echo " " >> "$fileName")
		$(echo "$salidaPing" >> "$fileName")		
		$(echo " " >> "$fileName")
		
	else
		$(echo "###################################################################" >> "$fileName")
		$(echo "Resultado de hacer ping: $?" >> "$fileName")
		$(echo " " >> "$fileName")
		$(echo "No se pudo realizar el ping" >> "$fileName")
		$(echo " " >> "$fileName")
	fi
	
	


}

##Funcion encargada de realizar la extraccion de hosts
##toca incorporarla con la funcion de traceroute

function tracehost {
	
	
	portOutputSave=$( tcptraceroute -n "$host" | awk '{print $2}' |   sed -e 's/*//g' | uniq -u)
	
	declare -a directions=($portOutputSave)
	#echo "array"
	#echo ${directions[*]}
	#echo ${#directions[*]}
	for i in ${directions[@]}
	
	do
        
        if [[ $(nmap   -T4 "$i" | grep  "filtered ports")  ]]; then
		
			
			$(echo "la ruta "$i" se encuentra detras de politicas de filtrado (Firewall)" >> "$fileName")
			$(echo " " >> "$fileName")
						
		fi
      
	
	done
}




##Funcion encargada de escanear el puerto remoto de condor y determinar si el servicio arranca 
function portScan {
	
	
	
	portOrigin=$(nmap   -T4 "$1")
	
	if [[ $? != 0 ]]; then
		echo "Command failed."
		
	elif [[ $portOrigin ]]; then
	
		
		
		if [[ $(echo "$portOrigin" | grep  "filtered ports") ]]; then
		
			
			$(echo "El host se encuentra detras de politicas de filtrado (Firewall)" >> "$fileName")
			$(echo " " >> "$fileName")
						
		fi
	
		portOutput=$(echo "$portOrigin" | grep condor | cut -d ' ' -f1 | cut -d '/' -f1 )
		
		if [[ $portOutput ]]; then
				
			
			$(echo "Se ha encontrado condor corriendo en el puerto: $portOutput" >> "$fileName")
			$(echo "Recuerde que HTCondor utiliza el puerto 9618 por defecto para el Daemon condor_collector " >> "$fileName")
			$(echo " " >> "$fileName")
			
		else
			
			$(echo "No se ha detectado condor_collector o algun servicio de condor en la direccion especificada   " >> "$fileName")
			$(echo " " >> "$fileName")
		
		fi
	
	
		portsave=$(echo "$portOrigin" | grep  /)
	
		$(echo "$portsave" >> "puertosde-$1.txt")
	
		
	else
		$(echo "No se pudieron analizar los puertos" >> "$fileName")
		$(echo " " >> "$fileName")
	fi
  
		
	
	
}



##funcion de putdate para poner la fecha en el log

function putDate {
	
	DATE=`date '+%Y-%m-%d %H:%M:%S'`
	
	$(echo "###################################################################-----------------------------------------------------------" >> "$fileName")
	$(echo "FECHA: $DATE" >> "$fileName")
	$(echo "###################################################################" >> "$fileName")
	$(echo "   " >> "$fileName")
	
}

##Funcion encargada del modo automatico
function AutomaticMode {
	if [[ $host == 0 ]]; then
		echo 'Introduzca un host:'
		#leer el dato del teclado y guardarlo en la variable de usuario var1
		read var1
		
		isHost $var1
		#host=$var1
	
	fi
	
	
	curlmachine 
	#tracehost $host
	
	portScan $host
	
	tracerouteFull $host $port $interface
	
	PingDetection $host $port $interface
	
	tracehost
	
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

##funcion que hace curl a la api para saber la ip por la que se sale
#a internet
function curlmachine {
	
	hostname=$(hostname)
	direccion=$(curl  https://api.ipify.org?format=json )
	
	
	$(echo "La ip de salida es: $direccion" >> "$fileName")
	$(echo " " >> "$fileName")

}



##Control use
existArguments
isUbuntu

##control de flags
while getopts "afmltsNco:i:p:h:" OPTION
do
	case $OPTION in
		
		
		f)
			echo "Firewall mode"
			firewall=true
			;;
		
		o)
			#echo "The value of -f is $OPTARG"
			fileName=$OPTARG
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
			echo "Text port"
			portmode=true
			
			;;
		N)
			echo "se lanza en modo a internet"
			netmode=true
			
			##curlmachine 
			;;
		c)
			echo "The value of -f is $OPTARG"
			MYOPTF=$OPTARG
			echo $MYOPTF
			exit
			;;
		p)
			#echo "The value of -f is $OPTARG"
			
			
			if (( $OPTARG > 0  && $OPTARG < 65535 )); then 
				
				port=$OPTARG
				
			else 		
				errorMess "No es un puerto valido: "$OPTARG
			fi
			
			;;
		
		h)
			echo ""
			isHost $OPTARG
			
			
			;;
		l)
			
			listFirewall=true
			
			
			
			;;
		\?)
			echo "
				Usage: condor_net [-a] [-f] [-m] [-s] [-t] [-N] [-c] [-i Interface] [-p Port] [-o Name] [-h IP_OUTSIDE]

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
				-l List_firewall	Search firewalls in a route.
				
				


				?              Help
			"
			exit
			;;
	esac
	
done


if [[ $automatic == true ]]; then
	putDate
	AutomaticMode
	#echo $portExit
else 
	putDate
	if [[ $netmode == true ]]; then
		curlmachine
	
	fi 
	
	
	if  [[ $portmode == true ]]; then
		portScan $host
		
	fi
	
	if [[ $listFirewall == true ]]; then
		tracehost
	fi
 
fi

