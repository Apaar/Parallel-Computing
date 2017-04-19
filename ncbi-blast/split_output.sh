
#For first few line
head -15l 500k_600k_ParallelOutput0.txt > FinalOutput.txt    			#copies first 15 lines of partition output to final output
QueryDetail=$(head -1l 8Million_DNA.fa)									#first line, description of fasta file
QueryDetail=${QueryDetail#">"}											#add '>' symbol to description
sed '1d' 8Million_DNA.fa > temp_DNA.txt									#deletes first line and copies only the sequence into another file
count_DNA=$(wc -c < temp_DNA.txt)										
count_DNA=$(($count_DNA-2))												#character count of dna sequence			
QueryDetail="Query = "$QueryDetail										
QueryDetail=$QueryDetail"\n\nLength = "$count_DNA
echo $QueryDetail >> FinalOutput.txt									#appends Query Detail to end of final output file
blah="\t\t\t\t\t\t\t\t\t\t\t\t\tScore\t\tE\nSequences producing significant alignments:\t\t\t(Bits)\tValue"
subjectDesc=$(head -1l prot_sample1.fa)
subjectDesc=${subjectDesc#'>'}
blah=$blah"\n\n"$subjectDesc
echo $blah >> FinalOutput.txt
#-----First 22 lines of output file finalised----#			
sed -n '24,27p' 500k_600k_ParallelOutput0.txt > prot_details.txt
tail -22l 500k_600k_ParallelOutput0.txt > tail_Lambda.txt
for i in $(seq 0 7);do
	sed -i 1,27d 500k_600k_ParallelOutput$i.txt
	head -n -22 500k_600k_ParallelOutput$i.txt > temp.txt 
	mv  temp.txt 500k_600k_ParallelOutput$i.txt	
	csplit --quiet --prefix=loop$i --digits=1  500k_600k_ParallelOutput$i.txt /Score/ {*}
	sed '1d' DNA_split_sequence0$i.fa > temp_DNA.txt					#deletes first line and copies only the sequence into another file
	count_partition=$(wc -c < temp_DNA.txt)
	ratio=$(echo "scale=4; $count_DNA / $count_partition"|bc)
	rm loop"$i"0
	for f in loop$i*;do
		e=$(grep -Po 'Expect = \K.*(?=,)'  ${f})						#computing the new E value
		new_e=$(echo "scale=4;($ratio*$e)/1"|bc)
		
		t_e=10.0
		if [ $(echo "$new_e > $t_e" | bc -l) -ne 0 ]; then
			rm -rf loop$i*
			break;
		else
			sed -i "s/Expect =.*, /Expect = $new_e , /g" ${f}
			mv -i "${f}" "file_$new_e"	
		fi
	done
done

rm -rf DNA_split_sequence*.fa


