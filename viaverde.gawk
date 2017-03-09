#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	nDias = 0;
	nImp = 0;
	nIvas = 0;
	nDesc = 0;
	nTipos = 0;
}

/<DATA_ENTRADA>/ {
	
	if ($3 != "null") {
		dias[$3]++;
		porDia[nDias++] = $3;
	}
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
	print "Data \t\t Nº de entradas"

	for (i in dias) {
		print i "\t\t" dias[i];
	}

	print "\nalínea b) - escrever a lista de locais de 'saída'.\n";
	print "Local \t\t Nº de saídas"
	for (i in locais) {
		print i "\t\t" locais[i];
	}

	print "\nalínea c) - calcula o total gasto no mês.\n";
	total = 0;
	iva = 0;
	for (i in imp) {
		total += imp[i] * (ivas[i]/100 + 1) - desc[i];
	}
	print total;
	
	print "\nalínea d) - Calcular o total gasto no mês em 'parques' e em 'portagens'.\n";
	totalP = 0;
	totalPt = 0;
	for (i in tipos){
		if (tipos[i] ~ /Parque/){
			totalP += imp[i];
		}
		if (tipos[i] ~ /Portagens/){
			totalPt += imp[i];
		}
	}
	print "Total gasto em parques: " totalP;
	print "Total gasto em portagens: " totalPt;

	print "\nalínea e) - Total gasto por dia.\n";
	print "Data \t\t Total gasto\n";
	for (i in porDia) {
		totais[porDia[i]] += imp[i];
	}
	for (i in totais)
		print i "\t\t" totais[i];
}
