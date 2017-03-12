#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";

	total = 0;
	semIvaTotal = 0;
	ivaTotal = 0;
}

# HEADER
NR == 1 {
	extrato = getMesEmissao();
	printCliente();
	printExtrato();
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
	desc = getValueOf("VALOR_DESCONTO");
	if (imp != null && desc != null){
		gsub(",", ".", imp);
		total += imp - desc;
	}

	# alínea d)
	if (tipo != null && imp != null)
		tipos[tipo] += imp;

	# calcular iva e valor sem iva
	ivaPerc = getValueOf("TAXA_IVA");
	if (ivaPerc != null && imp != null){
		semIva = imp / (1 + ivaPerc/100);

		semIvaTotal += semIva;
		ivaTotal += semIva * (ivaPerc/100);
	}


	entrada = getValueOf("ENTRADA");
	if (tipo != null && entrada != null){
		entradas[tipo][entrada]++;
	}

	# gasto diário
	if (tipo != null && data != null && data != "null"){
		invData = inverter(data);
		gastoD[invData][tipo] += imp - desc;
	}
}


END {
	printA();
	printB();
	printCD();
	printEntradas();
	printGastoD();
}

function inverter (data){
	split(data, campos, "-");
	return campos[3] "-" campos[2] "-" campos[1];
}

function getValueOf (tag){
	
	for (i=2; i < NF; i+=4){
		if ($i == tag)
			return $(i+1);
	}
	return null;
}

function getMesEmissao(){
	
	for (i=1; i < NF; i++){
		if ($i == "MES_EMISSAO")
			return $(i+1)
	}
}

#args: name_of_file, section active (1 - Consultar, 2 - Perfil)
function printHeader(file, active){
	enc = "<meta charset='UTF-8'/>";
	css = "<link rel='stylesheet' type='text/css' href='styles.css'>";
	fmt = "<li><a href='%s'> %s </a></li>\n";
	menu_active = "<li><a href='%s' class='active'> %s </a></li>";
	print "<html><head>" enc css "</head><body>" > file;
	print "<ul class='topmenu'>" > file;
	switch (active){
		case 1:	printf(menu_active, extrato ".html", "Consultar") > file;
				printf(fmt, "Cliente.html", "Perfil") > file;
				break;
		case 2:	printf(fmt, extrato ".html", "Consultar") > file;
				printf(menu_active, "Cliente.html", "Perfil") > file;
				break;
		default: break;
	}
	print "</ul>" > file;
}

function printFooter(file){
	footer_fmt = "<div class='footer'> %s </div>";
	end = "</body></html>";
	printf(footer_fmt, "<img src='logo.png'/><h1>Via Verde</h1><h3>Parar para quê?</h3>") > file;
	print end > file;

}

function printExtrato(){
	file = extrato ".html";
	printHeader(file, 1);
	printSideMenu(file, 0);
	print "<div class='column content'><div class='header'><h1></h1></div></div>" > file;
	print "</div>" > file;
	printFooter(file);
}

function printSideMenu(file, active){
	print "<div class='clearfix'><div class='column sidemenu'><ul>" > file;
    switch (active) {
    	case 1: printf(menu_active, "Ago-2015-numeroEntradas.html", "Número de Entradas") > file;
    			printf(fmt, "Ago-2015-entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Ago-2015-saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Ago-2015-gastoM.html", "Gasto Mensal") > file;
				printf(fmt, "Ago-2015-gastoD.html", "Gasto Diário") > file;
    			break;
    	case 2:	printf(fmt, "Ago-2015-numeroEntradas.html", "Número de Entradas") > file;
    			printf(menu_active, "Ago-2015-entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Ago-2015-saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Ago-2015-gastoM.html", "Gasto Mensal") > file;
				printf(fmt, "Ago-2015-gastoD.html", "Gasto Diário") > file;
    			break;
    	case 3: printf(fmt, "Ago-2015-numeroEntradas.html", "Número de Entradas") > file;
    			printf(fmt, "Ago-2015-entradas.html", "Locais de Entrada") > file;
  				printf(menu_active, "Ago-2015-saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Ago-2015-gastoM.html", "Gasto Mensal") > file;
				printf(fmt, "Ago-2015-gastoD.html", "Gasto Diário") > file;
    			break;
    	case 4: printf(fmt, "Ago-2015-numeroEntradas.html", "Número de Entradas") > file;
    			printf(fmt, "Ago-2015-entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Ago-2015-saidas.html", "Locais de Saída") > file;
  				printf(menu_active, "Ago-2015-gastoM.html", "Gasto Mensal") > file;
				printf(fmt, "Ago-2015-gastoD.html", "Gasto Diário") > file;
    			break;
    	case 5:	printf(fmt, "Ago-2015-numeroEntradas.html", "Número de Entradas") > file;
    			printf(fmt, "Ago-2015-entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Ago-2015-saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Ago-2015-gastoM.html", "Gasto Mensal") > file;
				printf(menu_active, "Ago-2015-gastoD.html", "Gasto Diário") > file;
    			break;
    	default:printf(fmt, "Ago-2015-numeroEntradas.html", "Número de Entradas") > file;
    			printf(fmt, "Ago-2015-entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Ago-2015-saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Ago-2015-gastoM.html", "Gasto Mensal") > file;
				printf(fmt, "Ago-2015-gastoD.html", "Gasto Diário") > file; 
    			break;
    }
    print "</ul></div>" > file;
}


function printA(){
	file = extrato "-numeroEntradas.html";
	printHeader(file, 1);
	printSideMenu(file, 1);
	print "<div class='column content'><div class='header'><h4 style='color:#008CBA'> Número de entradas em cada dia, nos vários tipos de serviço disponibilizados pela Via Verde </h4></div>" > file;
	print "<table style='width:30%; margin-left:200px'>" > file;
	for (i in nEntradas){
		print "<tr><th style='text-align:center'>" i "</th></tr>" > file;
		n = asorti(nEntradas[i], ordenado);
		for (j=1; j <= n; j++){
			data = ordenado[j];
			print "<tr><td style='text-align:center'>" inverter(data) "</td><td>" nEntradas[i][data] "</td></tr>\n" > file;
		}
	}
	print "</table></div></div>" > file;
	printFooter(file);
}


function printEntradas(){
	file = extrato "-entradas.html";
	printHeader(file, 1);
	printSideMenu(file, 2);
	print "<div class='column content'><div class='header'><h4 style='color:#008CBA'> Locais de entrada e respetivo número de visitas, nos vários tipos de serviço disponibilizados pela Via Verde </h4></div>" > file;
	print "<table style='width:30%; margin-left:200px'>" > file;
	for (i in entradas){
		print "<tr><th style='text-align:center'>" i "</th></tr>" > file;
		n = asort(entradas[i], ordenado);	
		for (j=n; j > 0; j--){
			numeroSaidas = ordenado[j];
			for (k in entradas[i]){
				if (entradas[i][k] == numeroSaidas){
					ref = "https://www.google.pt/maps/place/" k "+Portugal";
					print "<tr><td>" k "<a href='" ref "'><img class='maps' src='google_maps.png'/></a></td><td>" numeroSaidas "</td></tr>\n" > file;
					delete entradas[i][k];
				}
			}
		}
	}
	print "</table></div></div>" > file;
	printFooter(file);
}

function printB(){
	file = extrato "-saidas.html";
	printHeader(file, 1);
	printSideMenu(file, 3);
	print "<div class='column content'><div class='header'><h4 style='color:#008CBA'> Locais de saída e respetivo número de visitas, nos vários tipos de serviço disponibilizados pela Via Verde </h4></div>" > file;
	print "<table style='width:30%; margin-left:200px'>" > file;
	for (i in saidas){
		print "<tr><th style='text-align:center'>" i "</th></tr>" > file;
		n = asort(saidas[i], ordenado);	
		for (j=n; j > 0; j--){
			numeroSaidas = ordenado[j];
			for (k in saidas[i]){
				if (saidas[i][k] == numeroSaidas){
					ref = "https://www.google.pt/maps/place/" k "+Portugal";
					print "<tr><td>" k "<a href='" ref "'><img class='maps' src='google_maps.png'/></a></td><td>" numeroSaidas "</td></tr>\n" > file;
					delete saidas[i][k];
				}
			}
		}
	}
	print "</table></div></div>" > file;
	printFooter(file);
}


function printCD(){
	file = extrato "-gastoM.html";
	printHeader(file, 1);
	printSideMenu(file, 4);
	print "<div class='column content'><div class='header'><h4 style='color:#008CBA'> Gasto mensal nos vários tipos de serviço disponibilizados pela Via Verde </h4></div>" > file;
	print "<table style='width:50%; margin-left:200px'>" > file;
	print "<tr><th style='text-align:center'> Serviço </th><th> Montante </th></tr>" > file;
	n = asort(tipos, ordenado);
	for (i=n; i > 0; i--){
		valor = ordenado[i];
		for (j in tipos){
			if (tipos[j] == valor){
				print "<tr><td style='text-align:center'>" j "</td><td>" valor"€" "</td></tr>\n" > file;
				delete tipos[j];
			}
		}
	}
	values = "<tr><th style='text-align:center'> %s </th><td> %.2f€ </td></tr>\n";
	printf (values, "Total sem IVA", semIvaTotal) > file;
	printf (values, "IVA", ivaTotal) > file;
	printf (values, "TOTAL", total) > file;
	print "</table></div></div>" > file;
	printFooter(file); 
}


function printCliente(){
	file = "Cliente.html";
	printHeader(file, 2);
	print "<div class='avatar'><img src='profile.png' style='margin-right: 50px'/>" > file;
	print "<table>" > file;
	for (i=1; i < NF; i++){
		if ($i ~ /CLIENTE/){
			for (i += 2; $i !~ /CLIENTE/; i+=4){
				gsub("_", " ", $i);
				print "<tr><th style='text-align:left'>"$i"</th><td style='text-align:left'>"$(i+1)"</td></tr>" > file;
			}
			break;
		}
	}
	print "</table></div>" > file;
	printFooter(file);	
}


function printGastoD(){
	file = extrato "-gastoD.html";
	printHeader(file, 1);
	printSideMenu(file, 5);
	print "<div class='column content'><div class='header'><h4 style='color:#008CBA'> Gasto diário nos vários tipos de serviço disponibilizados pela Via Verde </h4></div>" > file;
	print "<table style='width:50%; margin-left:200px'>" > file;
	print "<tr><th> Dia </th><th> Serviço </th><th> Montante </th></tr>" > file;
	n = asorti(gastoD, ordenado);
	for (j=1; j <= n; j++){
		data = ordenado[j];
		for (k in gastoD[data]){
				print "<tr><td>" inverter(data) "</td><td>" k "</td><td>" gastoD[data][k]"€" "</td></tr>\n" > file;
				delete gastoD[i][k];
		}
	}
	print "</table></div></div>" > file;
	printFooter(file); 
}