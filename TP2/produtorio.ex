DECLS
n, p, v
INSTRS
READ: n;
p = 1;
WHILE(n > 0){
	READ: v;
	p = p * v;
	n = n - 1;
}
PRINT: p;