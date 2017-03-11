#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";
}

# HEADER
NR == 1 {
	
	printCliente();
}

function printCliente(file){
	
	for (i=1; i < NF; i++){
		if ($i ~ /CLIENTE/){
			for (i += 2; $i !~ /CLIENTE/; i+=4){
				gsub("_", " ", $i);
				print $i, $(i+1) > "Cliente.html";
			}
			break;
		}
	}
}