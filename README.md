# CondorNetworkTool


Diagnostic tool for networks focused on the use of htcondor flocking

requirements:

- net-tools
- traceroute 
- tcptraceroute 
- iputils-ping 
- hping3 
- tcpdump 
- nmap



or can use container recad/condornetworktool
```
docker pull recad/condornetworktool
```
With this command

```
docker run --rm -v $PWD:/home/ -w /home/ recad/condornetworktool /bin/bash condornet.sh -a -f -h "IP or Name"
```

## Usage 

	condor_net [-a] [-f] [-m] [-s] [-Tp] [-N] [-c] [-i Interface] [-p Port] [-o Name] [-h IP_OUTSIDE]

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

