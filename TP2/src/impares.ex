DECLS
a[10], i, c, r
INSTRS
i = 0;
WHILE(i < 10){
	a[i] = i;
	i = i + 1;
}
i = 0;
c = 0;
WHILE(i < 10){
	r = a[i] % 2;
	IF(r == 1){
		PRINT: "Impar: ";
		PRINT: a[i];
		PRINT: " \n";
		c = c + 1;
	}
	i = i + 1;
}
PRINT: "Numero de impares: ";
PRINT: c;