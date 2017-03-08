#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
}

/<DATA_ENTRADA>/ {
	
	dias[$3]++;
}

/<SAIDA>/ {
	
	locais[$3]++;
}

/<IMPORTANCIA>/ {
	gsub(",", ".", $3);
	imp[i++] = $3;
}

/<TAXA_IVA>/ {
	gsub(",", ".", $3);
	ivas[j++] = $3;
}

/<VALOR_DESCONTO>/ {
	gsub(",", ".", $3);
	desc[k++] = $3;
}

/<TIPO>/ {
	gsub(",", ".", $3);
	tipos[l++] = $3;
}

END {
	print "alínea a) - calcular o nº de 'entradas' em cada dia do mês.\n";
	for (i in dias) 
		print i, dias[i];

	print "\nalínea b) - escrever a lista de locais de 'saída'.\n";
	for (i in locais)
		print i;

	print "\nalínea c) - calcula o total gasto no mês.\n";
#	for (i in imp) {
#		x = imp[i] * (ivas[i]/100 + 1) - desc[i];
#		total += x;
#		print imp[i] " -> " ivas[i] " -> " desc[i] " = " x;
#	}

	for (i in imp) {
		total += imp[i];
	}

	print "TOTAL: " total;
}
