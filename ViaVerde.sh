#alínea a)
grep "DATA_ENTRADA" viaverde.xml | gawk -F "[<>]" '{a[$3]++} END {for (i in a) print i, a[i]}'



#alínea b)
grep "<SAIDA>" viaverde.xml | gawk -F "[<>]" '{print $3}'| sort -u


#alínea c)
