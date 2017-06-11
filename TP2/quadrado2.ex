DECLS
x, y, i
INSTRS
READ: x;
i = 0;
WHILE (i < 3){
	READ: y;
	IF (y == x){
		i = i + 1;
	}
	ELSE{
		PRINT: "Nao é quadrado!";
		i = 4;
	}
}
IF (i == 3){
	PRINT: "É quadrado!";
}