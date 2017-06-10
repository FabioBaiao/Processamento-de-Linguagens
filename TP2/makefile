F = lpis
$F: $F.y $F.fl
	yacc $F.y
	flex $F.fl
	gcc y.tab.c `pkg-config --cflags glib-2.0 --libs glib-2.0` -o $F