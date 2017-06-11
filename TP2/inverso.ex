DECLS
a[5], i
INSTRS
i = 0;
WHILE(i < 5){
	READ: a[i];
	i = i + 1;
}
i = 5 - 1;
PRINT: "Ordem inversa\n";
WHILE(i >= 0){
	PRINT: a[i];
	PRINT: " \n";
	i = i - 1;
}