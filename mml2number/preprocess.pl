#このファイルはs-jisです。
$text="";
while(<STDIN>){
	my($input)=$_;
	
	$input=~ s/[\n\r]//g;
	$input=~ s/\s//g;
	$input=~ s/　//g;
	$text.=$input;
}
if($text=~ /\#OCTAVEREVERSE/i){
	$text=~ tr/\<\>/\>\</;
	$text=~ s/\#OCTAVEREVERSE//gi;
}

while($text=~ /\$([^\;\=\$]+)\=([^\;\=\$]+)\;/){
	my($vkey,$vword)=($1,$2);
	$text=~ s/\$([^\;\=\$]+)\=([^\;\=\$]+)\;//;
	$text=~ s/\$$vkey/$vword/g;
	}

$text=~ s/\@[\w^Vv]\-?\d*\,?\-?\d*\,?\-?\d*\,?\-?\d*\,?\-?\d*\,?\-?\d*\,?\-?\d*//g;

@lines=split(/;/,$text);
foreach my $input(@lines)
	{
	$input=~ s/\/\*.+?\*\///g;
	
	$input=~ s/\/\:2?([^\:\/\d]+?)\:\//$1$1/g;

	while($input=~ /\/\:(\d*)([^\:\/\d][^\:\/]*?)\:\//){
		my($cnt);
		my($tmp);
		if($1 eq "0"){$tmp=""}else{
			if($1 eq ""){$cnt=2;}else{$cnt=$1+0;}
			$tmp=($2) x $cnt;
		}
		$input=~s /\/\:(\d*)([^\:\/\d][^\:\/]*?)\:\//$tmp/;
	}

	while($input=~ /\/\:(\d*)([^\:\/\d][^\:\/]*?)(\/?)([^\:\/]*?)\:\//){
		my($cnt);
		my($tmp);
		if($1 eq "0"){$tmp=""}else{
			if($1 eq ""){$cnt=2;}else{$cnt=$1+0;}
			if($3 eq ""){$tmp=($2.$4) x $cnt;}else{$tmp=($2.$4)x($cnt-1).$2;}
		}
		$input=~s /\/\:(\d*)([^\:\/\d][^\:\/]*?)(\/?)([^\:\/]*?)\:\//$tmp/;
	}
#print "\n";
	if($input ne ""){print $input.";\n";}
}
