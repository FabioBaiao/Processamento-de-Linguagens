#!/usr/bin/gawk -f

BEGIN {
	
	FS = "[<>]";
	RS = "<TRANSACCAO>";
	#html
	file = "Cliente.html"
	enc = "<meta charset='UTF-8'/>";
	css = "<link rel='stylesheet' type='text/css' href='styles.css'>";
	footer_fmt = "<div class='footer'> %s </div>";
	end = "</body> </html>";
	print enc css "<div class='avatar'><img src='profile.png' style='margin-right: 50px'/>" > file;

}

# HEADER
NR == 1 {
	
	printCliente(file);
}

END {
	print "</div>" > file;	
	printf(footer_fmt, "<img src='logo.png'/><h1>Via Verde</h1><h3>Parar para quê?</h3>") > file;
	print end > file;
}

function printCliente(file){
	print "<table>" > file;
	for (i=1; i < NF; i++){
		if ($i ~ /CLIENTE/){
			for (i += 2; $i !~ /CLIENTE/; i+=4){
				gsub("_", " ", $i);
				print "<tr><th style='text-align:left'>"$i"</th><td>"$(i+1)"</td></tr>" > file;
			}
			break;
		}
	}
	print "</table>" > file;
}