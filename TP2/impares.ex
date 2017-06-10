DECLS
a[10], i, c
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
		PRINT: a[i];
		c = c + 1;
	}
}
PRINT: c;