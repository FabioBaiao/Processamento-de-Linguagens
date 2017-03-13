#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";

	total = 0;
	semIvaTotal = 0;
	ivaTotal = 0;

	fmt = "<li><a href='%s'> %s </a></li>\n";
	menu_active = "<li><a href='%s' class='active'> %s </a></li>";
	title = "<div class='column content'><div class='header'><h4 style='color:#008CBA'> %s </h4></div>";
}

# HEADER
NR == 1 {
	extrato = getMesEmissao();

	system("mkdir -p " extrato);

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

	# debitos
	dataDebito = getValueOf("DATA_DEBITO");
	if (dataDebito != null && imp != null){
		invData = inverter(dataDebito);
		debitos[invData] += imp;
	}
}


END {
	printA();
	printB();
	printCD();
	printEntradas();
	printGastoD();
	printDebitos();
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

#args: name_of_file, section active (1 - Consultar, 2 - Perfil, 3 - Queries)
function printHeader(file, active){
	enc = "<meta charset='UTF-8'/>";
	css = "<link rel='stylesheet' type='text/css' href='%s'>"
	header = "<html><head>" enc css "</head><body>"
	switch (active){
		case 1:
		case 2:	printf (header, "lib/styles.css") > file;
				break;
		case 3:	printf (header, "../lib/styles.css") > file;
				break;
	}
	print "<ul class='topmenu'>" > file;
	switch (active){
		case 1:	printf(menu_active, extrato ".html", "Consultar") > file;
				printf(fmt, "Cliente.html", "Perfil") > file;
				break;
		case 2:	printf(fmt, extrato ".html", "Consultar") > file;
				printf(menu_active, "Cliente.html", "Perfil") > file;
				break;
		case 3:	printf(menu_active, "../" extrato ".html", "Consultar") > file;
				printf(fmt, "../Cliente.html", "Perfil") > file;
				break;
		default: break;
	}
	print "</ul>" > file;
}

function printFooter(file, active){
	footer_fmt = "<div class='footer'> <a target='_blank' href='http://www.viaverde.pt'><img src='%s'/></a>";
	switch (active){
		case 1:
		case 2:	printf(footer_fmt, "lib/logo.png") > file;
				break;
		case 3:	printf(footer_fmt, "../lib/logo.png") > file;
	}
	print "<h1>Via Verde</h1><h3>Parar para quê?</h3> </div></body></html>" > file;
}

function printExtrato(){
	file = extrato ".html";
	printHeader(file, 1);
	printSideMenu(file, 0);
	print "<div class='column content'><div class='header'><h1></h1></div></div>" > file;
	print "</div>" > file;
	printFooter(file, 1);
}

function printSideMenu(file, active){
	print "<div class='clearfix'><div class='column sidemenu'><ul>" > file;
    switch (active) {
    	case 1: printf(menu_active, "Numero-Entradas.html", "Número de Entradas") > file;
    			printf(fmt, "Entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(fmt, "Gastos-Diarios.html", "Gasto Diário") > file;
				printf(fmt, "Debitos.html", "Débito Diário") > file;
    			break;
    	case 2:	printf(fmt, "Numero-Entradas.html", "Número de Entradas") > file;
    			printf(menu_active, "Entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(fmt, "Gastos-Diarios.html", "Gasto Diário") > file;
				printf(fmt, "Debitos.html", "Débito Diário") > file;
    			break;
    	case 3: printf(fmt, "Numero-Entradas.html", "Número de Entradas") > file;
    			printf(fmt, "Entradas.html", "Locais de Entrada") > file;
  				printf(menu_active, "Saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(fmt, "Gastos-Diarios.html", "Gasto Diário") > file;
				printf(fmt, "Debitos.html", "Débito Diário") > file;
    			break;
    	case 4: printf(fmt, "Numero-Entradas.html", "Número de Entradas") > file;
    			printf(fmt, "Entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Saidas.html", "Locais de Saída") > file;
  				printf(menu_active, "Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(fmt, "Gastos-Diarios.html", "Gasto Diário") > file;
				printf(fmt, "Debitos.html", "Débito Diário") > file;
    			break;
    	case 5:	printf(fmt, "Numero-Entradas.html", "Número de Entradas") > file;
    			printf(fmt, "Entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(menu_active, "Gastos-Diarios.html", "Gasto Diário") > file;
				printf(fmt, "Debitos.html", "Débito Diário") > file;
    			break;
    	case 6:	printf(fmt, "Numero-Entradas.html", "Número de Entradas") > file;
    			printf(fmt, "Entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(fmt, "Gastos-Diarios.html", "Gasto Diário") > file; 
				printf(menu_active, "Debitos.html", "Débito Diário") > file;
    			break;
    	default:printf(fmt, "Ago-2015/Numero-Entradas.html", "Número de Entradas") > file;
    			printf(fmt, "Ago-2015/Entradas.html", "Locais de Entrada") > file;
  				printf(fmt, "Ago-2015/Saidas.html", "Locais de Saída") > file;
  				printf(fmt, "Ago-2015/Gastos-Mensais.html", "Gasto Mensal") > file;
				printf(fmt, "Ago-2015/Gastos-Diarios.html", "Gasto Diário") > file; 
				printf(fmt, "Ago-2015/Debitos.html", "Débito Diário") > file;
    			break;

    }
    print "</ul></div>" > file;
}


function printA(){
	file = extrato "/Numero-Entradas.html";
	printHeader(file, 3);
	printSideMenu(file, 1);
	printf(title, "Número de entradas em cada dia, nos vários tipos de serviço disponibilizados pela Via Verde") > file;
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
	printFooter(file, 3);
}


function printEntradas(){
	file = extrato "/Entradas.html";
	printHeader(file, 3);
	printSideMenu(file, 2);
	printf (title, "Locais de entrada e respetivo número de visitas, nos vários tipos de serviço disponibilizados pela Via Verde") > file;
	print "<table style='width:30%; margin-left:200px'>" > file;
	for (i in entradas){
		print "<tr><th style='text-align:center'>" i "</th></tr>" > file;
		n = asort(entradas[i], ordenado);	
		for (j=n; j > 0; j--){
			numeroEntradas = ordenado[j];
			for (k in entradas[i]){
				if (entradas[i][k] == numeroEntradas){
					ref = "https://www.google.pt/maps/place/" k "+Portugal";
					print "<tr><td>" k "<a target='_blank' href='" ref "'><img class='maps' src='../lib/google_maps.png'/></a></td><td>" numeroEntradas "</td></tr>\n" > file;
					delete entradas[i][k];
				}
			}
		}
	}
	print "</table></div></div>" > file;
	printFooter(file, 3);
}

function printB(){
	file = extrato "/Saidas.html";
	printHeader(file, 3);
	printSideMenu(file, 3);
	printf (title, "Locais de saída e respetivo número de visitas, nos vários tipos de serviço disponibilizados pela Via Verde") > file;
	print "<table style='width:30%; margin-left:200px'>" > file;
	for (i in saidas){
		print "<tr><th style='text-align:center'>" i "</th></tr>" > file;
		n = asort(saidas[i], ordenado);	
		for (j=n; j > 0; j--){
			numeroSaidas = ordenado[j];
			for (k in saidas[i]){
				if (saidas[i][k] == numeroSaidas){
					ref = "https://www.google.pt/maps/place/" k "+Portugal";
					print "<tr><td>" k "<a target='_blank' href='" ref "'><img class='maps' src='../lib/google_maps.png'/></a></td><td>" numeroSaidas "</td></tr>\n" > file;
					delete saidas[i][k];
				}
			}
		}
	}
	print "</table></div></div>" > file;
	printFooter(file, 3);
}


function printCD(){
	file = extrato "/Gastos-Mensais.html";
	printHeader(file, 3);
	printSideMenu(file, 4);
	printf (title, "Gasto mensal nos vários tipos de serviço disponibilizados pela Via Verde") > file;
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
	printFooter(file, 3); 
}


function printCliente(){
	file = "Cliente.html";
	printHeader(file, 2);
	print "<div class='avatar'><img src='lib/profile.png' style='margin-right: 50px'/>" > file;
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
	printFooter(file, 2);	
}


function printGastoD(){
	file = extrato "/Gastos-Diarios.html";
	printHeader(file, 3);
	printSideMenu(file, 5);
	printf (title, "Gasto diário nos vários tipos de serviço disponibilizados pela Via Verde") > file;
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
	printFooter(file, 3); 
}

function printDebitos(){
	file = extrato "/Debitos.html";
	printHeader(file, 3);
	printSideMenu(file, 6);
	printf (title, "Débitos realizados por dia nos serviços da Via Verde") > file;
	print "<table style='width:50%; margin-left:200px'>" > file;
	print "<tr><th> Dia </th><th> Montante </th></tr>" > file;
	n = asorti(debitos, ordenado);
	for (i=1; i <= n; i++){
		dataDebito = ordenado[i];
		print "<tr><td>" inverter(dataDebito) "</td><td>" debitos[dataDebito]"€ </td></tr>\n" > file;
	}
	print "</table></div></div>" > file;
	printFooter(file, 3); 
}
