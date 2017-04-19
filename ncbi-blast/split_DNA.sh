#protein sequence word count
sed '1d' prot_sample1.fa > tempProt   									#deletes first line of fasta file
mv tempProt tempProt.txt              
count=$(wc -m < tempProt.txt)        									#wordcount

#TODO: 
#1. First find number of queries in the dna file
#2. If only single query go to comment 696969
#3. If a dna file has multiple queries in it. 
#4. Split the file into individual query files



#splitting the dna sequence into 8 parts 
#696969
sed '1d' 8Million_DNA.fa > temp_DNA.txt      					                                 
split -n 8  -d temp_DNA.txt DNA_split_sequence

#appends the (i+1)th part to last $count characters in ith part to form new file
var=1
unset prev
for i in DNA_split_sequence*
do if [ -n "${prev}" ]                  								#checks if prev file is null
	then 
		tail -c $count ${prev} > part.temp									#stores the last 1000 characters of the previous file into part.temp
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
seq 0 7 | parallel ./blastx -query DNA_split_sequence0{}.fa -subject prot_sample1.fa -out 500k_600k_ParallelOutput{}.txt  

