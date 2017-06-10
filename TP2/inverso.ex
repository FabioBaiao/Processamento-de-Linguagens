DECLS
a[20]
INSTRS
i = 0;
WHILE(i < 20){
	READ: a[i];
	i = i + 1;
}
i = 20;
WHILE(i > 0){
	PRINT: a[i];
	i = i - 1;
}