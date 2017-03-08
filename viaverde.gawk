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

END {
	
	print "alínea a) - calcular o nº de 'entradas' em cada dia do mês.\n";
	for (i in dias) 
		print i, dias[i];

	print "\nalínea b) - escrever a lista de locais de 'saída'.\n";
	for (i in locais)
		print i;
}
