#!/usr/bin/gawk -f

BEGIN {
	FS = "[<>]";
	enc = "<html> <head> <meta charset='UTF-8'/> </head> <body>"
	end = "</body> </html>"
}

{
	if ($2 == "IMPORTANCIA")
		importancias[i++] = $3;
	if ($2 == "TAXA_IVA")
		ivas[j++] = $3;
	if ($2 == "VALOR_DESCONTO")
		descontos[k++] = $3;
	if ($2 == "TIPO")
		tipos[l++] = $3;
}

END {
	for(i in importancias) {
		x = importancias[i];
		price += x;	
		print importancias[i] "->" ivas[i] "->" descontos[i] "->" x;
	}
	print price;
}



#grep "DATA_ENTRADA" viaverde.xml | gawk -F "[<>]" '{a[$3]++} END {for (i in a) print i, a[i]}'

#grep "<SAIDA>" viaverde.xml | gawk -F "[<>]" '{print $3}'| sort -u
