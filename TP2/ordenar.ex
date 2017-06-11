DECLS
a[5], i, v, aux, j, m
INSTRS
i = 0;
WHILE(i < 5){
	READ: v;
	a[i] = v;
	i = i + 1;
}
i = 0;
WHILE (i < 5){
	j = i + 1;
	m = i;
	WHILE(j < 5){
		IF(a[j] > a[m]){
			m = j;
		}
		j = j + 1;
	}
	aux = a[i];
	a[i] = a[m];
	a[m] = aux;
	i = i + 1;
}
i = 0;
PRINT: "Ordem descrescente\n";
WHILE(i < 5){
	PRINT: a[i];
	PRINT: " \n";
	i = i + 1;
}