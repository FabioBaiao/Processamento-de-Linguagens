#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";
}

# HEADER
NR == 1 {
	
	file = getValueOf("MES_EMISSAO") ".html";
}

NR > 1 {
	
	data = getValueOf("DATA_ENTRADA");
	if (data != null && data != "null"){
		inv = inverter(data);
		entradas[inv]++;
	}
}

END {
	
	asorti(entradas, ordenado);
	for (i in ordenado){
		data = ordenado[i];
		print inverter(data), entradas[data];

	}
}


function inverter (data){
	split(data, campos, "-");
	return campos[3] "-" campos[2] "-" campos[1];
}

function getValueOf (tag){
	
	for (i=1; i < NF; i++){
		if ($i == tag)
			return $(i+1);
	}
	return null;
}