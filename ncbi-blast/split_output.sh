
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
	csplit --quiet --prefix=lolz$i --digits=1  500k_600k_ParallelOutput$i.txt /Score/ {*}
	sed '1d' DNA_split_sequence0$i.fa > temp_DNA.txt					#deletes first line and copies only the sequence into another file
	count_partition=$(wc -c < temp_DNA.txt)
	ratio=$(echo "scale=4; $count_DNA / $count_partition"|bc)
	rm lolz"$i"0
	for f in lolz$i*;do
		e=$(grep -Po 'Expect = \K.*(?=,)'  ${f})
		new_e=$(echo "scale=4;($ratio*$e)/1"|bc)
		
		t_e=10.0
		if [ $(echo "$new_e > $t_e" | bc -l) -ne 0 ]; then
			rm -rf lolz$i*
			break;
		else
			sed -i "s/Expect =.*, /Expect = $new_e , /g" ${f}
			mv -i "${f}" "yoyo$new_e"	
		fi
	done
done








rm -rf DNA_split_sequence*.fa
#awk '/Expect =/,/, / { print }'  500k_600k_ParallelOutput1.txt > evalues.txt
#sed -i 's/Expect =.*, /Expect = 12 , /g' 	500k_600k_ParallelOutput1.txt
#sed -i 1,21d 500k_600k_ParallelOutput1.txt
#line_replacement=$(head -1l 500k_600k_ParallelOutput1.txt)
#MAX_score=$(echo $line_replacement | awk '{print $(NF-1)}')

#for i in  $(seq 2 8);do
#	sed -i 1,21d 500k_600k_ParallelOutput$i.txt								#remove first 21 lines of parallel_output file
#	line=$(head -1l 500k_600k_ParallelOutput$i.txt)
#	score=$(echo $line | awk '{print $(NF-1)}')
#	if [ $(echo "$score > $MAX_score" | bc) -ne 0 ];then
#		MAX_score=$score			
#		line_replacement=$line
#		f=$i																#store the MAX_score file number	
#	fi
#done

#sed '1d' DNA_split_sequence0$f.fa > temp_DNA.txt
#count_DNA_partition=$(wc -c < temp_DNA.txt)
#v=$(echo "$count_DNA / $count_DNA_partition" | bc -l)
#E_value=$(echo $line_replacement | awk '{print $NF}' )
#E_v=$(echo "scale=4; ($E_value * $v)/1" | bc)
#line_replacement=$(echo $line_replacement|sed s/"$E_value"//g)
#line_replacement=$line_replacement"\t"$E_v
#echo $line_replacement >> FinalOutput.txt
#sed 2,7d 500k_600k_ParallelOutput1.txt > seq.txt 
#cat seq.txt >> FinalOutput.txt
#sed '1d' DNA_split_sequence01.fa > temp_DNA.txt
#count_DNA_partition=$(wc -c < temp_DNA.txt)
#v=$(echo "$count_DNA / $count_DNA_partition" | bc -l)
#grep -Po 'Expect = \K.*(?=,)'  500k_600k_ParallelOutput1.txt > outfile.txt    #expect value of all hits into another file
#while read line
#do
#	e=$(echo "scale=3; ($line * $v)/1 "|bc)
#	echo $e
#done < outfile.txt
#sed -i 's/Expect =.*, /Expect = 12 , /g' 	500k_600k_ParallelOutput1.txt    #replace expect value
#tail -22l 500k_600k_ParallelOutput1.txt > tail_Lambda.txt				#stores the last tail part of output
#head -n -22 500k_600k_ParallelOutput1.txt > temp.txt					#removes last 22 lines
#mv temp.txt 500k_600k_ParallelOutput1.txt

