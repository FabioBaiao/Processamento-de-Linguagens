#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";

	total = 0;
}

# HEADER
NR == 1 {
	
	file = getValueOf("MES_EMISSAO") ".html";
}

NR > 1 {
	
	# alínea a)
	tipo = getValueOf("TIPO");
	data = getValueOf("DATA_ENTRADA");
	if (tipo != null && data != null && data != "null"){
		invData = inverter(data);
		nEntradas[tipo][invData]++;
	}

	# alínea b)
	saida = getValueOf("SAIDA");
	if (tipo != null && saida != null){
		saidas[tipo][saida]++;
	}

	# alínea c)
	imp = getValueOf("IMPORTANCIA");
	if (imp != null){
		gsub(",", ".", imp);
		total += imp;
	}

	# alínea d)
	if (tipo != null && imp != null)
		tipos[tipo] += imp;
}

END {
	
	# alínea a)
	for (i in nEntradas){
		print i;
		n = asorti(nEntradas[i], ordenado);
		for (j=1; j < n; j++){
			data = ordenado[j];
			print inverter(data), nEntradas[i][data];
		}
	}

	# alinea b)
	for (i in saidas){
		print i;
		n = asort(saidas[i], ordenado);
		for (j=n; j > 0; j--){
			nSaidas = ordenado[j];
			for (k in saidas[i]){
				if (saidas[i][k] == nSaidas){
					print k, nSaidas;
					delete saidas[i][k];
				}
			}
		}
	}

	# alínea c)
	print total;

	# alínea d)
	n = asort(tipos, ordenado);
	for (i=n; i > 0; i--){
		valor = ordenado[i];
		for (j in tipos){
			if (tipos[j] == valor){
				print j, valor;
				delete tipos[j];
			}
		}
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
