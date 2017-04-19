csplit --prefix=individ_query -z -q -n 3 8Million_DNA.fa '/>/' '{*}' 
ct=$(ls individ_query* | wc -l)
echo $ct
if [ "$ct" -gt 1 ];then

	for f in individ_query*;
	do
		mv "$f" "$f".fa 
	done
    parallel -j150% ./blastx -query {} -subject prot_sample1.fa -out ParallelOutput_{}.txt ::: individ_query*
    #rm ParallelOutput_*
    rm individ_query*
    
else


	sed '1d' prot_sample1.fa > tempProt.txt   								#deletes first line of fasta file        
	count=$(wc -m < tempProt.txt)
	#splitting the dna sequence into 8 parts 
	sed '1d' 8Million_DNA.fa > temp_DNA.txt      					                                 
	split --numeric-suffixes=1 -n 8 temp_DNA.txt DNA_split_sequence

	#appends the (i+1)th part to last $count characters in ith part to form new file
	var=1
	unset prev
	for i in DNA_split_sequence*
	do
		if [ -n "${prev}" ]                  								#checks if prev file is null
		then 
			tail -c $count ${prev} > part.temp								#stores the last 1000 characters of the previous file into part.temp
			cat ${i}>>part.temp												#appends the contents of current file to the end of part.temp
			mv part.temp ${i}																
		fi
		prev=${i}
		sed -i -e "1i>$var|500k 600k split\n" ${i}
		var=$((var+1))
	done

	#rename the partitions to .fa files
	for f in DNA_split_sequence*; 
	do
		mv -- "$f" "${f%.txt}.fa"
	done

	#gnu parallel
	seq 1 8 | parallel ./blastx -query DNA_split_sequence0{}.fa -subject prot_sample1.fa -out 500k_600k_ParallelOutput{}.txt
	
	
fi

