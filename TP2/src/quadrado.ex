DECLS
x, y, i
INSTRS
READ: x;
i = 0;
WHILE (i < 3){
	READ: y;
	IF (y != x){
		PRINT: "Nao é quadrado!";
		i = 4;
	}
	ELSE{
		i = i + 1;
	}
}
IF (i == 3){
	PRINT: "É quadrado!";
}