#saveDirSize("fs.txt");
currentDirMSSDVD();
#basicDS();

sub basicDS{
	my %h;
	%h=(%h,getDirSizeList("C:/Users/UserName/BackUP"));
	%h=(%h,("Videos",getDirSize("C:/Users/UserName/Videos")));
	while(my ($k,$v)=each(%h)){
		if($v<1000000){delete($h{$k});}
		}
	saveFile("fs.txt",dataListOut(\%h));
	}

sub saveDirSize{
	my $d=$_[1];
	if(! defined($d)){$d=".";}
	my $f=$_[0];
	my %h=loadDataList(loadFile($f));
	%h=(%h,getDirSizeList($d));
	saveFile($f,dataListOut(\%h));
	}

sub currentDirMSSDVD{
	my %h=loadDataList(loadFile("fs.txt"));
	%h=(%h,getDirSizeList("."));
	
	my @r=maximizeSumSize(\%h,4700000000);
	print "Sum Size: $r[0] B\n";
	foreach $n (@{$r[1]}){
		print $n."\n";
		}
	}

sub maximizeSumSize{
	my %h=%{$_[0]};
	my $ls=$_[1];
	my @n=keys %h;
	my $mxs=-1;
	my $mxn=-1;
	my @r;
	for(my $i=1;$i<=2**(0+@n);$i++){
		my $s=0;
		for(my $j=0;$j<@n;$j++){
			if(int($i/(2**$j))%2 ==1){$s+=$h{$n[$j]};}
			if($s>$ls){next;}
			}
		if($s<=$ls and $s>$mxs){$mxs=$s;$mxn=$i;}
		}
	for(my $j=0;$j<@n;$j++){
		if(int($mxn/(2**$j))%2 ==1){push(@r,$n[$j]);}
		}
	return ($mxs,\@r);
	}

sub showDirSizeList{
	my $d=$_[0];
	my %h=getDirSizeList($d);
	my $r="";
	while(my($n,$s)=each(%h)){
		$r.=$n."\t".$s."\n";
		}
	return $r;
	}

sub getDirSizeList{
	my $d=$_[0];
	my @d=getDir($d);
	my %h;
	foreach $f (@d){
		if(-d $d."/".$f){
			$h{$f}=getDirSize($d."/".$f);
			}else{
			$h{$f}= -s $d."/".$f;
			}
		}
	return %h;
	}

sub getDirSize{
	my $s=0;
	my $d=$_[0];
	my @d=getDir($d);
	foreach $f (@d){
		if(-d $d."/".$f){
			$s+=getDirSize($d."/".$f);
			}else{
			$s+= -s $d."/".$f;
			}
		}
	return $s;
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


#___________________________________________
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

sub addFile{
	open DATA,">>".$_[0];
	flock(DATA, LOCK_EX);
	print DATA $_[1];
	flock(DATA, LOCK_NB); 
	close DATA; 
}

sub loadDataList{
	my $text=$_[0];
	my %ret;
	my @list=split(/\n/, $text);
	my $temp;
	foreach $temp(@list){
		(my $key,my $content)=split(/:/, $temp,2);
		$content =~ s/\[ENTER\]/\n/g ;
		$ret{$key}=$content;
		}
	return %ret;
	}

sub dataListOut{
	my $temp;
	$temp=$_[0];
	my %hash=%$temp;
	my $text="";
	while ( (my $key, my $content) = each %hash ) {
		$content =~ s/\n/\[ENTER\]/g ;
		$text=$text."$key:$content\n";
		}
	return $text;
	}

