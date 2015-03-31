@melody;
@timespan;
@time;
@volume;
@count;

$separator=",";

while(<STDIN>){
	my($input)=$_;
	my($octave)=4;
	my($smelody)="";
	my($slength)="";
	my($stime)="";
	my($ctime)=0;
	my($svolume)="";
	my($cvolume)=100;
	my($luvolume)=1;
	my($plength)=0;
	my($dlength)=4;
	my($sundecoded)="";
	my($soriginal)="";
	my($scount)=0;
	
	$input=~ s/\/\*.+?\*\///g;
	$input=~ s/\/\:2?(.+?)\/(.+?)\:\//$1$2$1/g;
	$input=~ s/\/\:2?(.+?)\:\//$1$1/g;
	$input=~ tr/a-z/A-Z/;
	$input=~ s/\s//g;

	while($input=~ /([^A-G^R]*?)([A-GR])([\-\+\#]?)(\%?)(\d*)(\.*)(\&?)/){
		$soriginal.="[".$1."]"."(".$2.$3.$4.$5.$6.$7.")";
		my($header)=$1;
		while($header=~ /O(\d+)/){
			$octave=$1;
			$header=~ s/O(\d+)//;
		}
		while($header=~ /L(\d+)/){
			$dlength=$1;
			$header=~ s/L(\d+)//;
		}
		while($header=~ /\</){
			$octave++;
			$header=~ s/\<//;
		}
		while($header=~ /\>/){
			$octave--;
			$header=~ s/\>//;
		}
		
		#音量関係
		while($header=~ /\@V(\d+)/){
			$cvolume=$1;
			$luvolume=1;
			$header=~ s/\@V(\d+)//;
		}
		while($header=~ /V(\d+)/){
			$cvolume=$1*8+7;
			$luvolume=7;
			$header=~ s/V(\d+)//;
		}
		while($header=~ /\((\d+)/){
			$cvolume+=$luvolume*$1;
			$header=~ s/\((\d+)//;
		}
		while($header=~ /\(/){
			$cvolume+=$luvolume;
			$header=~ s/\(//;
		}
		while($header=~ /\)(\d+)/){
			$cvolume-=$luvolume*$1;
			$header=~ s/\)(\d+)//;
		}
		while($header=~ /\)/){
			$cvolume-=$luvolume;
			$header=~ s/\)//;
		}

		$sundecoded.=$header;
		
		my($onkai);
		my($length)=0;
		
		if($4 eq "%"){
			$length=$5;
		}else{
			if($5 eq ""){
				$length=384/$dlength;
			}else{
				$length=384/$5;
			}
		}
		if($6 eq "."){
			$length=$length*1.5;
		}elsif($6 eq ".."){
			$length=$length*1.75;
		}elsif($6 eq "..."){
			$length=$length*1.875;
		}
		$length+=$plength;
		
		if($7 eq "&"){
			$plength=$length;
		}elsif($2 eq "R"){
			$plength=0;
			
			$ctime+=$length;
		}else{
			$plength=0;
			
			$onkai=index("C D EF G A B",$2);
			$onkai+=$octave*12;
			if($3 eq "+" || $3 eq "#"){
				$onkai++;
			}elsif($3 eq "-"){
				$onkai--;
			}
			
			$smelody.=$onkai.$separator;
			$slength.=($length/384).$separator;
			$stime.=($ctime/384).$separator;
			$ctime+=$length;
			$svolume.=($cvolume/100).$separator;
			$scount++;
		}
		
		$input=~ s/([^A-G^R]*?)([A-GR])([\-\+\#]?)(\%?)(\d*)(\.*)(\&?)//;
	}
	
	push(@melody,$smelody);
	push(@timespan,$slength);
	push(@time,$stime);
	push(@volume,$svolume);
	push(@count,$scount);
	
	print "\n\nFollowing text could not be decoded.\n".$sundecoded." ".$input."\n\n";
#	print "\n\nOriginal.\n".$soriginal."\n\n";
}

$i=0;
while($i<@melody-1){
	if($count[$i]<$count[$i+1]){
		($melody[$i],$melody[$i+1])=($melody[$i+1],$melody[$i]);
		($timespan[$i],$timespan[$i+1])=($timespan[$i+1],$timespan[$i]);
		($time[$i],$time[$i+1])=($time[$i+1],$time[$i]);
		($volume[$i],$volume[$i+1])=($volume[$i+1],$volume[$i]);
		($count[$i],$count[$i+1])=($count[$i+1],$count[$i]);
		$i=0;
	}else{
		$i++;
	}
}

print "<Melody>\n";
for(my $i=0;$i<@melody;$i++){
	print ":{0;".$i."}".$separator;
	print $melody[$i];
#	print $separator x ($count[0]-$count[$i]);
}
print "\n\n___________________________________________\n\n";

print "<Timespan>\n";
for(my $i=0;$i<@melody;$i++){
	print ":{0;".$i."}".$separator;
	print $timespan[$i];
#	print $separator x ($count[0]-$count[$i]);
}
print "\n\n___________________________________________\n\n";

print "<Time>\n";
for(my $i=0;$i<@melody;$i++){
	print ":{0;".$i."}".$separator;
	print $time[$i];
#	print $separator x ($count[0]-$count[$i]);
}
print "\n\n___________________________________________\n\n";

print "<Volume>\n";
for(my $i=0;$i<@melody;$i++){
	print ":{0;".$i."}".$separator;
	print $volume[$i];
#	print $separator x ($count[0]-$count[$i]);
}

