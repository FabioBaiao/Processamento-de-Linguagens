DECLS
a[20], i, v, aux
INSTRS
i = 0;
WHILE(i < 20){
	READ: v;
	a[i] = v;
	i = i + 1;
}
i = 0;
WHILE (i < 20){
	j = i + 1;
	m = i;
	WHILE(j < 20){
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
WHILE(i < 20){
	PRINT: a[i];
}