DECLS
x, y, i
INSTRS
READ: x;
i = 0;
WHILE (i < 3){
	READ: y;
	IF (y != x){
		PRINT: 0;
		i = 4;
	}
}
IF (x == 3){
	PRINT: 1;
}