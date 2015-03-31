main();
sub main{
	my @t=getDir("./in");
	for(my $i=0;$i<@t;$i++){
		if(!(-d "./in/".$t[$i])){
			my $p=$t[$i];
			$p=~ s/\.\w{3}$/\.srt/;
			saveFile("./out/".$p,convNico2Srt(loadFile("./in/".$t[$i])));
			}
		}

	}

sub convNico2Srt{
	my ($n,@a)=@_;
	my @l=split(/\n/,$n);
	$c=0;
	my @t;
	my @w;
	for(my $i=0;$i<@l;$i++){
		my @u=split(/:/,$l[$i],3);
		if($t[@t-1] eq $u[0]){
			$w[@w-1]=$u[2]."\n".$w[@w-1];
			}else{
			push(@t,$u[0]);
			push(@w,$u[2]);
			}
		}
	my $t="";
	for(my $i=0;$i<@t;$i++){
		$t.="".($i+1)."\n";
		my ($s,$m)=split(/\./,$t[$i]);
		$s=~ s/^.*?(\d+)$/$1/;
		$t.=sprintf("%02d:%02d:%02d,%03d",int($s/3600),int(($s/60)%60),int($s%60),$m*10);
		$t.=" --> ";
		my ($sn,$mn)=split(/\./,$t[$i+1]);
		my $waitTime=5;
		if($sn*100+$mn>($s*100+$m+$waitTime*100)){
			$s+=$waitTime;}else{
			$s=int(($sn*100+$mn-1)/100);
			$m=int(($sn*100+$mn-1)%100);}
		$t.=sprintf("%02d:%02d:%02d,%03d",int($s/3600),int(($s/60)%60),int($s%60),$m*10);
		$t.="\n";
		$t.=$w[$i];
		$t.="\n\n";
		}
	return $t;
	}

sub loadFile{
	if ( exists($fileCache{$_[0]}) ) {
		return $fileCache{$_[0]}
	}else{
		local(@temp);
		open DATA,$_[0];
		flock(DATA, LOCK_EX);
		@temp = <DATA>;
		print <DATA>;
		flock(DATA, LOCK_NB); 
		close DATA;
		$fileCache{$_[0]}=join "",@temp;
		return join "",@temp;
	}
}

sub saveFile{
	open DATA,">".$_[0];
	flock(DATA, LOCK_EX);
	print DATA $_[1];
	flock(DATA, LOCK_NB); 
	close DATA;
	$fileCache{$_[0]}=$_[1];
}

sub getDir{
	my @dirs;
	my $dir;
	opendir(DIR, $_[0]);
	while (defined($dir = readdir(DIR))) {
		if($dir ne "." and $dir ne ".."){push(@dirs,$dir);}
	}
	closedir(DIR);
	return sort(@dirs);
}
