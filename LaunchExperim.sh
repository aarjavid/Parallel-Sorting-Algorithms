#!/bin/bash
Narr=(8 16 1024 32768 1048576 33554432)
dir_arr=(RND RS)
sorFile_dir_RS="<provide absolute path to RS directory>"
sorFile_dir_RND="<provide absolute path to RND directory>"


btn_dir="./sort/bitonic/final/"
oets_dir="./sort/odd_even/final/"

Nsize=${#Narr[@]}

START=0
END=Nsize

for (( c=$START; c<$END; c++ ))
do

	echo
	echo

	#RS part
	echo "N is "${Narr[$c]}" Input Mode is RND-Random"
	
	#filepath for RND
	grep_strng="_"${Narr[$c]}"_"
	cmnd="ls "$sorFile_dir_RND" | grep "$grep_strng
	files=$(eval $cmnd)
	file_path=$sorFile_dir_RND$files
	
	#oets seq	
	cmnd=$oets_dir"oe_seq "${Narr[$c]}" "$file_path" | grep sort"
	echo $cmnd
	res=$(eval $cmnd)
	oup=${Narr[$c]}",RND,"$res	
	echo $oup
	
	#btn seq
	cmnd=$btn_dir"btn_seq "${Narr[$c]}" "$file_path" | grep sort"
	echo $cmnd
	res=$(eval $cmnd)
	oup=${Narr[$c]}",RND,"$res	
	echo $oup
	echo

	#RS part
	echo "N is "${Narr[$c]}" Input Mode is RS-Reverse Sorted"
	
	#filepath for RS
	grep_strng="_"${Narr[$c]}"_"
	cmnd="ls "$sorFile_dir_RS" | grep "$grep_strng
	files=$(eval $cmnd)
	file_path=$sorFile_dir_RS$files
	

	#oets seq	
	cmnd=$oets_dir"oe_seq "${Narr[$c]}" "$file_path" | grep sort"
	echo $cmnd
	res=$(eval $cmnd)
	oup=${Narr[$c]}",RS,"$res	
	echo $oup
	
	#btn seq	
	cmnd=$btn_dir"btn_seq "${Narr[$c]}" "$file_path" | grep sort"
	echo $cmnd
	res=$(eval $cmnd)
	oup=${Narr[$c]}",RS,"$res	
	echo $oup
done
echo

echo "over"      

