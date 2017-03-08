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
	
	print "a)";
	for (i in dias) 
		print i, dias[i];

	print "b)";
	for (i in locais)
		print i;
}