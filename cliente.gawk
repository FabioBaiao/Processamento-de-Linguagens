#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";
}

# HEADER
NR == 1 {

	printCliente();

	file = getMesEmissao() ".html";
}

NR > 1 {
	
	# alínea a)
	tipo = getValueOf("TIPO");
	data = getValueOf("DATA_ENTRADA");
	if (tipo != null && data != null && data != "null"){
		invData = inverter(data);
		nEntradas[tipo][invData]++;
	}
}

END {
	
	# alínea a)
	for (i in nEntradas){
		print i;
		n = asorti(nEntradas[i], ordenado);
		for (j=1; j <= n; j++){
			data = ordenado[j];
			print inverter(data), nEntradas[i][data];
		}
	}
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

#args: name_of_file, section active (e.g.: "Perfil"), section inactive
function printHeader(file, active){
	enc = "<meta charset='UTF-8'/>";
	css = "<link rel='stylesheet' type='text/css' href='styles.css'>";
	fmt = "<li><a href='%s'> %s </a></li>";
	menu_active = "<li><a href='%s' class='active'> %s </a></li>";
	print enc css > file;
	print "<ul class='topmenu'>" > file;
	switch (active){
		case 1:	printf(menu_active, file, "Consultar") > file;
				printf(fmt, file, "Perfil") > file;
				break;
		case 2:	printf(fmt, file, "Consultar") > file;
				printf(menu_active, file, "Perfil") > file;
				break;
		default: break;
	}
	print "</ul>" > file;
}

function printFooter(file){
	footer_fmt = "<div class='footer'> %s </div>";
	end = "</body> </html>";
	printf(footer_fmt, "<img src='logo.png'/><h1>Via Verde</h1><h3>Parar para quê?</h3>") > file;
	print end > file;

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