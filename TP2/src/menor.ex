DECLS
n, m, v
INSTRS
READ: n;
READ: m;
n = n - 1;
WHILE(n > 0){
	READ: v;
	IF(v < m){
		m = v;
	}
	n = n - 1;
}
PRINT: "Menor: ";
PRINT: m;