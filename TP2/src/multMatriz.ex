DECLS
a[3][3], b[3][3], c[3][3], i, j, k, r
INSTRS
i = 0;
WHILE(i < 3){
	j = 0;
	WHILE(j < 3){
		a[i][j] = i * j;
		b[j][i] = i + j;

		j = j + 1;
	}
	i = i + 1;
}
i = 0;
WHILE(i < 3){
	j = 0;
	WHILE (j < 3){
		k = 0;
		WHILE(k < 3){
			r = a[i][k] * b[k][j];
			c[i][j] = c[i][j] + r;
			k = k + 1;
		}
		j = j + 1;
	}
	i = i + 1;
}
i = 0;
WHILE(i < 3){
	j = 0;
	WHILE(j < 3){
		PRINT: a[i][j];
		PRINT: " ";
		j = j + 1;
	}
	IF(i == 1){
		PRINT: "|*|";
	}
	ELSE{
		PRINT: "| |";
	}
	j = 0;
	WHILE(j < 3){
		PRINT: b[i][j];
		PRINT: " ";
		j = j + 1;
	}
	IF(i == 1){
		PRINT: "|=|";
	}
	ELSE{
		PRINT: "| |";
	}
	j = 0;
	WHILE(j < 3){
		PRINT: c[i][j];
		PRINT: " ";
		j = j + 1;
	}
	PRINT: " \n";
	i = i + 1;
}