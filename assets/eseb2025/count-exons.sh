rg '\tprotein\t' Araport11_GFF3_genes_transposons.current.gff |
    sed 's/.*=//' |
    sed 's/\..*//' |
    sort |
    uniq >araport11-protein-genes.txt

rg '\texon\t' Araport11_GFF3_genes_transposons.current.gff |
    rg -f <(cat araport11-protein-genes.txt | sed 's/^/Parent=/') |
    sed 's/.*Parent=//' |
    cut -f1 -d';' |
    sort |
    uniq -c |
    sed 's/ \(AT[^.]*\)\..*/\0\t\1/' |
    awk '{if ($1>1) {print $3}}' |
    sort |
    uniq >araport11-multiexonic-protein-genes.txt

paste <(rg -c -v -f araport11-multiexonic-protein-genes.txt araport11-protein-genes.txt) \
    <(wc -l araport11-multiexonic-protein-genes.txt | awk '{print $1}') \
    <(wc -l araport11-protein-genes.txt | awk '{print $1}') |
    awk 'BEGIN{print "species\tn_monoexonic\tn_multiexonic\tn_total\tmono_to_multi_ratio"} {print "Arabidopsis", $0, $1/$2}' >mono-multi.tsv

cat A.sinensis.gff |
    rg '\tCDS\t' |
    sed 's/.*Parent=//' |
    tr -d \; |
    sort |
    uniq -c |
    awk '{if($1>1){multi+=1}if($1==1){mono+=1}} END{print "A.sinensis", mono, multi, mono+multi, mono/multi}' >>mono-multi.tsv

zcat A.yunnanensis.gff3.gz |
    rg '\texon\t' |
    sed 's/.*Parent=//' |
    tr -d \; |
    sort |
    uniq -c |
    awk '{if($1>1){multi+=1}if($1==1){mono+=1}} END{print "A.yunnanensis", mono, multi, mono+multi, mono/multi}' >>mono-multi.tsv

zcat langdu.chr.rename.gff.gz |
    rg '\texon\t' |
    sed 's/.*Parent=//' |
    tr -d \; |
    sort |
    uniq -c |
    awk '{if($1>1){multi+=1}if($1==1){mono+=1}} END{print "Stellera", mono, multi, mono+multi, mono/multi}' >>mono-multi.tsv

sed -i 's/ /\t/g' mono-multi.tsv
