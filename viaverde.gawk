#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	nImp = 0;
	nIvas = 0;
	nDesc = 0;
	nTipos = 0;
}

/<DATA_ENTRADA>/ {
	
	dias[$3]++;
}

/<SAIDA>/ {
	
	locais[$3]++;
}

/<IMPORTANCIA>/ {
	
	gsub(",", ".", $3);
	imp[nImp++] = $3;
}

/<TAXA_IVA>/ {
	
	ivas[nIvas++] = $3;
}

/<VALOR_DESCONTO>/ {
	
	gsub(",", ".", $3);
	desc[nDesc++] = $3;
}

/<TIPO>/ {
	
	tipos[nTipos++] = $3;
}

END {
	
	print "alínea a) - calcular o nº de 'entradas' em cada dia do mês.\n";
	for (i in dias) {
		print i, dias[i];
	}

	print "\nalínea b) - escrever a lista de locais de 'saída'.\n";
	for (i in locais) {
		print i;
	}

	print "\nalínea c) - calcula o total gasto no mês.\n";
	total = 0;
	iva = 0;
	for (i in imp) {
		total += imp[i] * (ivas[i]/100 + 1) - desc[i];
	}
	print total;
	
	print "\nalínea d)\n";
	total = 0;
	for (i in tipos){
		if (tipos[i] ~ /Parque/){
			total += imp[i];
		}
	}
	print total;
}
