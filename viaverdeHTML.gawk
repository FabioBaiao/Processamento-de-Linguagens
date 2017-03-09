#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	file = "queries.html";
	enc = "<meta charset='UTF-8'/>";
	css = "<link rel='stylesheet' type='text/css' href='styles.css'>"
	end = "</body> </html>";
}

/<DATA_ENTRADA>/ {
	
	dias[$3]++;
}

/<SAIDA>/ {
	
	locais[$3]++;
}		

END {
	#print "<!DOCTYPE html>" > file;
	print "<html><head>"enc css"</head> <body>" > file;
	print "<div><img src='logo.jpg'/>" > file;
	print "<h1>Via Verde</h1>" > file;
	print "<h3>Anda consigo.</h3></div>" > file;
	print "<h3>a) - calcular o nº de 'entradas' em cada dia do mês</h3>" > file;
	print "<table><tr><th>Dia</h><th>Entradas</th></tr>" > file;
	for (i in dias){
		print "<tr><td>"i"</td><td>"dias[i]"</td></tr>" > file
	}
	print "</table>" > file;
	print "<h3>b) - escrever a lista de locais de 'saída'</h1>" > file;
	for (i in locais){
		print "<p" enc i "</p>" > file;
	}

	print "<h3>c) calcular o total gasto no mês</h3>" > file;
	print "<h3>d) calcular o total gasto no mês apenas em 'parques'</h3>" > file;
	print end > file;
}
