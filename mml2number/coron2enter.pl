while(<STDIN>){
	my($a)=$_;
	$a=~ s/\,/\n/g;
	print $a;
}