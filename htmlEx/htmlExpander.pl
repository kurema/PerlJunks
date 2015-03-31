use Time::Local;
require "./qreki.pl";

init();
#saveFile("temp3.html",htmlExpander(loadFile("./benronbu.html")));

sub showHttp{
	my $temp=htmlExpander(loadFile($_[0]));
	print "Content-Type: text/html\n\n";
	while ( my($key, $value) = each(%COOKIE_TO_WRITE) ) {
		print "$key=$value; "
		}
	print "\n\n";
	print $temp;
	}

sub userCertification{
	$USER="guest";
	}

sub init{
	loadFormGet();
	userCertification();
	getLocalTime();
	loadCookie();
	chatWrite();
}

sub htmlExpander{
	my $text=$_[0];
	my %varList=("SESSION_ID",int(10000000000*rand()),"USER",$USER,"SEC",$TIME{"sec"},"MIN", $TIME{"min"}, "HOUR",$TIME{"hour"},"DAY_M", $TIME{"mDay"},"MONTH", $TIME{"month"},"YEAR", $TIME{"year"},"DAY_WJ", $TIME{"wDayJapanese"},"DAY_W", $TIME{"wDay"},"DAY_WE", $TIME{"wDayEnglish"},"DAY_WEF", $TIME{"wDayEnglishFull"},"MONTH_J", $TIME{"monthJapanese"},"MONTH_E", $TIME{"monthEnglish"},"MONTH_EF", $TIME{"monthEnglishFull"}, "DAY_Y",$TIME{"yDay"},"SUMMER_TIME", $TIME{"summerTime"},"TIME_F",$TIME{"text"},"DATE_J",$TIME{"textDateJapanese"},"TIME_J",$TIME{"textTimeJapanese"},"DATE",$TIME{"textDate"},"TIME",$TIME{"textTime"});
	my %entity=("ENTER","<br />","COMMA",",","LESS","&lt;","GREATER","&gt;","QUOTE","&quot;","AND","&at;","SPACE"," ","OPEN","(","CLOSE",")");

	$text =~ s/\{%(\w+?)%\}/$varList{$1}/g ;
	$text =~ s/\{%(\w+?):(.+?)%\}/htmlExpanderCommandSimple($1,$2)/eg ;
	while($text =~ /<\!-- COMMAND BEGIN .+? (\w+?) -->.+?<\!-- COMMAND END \1 -->/s){
		$text =~ s/<\!-- COMMAND BEGIN (.+?) (\w+?) -->(.+?)<\!-- COMMAND END \2 -->/htmlExpanderCommandLong($3,$1)/esg ;
		}
	while($text =~ /<\!-- COMMAND .+? -->/s){
		$text =~ s/<\!-- COMMAND (.+?) -->/htmlExpanderCommand($1)/esg ;
	}
	$text =~ s/\[(\w+?)\]/defaultText("\[".$1."\]",$entity{$1})/eg ;
	return $text;
	}

sub htmlExpanderCommandLong{
	my %commandHash=("DATABASE",\&htmlExpanderDataBase,"IF",\&htmlExpanderIf,"PROGRAM",\&htmlExpanderProgram,"CALENDAR",\&htmlExpanderCalendar,"SET",\&htmlExpanderSetVarLong,"CALENDAR_SHORT",\&htmlExpanderCalendarShort,"DATABASE_DL",\&htmlExpanderDataBaseDataList);
	my $text=$_[0];
	my $temp=$_[1];
	$temp=~ s/\'(.+?)\'/deleteSpace($1)/eg ;
	while($temp=~ /\([^\(\)]+\)/){
		$temp=~ s/\(([^\(\)]+)\)/htmlExpanderCommand($1)/e ;
		}
	(my $commandName,@argList)=split(/\s/,$temp);
	if (exists $commandHash{$commandName}){
		my $temp=$commandHash{$commandName};
		return &$temp($text,\@argList);
		}else{
		return "";
		}
	}

sub htmlExpanderCommand{
	my %commandHash=("HEAD",\&htmlExpanderHead,"TAIL",\&htmlExpanderTail,"INCLUDE",\&htmlExpanderInclude,"ENV",\&htmlExpanderEnv,"FORM",\&htmlExpanderForm,"LOAD",\&htmlExpanderLoadVar,"VAR",\&htmlExpanderShowVar,"SAVE_FORM_DATA",\&htmlExpanderSaveFormData,"SET",\&htmlExpanderSetVar,"TABTITLE",\&htmlExpanderShowTab,"INPUTFORM",\&htmlExpanderFormMaker,"SAVE_COOKIE",\&htmlExpanderSetCookie,"ALINK",\&htmlExpanderAlink,"VARLIST_URL",\&htmlExpanderShowVarListUrl,"CALC",\&htmlExpanderCalc,"GETDAY",\&htmlExpanderGetDay,"MOONAGE",\&htmlExpanderMoonAge,"ROKUYOU",\&htmlExpanderRokuyou,"24SEKKI",\&htmlExpander24Sekki,"TEXT_EX_TABTITLE",\&htmlExpanderTextExToTabList,"TEXT_EX_HTML",\&htmlExpanderTextExToHtml,"TEXT_EX_HTML_TAB",\&htmlExpanderTextExToHtmlSwitch);
	my $temp=$_[0];
	$temp=~ s/\'(.+?)\'/deleteSpace($1)/eg ;
	while($temp=~ /\([^\(\)]+\)/){
		$temp=~ s/\(([^\(\)]+)\)/htmlExpanderCommand($1)/e ;
		}
	(my $commandName,@argList)=split(/\s/,$temp);
	if (exists $commandHash{$commandName}){
		my $temp=$commandHash{$commandName};
		return &$temp(\@argList);
		}else{
		return "";
		}
	}

sub htmlExpanderCommandSimple{
	my %commandHash=("CALC",\&simpleCalc,"LOCALTIME",\&htmlExpanderLocalTime,"GMTIME",\&htmlExpanderGMTime,"GETDAY",\&htmlExpanderGetDayText,"MOONAGE",\&htmlExpanderMoonAgeText,"ROKUYOU",\&htmlExpanderRokuyouText,"24SEKKI",\&htmlExpander24SekkiText);
	my $arg=$_[1];
	my $commandName=$_[0];
	if (exists $commandHash{$commandName}){
		my $temp=$commandHash{$commandName};
		return &$temp($arg);
		}else{
		return "";
		}
	}

sub htmlExpanderProgram{
	my $text=$_[0];
	my @commandList=split(/\n/,$text);
	for(my $i;$i<@commandList;$i++){
		htmlExpanderCommand($commandList[$i]);
		}
	return "";
	}


sub htmlExpanderLoadVar{
	my $temp=$_[0];
	my @arg=@$temp;
	my %hash=loadDataList(loadFile($arg[1]));
	%{$VAR{$arg[0]}}=%hash;
	return "";
}

sub htmlExpanderShowVar{
	my $temp=$_[0];
	my @arg=@$temp;
	return $VAR{$arg[0]}{$arg[1]};
}

sub htmlExpanderShowVarListUrl{
	my $temp=$_[0];
	my @arg=@$temp;
	my $text="?";
	my $temp=$VAR{$arg[0]};
	my %tempHash=%$temp;
	my $i=1;
	while($i+1<=0+@arg){
		$tempHash{$arg[$i]}=$arg[$i+1];
		$i+=2;
		}
	while(my($key,$value)=each(%tempHash)){
		my $temp=$value;
		$temp=~ s/([^\s\w])/"\%".sprintf("%02X",ord($1))/eg ;
		$temp=~ s/(\s)/+/g ;
		$text=$text."$key=$temp\&";
		}
	chop $text;
	return $text;
}

sub htmlExpanderCalc{
	my $temp=$_[0];
	my @arg=@$temp;
	return simpleCalc($arg[0]);
	}

sub htmlExpanderSetVarLong{
	my $temp=$_[1];
	my @arg=@$temp;
	my $text=$_[0];
	$VAR{$arg[0]}{$arg[1]}=$text;
	return "";
}

sub htmlExpanderSetVar{
	my $temp=$_[0];
	my @arg=@$temp;
	if($arg[2] ne ""){
		$arg[2] =~ s/\[ENTER\]/\n/g ;
		$arg[2] =~ s/\[SPACE\]/\s/g ;
		$arg[2] =~ s/\[LESS\]/\</g ;
		$arg[2] =~ s/\[GREATER\]/\>/g ;
		$arg[2] =~ s/\[HYPHEN\]/\-/g ;
		$VAR{$arg[0]}{$arg[1]}=$arg[2];
		}elsif($arg[3] ne ""){
		$arg[3] =~ s/\[ENTER\]/\n/g ;
		$arg[3] =~ s/\[SPACE\]/\s/g ;
		$arg[3] =~ s/\[LESS\]/\</g ;
		$arg[3] =~ s/\[GREATER\]/\>/g ;
		$arg[3] =~ s/\[HYPHEN\]/\-/g ;
		$VAR{$arg[0]}{$arg[1]}=$arg[3];
		}
	return "";
	}

sub htmlExpanderSetCookie{
	my $temp=$_[0];
	my @arg=@$temp;
	$COOKIE_TO_WRITE{$arg[0]}=$arg[1];
	}


sub htmlExpanderInclude{
	my $temp=$_[0];
	my @arg=@$temp;
	return loadFile($arg[0]);
	}

sub htmlExpanderEnv{
	my $temp=$_[0];
	my @arg=@$temp;
	return $ENV{$arg[0]};
	}

sub htmlExpanderForm{
	my $temp=$_[0];
	my @arg=@$temp;
	return $FORM{$arg[0]};
	}

sub htmlExpanderGetDay{
	my $temp=$_[0];
	my @arg=@$temp;
	return getDay($arg[0],$arg[1],$arg[2]);
	}

sub htmlExpanderMoonAge{
	my $temp=$_[0];
	my @arg=@$temp;
	return int(moonAge(correctDate($arg[0],$arg[1],$arg[2]),$arg[3]));
	$VAR{'CALENDAR'}{'SCH_DAY'}=32;
	}

sub htmlExpanderRokuyou{
	my $temp=$_[0];
	my @arg=@$temp;
	return "".("¬Á∞¬","¿÷∏˝","¿Ëæ°","Õß∞ÅE,"¿Ë…ÅE," ©Ã«")[qreki::get_rokuyou(correctDate(@arg))];
	}

sub htmlExpander24Sekki{
	my $temp=$_[0];
	my @arg;
	my $default="";
	($arg[0],$arg[1],$arg[2],$default)=@$temp;
	return qreki::check_24sekki(@arg) eq ''? $default : "".qreki::check_24sekki(correctDate(@arg));
	}

sub htmlExpanderGetDayText{
	my $text=$_[0];
	$text=~ /(\d+)\D(\d+)\D(\d+)/;
	return getDay($1,$2,$3);
	}

sub htmlExpanderMoonAgeText{
	my $text=$_[0];
	$text=~ /(\d+)\D(\d+)\D(\d+)/;
	return int(moonAge(correctDate($1,$2,$3),12));
	}

sub htmlExpanderRokuyouText{
	my $text=$_[0];
	$text=~ /(\d+)\D(\d+)\D(\d+)/;
	return "".("¬Á∞¬","¿÷∏˝","¿Ëæ°","Õß∞ÅE,"¿Ë…ÅE," ©Ã«")[qreki::get_rokuyou(correctDate($1,$2,$3))];
	}

sub htmlExpander24SekkiText{
	my $text=$_[0];
	$text=~ /(\d+)\D(\d+)\D(\d+)/;
	return qreki::check_24Sekki(correctDate($1,$2,$3));
	}

sub htmlExpanderAlink{
	my $temp=$_[0];
	my @arg=@$temp;
	my $out;
	if($arg[1] eq ''){
		$out=$arg[0];}else{
		$out="<a href='$arg[1]' target='$arg[3]' title='$arg[2]'>$arg[0]<\/a>";}
	return $out;
	}

sub htmlExpanderSaveFormData{
	#•ª•≠•Â•ÅE∆•£°ºæÂ§ŒÃ‰¬Í§«»Ûø‰æ©°£
	my $temp=$_[0];
	my @arg=@$temp;
	my %baseHash=loadCsvHash(loadFile($arg[1]));
	if ($arg[0] eq "TOP"){
		my %temp2=addHashDataTop(\%baseHash,\%FORM);
		saveFile($arg[1],csvOutHash(\%temp2));
		}else{
		my %temp2=addHashDataBottom(\%baseHash,\%FORM);
		saveFile($arg[1],csvOutHash(\%temp2));
		}
	return "";
	}

sub htmlExpanderHead{
	my $temp=$_[0];
	my @arg=@$temp;
	my @temp=@arg;
	shift(@temp);
	my $text=join(' ', @temp);
	return substr($text,0,min2($arg[0],length($text)))." ";
	}

sub htmlExpanderFormMaker{
	my $temp=$_[0];
	my @arg=@$temp;
	return formMakerMain($arg[0],$arg[1]);
	}

sub htmlExpanderTail{
	my $temp=$_[0];
	my @arg=@$temp;
	my @temp=@arg;
	shift(@temp);
	my $text=join(' ', @temp);
	return " ".substr($text,length($text)-min2($arg[0],length($text)),min2($arg[0],length($text)));
	}

sub htmlExpanderDataBase{
	my $temp=$_[1];
	my @arg=@$temp;
	my $text=$_[0];
	my %temp=loadCsvHash(loadFile($arg[1]));
	return dataBasePrinter($text,\%temp,$arg[0]);
}

sub htmlExpanderDataBaseDataList{
	my $temp=$_[1];
	my @arg=@$temp;
	my %hash;
	if($arg[0] =~ /FILE:(.+)/){
		%hash=loadDataList(loadFile($1));
		}else{
		my $temp=$VAR{$arg[0]};
		%hash=%$temp;
		}
	my $baseText=$_[0];
	my $outText="";
	while(my($key,$value)=each(%hash)){
		my $tempText=$baseText;
		$tempText=~ s/{title}/$key/g ;
		$tempText=~ s/{content}/$value/g ;
		$outText=$outText.$tempText;
		}
	return $outText;
	}

sub htmlExpanderLocalTime{
	my $ret=localtime($_[0]);
	return $ret;
	}

sub htmlExpanderGMTime{
	my $ret=gmtime($_[0]);
	return $ret;
	}

sub htmlExpanderTextExToTabList{
	my $temp=$_[0];
	my @arg=@$temp;
	my $text=loadFile($arg[0]);
	my $i=0;
	my $ret="";
	$text =~ s/\r//g ;
	$text =~ s/^\/([^\/\n]+)$/$ret.=$arg[1].$i." ".$1." ";$i++;/meg ;
	return $ret;
	}

sub htmlExpanderTextExToHtml{
	my $temp=$_[0];
	my @arg=@$temp;
	my $text=loadFile($arg[0]);
	$text =~ s/\r//g ;
	$text =~ s/^([^\/\n]+)$/$1<br \/>/mg ;
	$text =~ s/^(\/{1,6})([^\/\n]+)$/"<h".(1,2,3,4,5,6)[length($1)-1].">$2<\/h".(1,2,3,4,5,6)[length($1)-1].">"/meg ;
	return $text;
}

sub htmlExpanderTextExToHtmlSwitch{
	my $temp=$_[0];
	my @arg=@$temp;
#	if($arg[2] eq ""){$arg[2]="";}
	my $text=loadFile($arg[0]);
#$text="/hello\n//First\n///Second\n////Third\n/////Fifth\n//////Sixth\n///////Seventh\n////////Dummy\nWOW";
	$text =~ s/^\/([^\/\n]+)$/\{NEW TAB\}/mg ;
	@text=split(/\{NEW TAB\}/,$text);
	my $out="";
	for(my $i=0;$i<@text;$i++){
		if($VAR{$arg[1]}{$arg[2].$i} eq "1" or $VAR{$arg[1]}{$arg[2].$i} eq "true"){
			$text=$text[$i+1];
			$text =~ s/\r//g ;
			$text =~ s/^([^\/\n]+)$/$1<br \/>/mg ;
			$text =~ s/^(\/{2,7})([^\/\n]+)$/"<h".(1,2,3,4,5,6)[length($1)-2].">$2<\/h".(1,2,3,4,5,6)[length($1)-2].">"/meg ;
			$out.=$text;
			}
		}
	return $out;
	}

sub htmlExpanderCalendar{
	my $temp=$_[1];
	my @arg=@$temp;
	my $text=$_[0];
	my $i=0;
	my $j=1;
	my $wday=(getDay($arg[0],$arg[1])+1)%7-1;
	while($text=~ /\*/){
		if($i<=$wday or $j>(31,29-min2($arg[0]%4,1)+min2($arg[0]%100,1)-min2($arg[0]%400,1),31,30,31,30,31,31,30,31,30,31)[$arg[1]-1]){
			$text=~ s/\*// ;
			}elsif($arg[0]==$TIME{"year"} and $arg[1]==$TIME{"month"} and $j==$TIME{"mDay"}){
			my $baseText=htmlExpanderCalendarSub($arg[3],$arg[0],$arg[1],$j);
			$j++;
			$text=~ s/\*/$baseText/ ;
			}else{
			my $baseText=htmlExpanderCalendarSub($arg[2],$arg[0],$arg[1],$j);
			$j++;
			$text=~ s/\*/$baseText/ ;
			}
		$i++;
		}
	return $text;
	}

sub htmlExpanderCalendarShort{
	my $temp=$_[1];
	my @arg=@$temp;
	my $text=$_[0];
	my $j=$arg[2];
	while($text=~ /\*/){
		my @date=correctDate($arg[0],$arg[1],$j);
		if($arg[0]==$TIME{"year"} and $arg[1]==$TIME{"month"} and $j==$TIME{"mDay"}){
			my $baseText=htmlExpanderCalendarSub($arg[4],@date);
			$j++;
			$text=~ s/\*/$baseText/ ;
			}else{
			my $baseText=htmlExpanderCalendarSub($arg[3],@date);
			$j++;
			$text=~ s/\*/$baseText/ ;
			}
		}
	return $text;
	}


sub htmlExpanderCalendarSub{
	my ($baseText,@arg)=@_;
	$baseText=~ s/{day_m}/$arg[2]/g ;
	$baseText=~ s/{month}/$arg[1]/g ;
	$baseText=~ s/{year}/$arg[0]/g ;
	$baseText=~ s/{day_w_j}/qw(∆ÅE∑ÅE≤– øÅEÃ⁄ ∂ÅE≈⁄)[getDay($arg[0],$arg[1],$arg[2])]/eg ;
	$baseText=~ s/{day_w_e}/qw(Sun Mon Tue Wed Thu Fri Sat)[getDay($arg[0],$arg[1],$arg[2])]/eg ;
	$baseText=~ s/{day_w_ef}/qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)[getDay($arg[0],$arg[1],$arg[2])]/eg ;
	return $baseText;
	}

sub htmlExpanderIf{
	my $temp=$_[1];
	my @arg=@$temp;
	my $text=$_[0];
	if($arg[0]==0){
		return "";
		}else{
		return $text;
		}
	}

sub htmlExpanderShowTab{
	my $temp=$_[0];
	my $retText="";
	my ($titleTabMain,$titleTabActive,$titleTabNegative,$hashName,@tabList)=@$temp;
	for(my $i=0; $i<@tabList/2;$i++){
		my $tempText=(($VAR{$hashName}{$tabList[$i*2]} eq "ACTIVE") or ($VAR{$hashName}{$tabList[$i*2]} == 1))?$VAR{$titleTabMain}{$titleTabActive}:$VAR{$titleTabMain}{$titleTabNegative};
		$tempText =~ s/{title}/$tabList[$i*2+1]/g ;
		$tempText =~ s/{var}/$tabList[$i*2]/g ;
		$retText=$retText.$tempText;
		}
	return $retText;
	}

sub dataBasePrinter{
	my $temp;
	$temp=$_[1];
	my %hash=%$temp;
	my $baseText=$_[0];
	my $text="";
	my @hashKey=keys(%hash);
	my $len=@hash{$hashKey[0]};
	my $start=0;
	my $end=$_[2];
	if($end=~ /(\d+)from(\d+)/){$end=$1+$2;$start=$2;}elsif($end=~ /last(\d+)/){$end=0+@$len;$start=$end-$1;}
	for(my $i=$start; $i<($end==0?0+@$len:min2(0+@$len,$end));$i++){
		my $tempText=$baseText;
		$tempText =~ s/\{\!number\}/$i/g ;
		$tempText =~ s/\{(\w+)\}/$hash{$1}[$i]/g ;
		$text=$text.$tempText;
		}
	return $text;
	}

sub getLocalTime{
	%TIME=getLocalTimeHash(time());
	}

sub getLocalTimeHash{
	my %TIME;
	$TIME{"totalSec"}=$_[0] ;
	($TIME{"sec"}, $TIME{"min"}, $TIME{"hour"}, $TIME{"mDay"}, $TIME{"month"}, $TIME{"year"}, $TIME{"wDay"}, $TIME{"yDay"}, $TIME{"summerTime"}) = localtime($TIME{"totalSec"});
	
	$TIME{"wDayJapanese"}=qw(∆ÅE∑ÅE≤– øÅEÃ⁄ ∂ÅE≈⁄)[$TIME{"wDay"}];
	$TIME{"wDayEnglish"}=qw(Sun Mon Tue Wed Thu Fri Sat)[$TIME{"wDay"}];
	$TIME{"wDayEnglishFull"}=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)[$TIME{"wDay"}];
	
	$TIME{"mDayJapanese"}=qw(À”∑ÅE«°∑ÅEÃÅE∏ ±¨∑ÅEª©∑ÅEøÂÃµ∑ÅE ∏∑ÅEÕ’∑ÅEƒπ∑ÅEø¿Ãµ∑ÅE¡˙∑ÅEø¿≥⁄∑ÅEª’¡ÅE[$TIME{"month"}];
	$TIME{"mDayEnglish"}=qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$TIME{"month"}];
	$TIME{"mDayEnglishFull"}=qw(January February March April May June July August September October November December)[$TIME{"month"}];
	
	$TIME{"year"}+=1900;
	$TIME{"month"}++;
	
	$TIME{"textDateJapanese"}=sprintf("%04d\«Ø%02d\∑ÅE02d\∆ÅE%s\)",$TIME{"year"},$TIME{"month"},$TIME{"mDay"},$TIME{"wDayJapanese"});
	$TIME{"textTimeJapanese"}=sprintf("%02d\ª˛%02d ¨%02d…√",$TIME{"hour"},$TIME{"min"},$TIME{"sec"});
	$TIME{"textDate"}=sprintf("%04d\/%02d\/%02d\/(%s\)",$TIME{"year"},$TIME{"month"},$TIME{"mDay"},$TIME{"wDayEnglish"});
	$TIME{"textTime"}=sprintf("%02d\:%02d:%02d",$TIME{"hour"},$TIME{"min"},$TIME{"sec"});
	
	$TIME{"text"}=localtime($TIME{"totalSec"});
	return %TIME;
	}


sub addHashDataTop{
	my $temp=$_[0];
	my %baseHash=%$temp;
	my $temp=$_[1];
	my %addHash=%$temp;
	foreach my $key(keys %baseHash){
		my $temp2=$baseHash{$key};
		my @temp2=@$temp2;
		unshift (@temp2,$addHash{$key});
		$baseHash{$key}=\@temp2;
		}
	return %baseHash;
	}

sub addHashDataBottom{
	my $temp=$_[0];
	my %baseHash=%$temp;
	my $temp=$_[1];
	my %addHash=%$temp;
	foreach my $key(keys %baseHash){
		my $temp2=$baseHash{$key};
		my @temp2=@$temp2;
		push (@temp2,$addHash{$key});
		$baseHash{$key}=\@temp2;
		}
	return %baseHash;
	}

sub simpleCalc{
	my $text=$_[0];
	while($text=~ /\([^\(\)]+\)/){
		$text=~ s/\(([^\(\)]+)\)/simpleCalc($1)/e ;
		}
	while($text=~ /\-?[\d\.]+\/\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\/(\-?[\d\.]+)/int($1\/$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\%\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\%(\-?[\d\.]+)/int($1%$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\*\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\*(\-?[\d\.]+)/int($1*$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\+\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\+(\-?[\d\.]+)/int($1+$2)/e ;
	}
	while($text=~ /\-?[\d\.]+\-\-?[\d\.]+/){
	$text=~ s/(\-?[\d\.]+)\-(\-?[\d\.]+)/int($1-$2)/e ;
	}
	return $text;
	}

sub getDay{
	(my $year,my $month,my $day)=@_;
	return (($year-int((12-$month)/10)) + int(($year-int((12-$month)/10))/4) - int(($year-int((12-$month)/10))/100) + int(($year-int((12-$month)/10))/400) + int((13*(($month+12-3)%12+3) + 8)/5) + $day) %7;
	}

sub correctDate{
	@arg=@_;
	my @dayOfMonth=(31,31,29-min2($arg[0]%4,1)+min2($arg[0]%100,1)-min2($arg[0]%400,1),31,30,31,30,31,31,30,31,30,31);
	if($arg[1]>=1 and $arg[1]<=12 and $arg[2]>=1 and $arg[2]<=$dayOfMonth[$arg[1]]){
		return @arg;
		}elsif($arg[1]<1){
		$arg[0]-=1;
		$arg[1]+=12;
		}elsif($arg[1]>12){
		$arg[0]+=1;
		$arg[1]-=12;
		}elsif($arg[2]<1){
		$arg[2]+=$dayOfMonth[$arg[1]-1];
		$arg[1]-=1;
		}elsif($arg[2]>$dayOfMonth[$arg[1]]){
		$arg[2]-=$dayOfMonth[$arg[1]];
		$arg[1]+=1;
		}
	return correctDate(@arg);
	}

sub loadCookie{
	my $cookies = $ENV{'HTTP_COOKIE'};
	my @pairs = split(/;/, $cookies);
	foreach my $pair (@pairs) {
		my ($name, $value) = split(/=/, $pair);
		$name =~ s/ //g;
		$COOKIE{$name} = $value;
		}
	}

sub relativeDir{
	$text=$_[0];
	$text=~ s/(.+\/)[^\/]+?$/$1/g;
	return $text;
	}

sub formMakerMain{
	my @arg=@_;
	my $text="";
	my $relativeDir=relativeDir($arg[0]);
	my %formInfo=loadDataList(loadFile($arg[0]));
	my %a=loadCsvHash(loadFile($relativeDir.$formInfo{"form_def"}));
	my %b;
	if($arg[1] eq ""){
		%b=loadDataList(loadFile($relativeDir.$formInfo{"form_type_def"}));
	}else{
		%b=$VAR{$arg[1]};
	}
	return $formInfo{"head"}.formMakerBody(\%a,\%b).$formInfo{"foot"};
	}

sub formMakerBody{
	my $temp;
	$temp=$_[0];
	my %hash=%$temp;
	$temp=$_[1];
	my %data=%$temp;
	my $text="";
	my $len=@hash{'type'};
	for(my $i=0; $i<=@$len;$i++){
		my $tempText=$data{$hash{'type'}[$i]};
		my $addition=($hash{'default'}[$i] eq 'checked' ?"checked " : "").($hash{'default'}[$i] eq 'disabled' ?"disabled" : "");
		$tempText =~ s/{addition}/$addition/g ;
		$tempText =~ s/{(\w+)}/$hash{$1}[$i]/g ;
		$text=$text.$tempText;
		}
	return $text;
	}

sub defaultText{
	if($_[1] eq ""){return $_[0];}else{return $_[1]};
}

sub convertDate{
	my @arg=@_;
	my %dateList=("MONTH",);
	}

#temporary subroutines

sub loadCsv{
	local($text);
	$text=$_[0];
	local(@ret);
	local(@temp);
	local($value);
	local($i);
	local(@temp2);
	
	@temp = split(/\n/, $text);
	for($i=0 ; $i <= $#temp ; $i++ ){
		@temp2= split(/,/, $temp[$i]);

		map { s/\[ENTER\]/\n/ } @temp2;
		map { s/\[COMMA\]/,/ } @temp2;

		@{$ret[$i]}=@temp2;
	}
	return @ret;
}

sub loadCsvHash{
	local($text);
	$text=$_[0];
	local(%ret);
	local(@temp);
	local($value);
	local($i);
	local($j);
	local(@temp2);
	local(@namelist);
	local(%temp3);

	@temp = split(/\n/, $text);
	$temp[0]=~ s/[\r\n]//g;
	@namelist = split(/,/, $temp[0]);

	for( $i=1 ; $i <= $#temp ; $i++ ){
		@temp2= split(/,/, $temp[$i]);
		for( $j=0 ; $j <= $#namelist ; $j++ ){
			$temp2[$j]=~ s/\[ENTER\]/\n/g ;
			$temp2[$j]=~ s/\[COMMA\]/,/g ;			
			
			$ret{$namelist[$j]}[$i-1]="".$temp2[$j];
		}
	}
	return %ret;
}

sub max2{
	return ($_[0]>$_[1]) ? $_[0] : $_[1];
}

sub min2{
	return ($_[0]<$_[1]) ? $_[0] : $_[1];
}


sub loadFile{
	local(@temp);
	open DATA,$_[0];
	flock(DATA, LOCK_EX);
	@temp = <DATA>;
	print <DATA>;
	flock(DATA, LOCK_NB); 
	close DATA;
	return join "",@temp;
}

sub saveFile{
	open DATA,">".$_[0];
	flock(DATA, LOCK_EX);
	print DATA $_[1];
	flock(DATA, LOCK_NB); 
	close DATA;
}

sub deleteSpace{
	local($text);
	$text=$_[0];
	$text =~ s/\s/\[SPACE\]/g ;
	return $text;
	}

sub convertTextCsvSave{
	local($text);
	$text=$_[0];
	$text =~ s/\n/\[ENTER\]/g ;
	$text =~ s/\t/\[TAB\]/g ;
	$text =~ s/,/\[COMMA\]/g ;
	return $text;
}

sub convertTextCsvLoad{
	local($text);
	$text=$_[0];
	$text =~ s/\[ENTER\]/\n/g ;
	$text =~ s/\[TAB\]/\t/g ;
	$text =~ s/\[COMMA\]/,/g ;
	return $text;
}

sub convertTextHtmlOut{
	local($text);
	$text=$_[0];
	$text =~ s/\n/<BR \/>/g ;
	$text =~ s/</&lt;/g ;
	$text =~ s/>/&gt;/g ;
	return $text;
}

sub csvOutEscape{
	my $tempText=$_[0];
 	$tempText=~ s/\n/\[ENTER\]/g ;
 	$tempText=~ s/,/\[COMMA\]/g ;
 	return $tempText;
 	}

sub csvOut{
	my @list;
	my $text;
	my $temp=$_[0];
	@list = @$temp;
	$text="";
	for (my $i=0; $i<= $#list ; $i++){
		for (my $j=0; $j<@{$list[$i]}-1; $j++){
			$text = $text.csvOutEscape($list[$i][$j]).",";
			}
		$text=$text.csvOutEscape($list[$i][@{$list[$i]}-1])."\n";
		}
	return $text;
}

sub csvOutHash{
	my @keylist;
	my $temp=$_[0];
	my %hash=%$temp;
	my $maxlen=0;
	my $text="";
	foreach $key (keys %hash) {
		push(@keylist, csvOutEscape($key));
		my $temp2=$hash{$key};
		$maxlen= @$temp2>$maxlen?@$temp2:$maxlen;
		}
	$text=join(',', @keylist)."\n";
	for(my $j=0;$j<$maxlen;$j++){
		for(my $i=0;$i<$#keylist; $i++){
			$text=$text.csvOutEscape($hash{$keylist[$i]}[$j]).",";
		}
		$text=$text.csvOutEscape($hash{$keylist[$#keylist]}[$j])."\n";
	}
	return $text;
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


sub loadFormGet{
	my $buffer = $ENV{'QUERY_STRING'};
	my @pairs = split(/&/, $buffer);
	foreach $pair (@pairs) {
		my ($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		$FORM{$name} = $value;
	}
}

sub moonAge{
	@arg=@_;
	if ($arg[1] eq ""){$arg[1]=1;}
	if ($arg[2] eq ""){$arg[2]=1;}
	if ($arg[3] eq ""){$arg[3]=12;}
	
	my $jd = timelocal(0,0,$arg[3],$arg[2],$arg[1]-1,$arg[0]) /86400 + 2440587.5; 
	my $kaiki = (($jd-2451550.09765)/29.530589); 
	$kaiki = $kaiki<0?int($kaiki)-1:int($kaiki);
	my $nmoon = 2451550.09765 + 29.530589 * $kaiki + 0.0001337 * (($kaiki/1236.85)**2) - 0.40720 * sin((201.5643 + 385.8169 * $kaiki)*0.017453292519943)+ 0.17241 * sin(( 2.5534 + 29.1054 * $kaiki)*0.017453292519943);
	return $jd-$nmoon<0?$jd-$nmoon+29.530589:$jd-$nmoon;
	}

sub totalDay{
	my @arg=@_;
	my $uruu=-min2($arg[0]%4,1)+min2($arg[0]%100,1)-min2($arg[0]%400,1);
	return $arg[0]*365+int(($arg[0]-1)/4)-int(($arg[0]-1)/100)+int(($arg[0]-1)/400)+$arg[2]+(0,31,60+$uruu,91+$uruu,121+$uruu,152+$uruu,182+$uruu,213+$uruu,244+$uruu,274+$uruu,305+$uruu,335+$uruu,366+$uruu)[$arg[1]-1];
	}

sub makeSimpleIndex{
	my $temp=$_[0];
	my %hash=%$temp;
	my $word=$_[1];
	my %ret;
	for(my $i=0;$hash{$word}[$i] ne "" or $hash{$word}[$i] != 0;$i++){
		$ret{$hash{$word}[$i]}=$i;
		}
	return %ret;
	}

#temorary chat
sub chatWrite{
	if($FORM{"function"} eq "chat"){
		my %temp=("sid",chatWriteEscape($FORM{"sid"}),"name",chatWriteEscape($FORM{"name"}),"time","".localtime(),"comment",chatWriteEscape($FORM{"comment"}));
		my %baseHash=loadCsvHash(loadFile("chat.csv"));
		my %indexHash=makeSimpleIndex(\%baseHash,"sid");
		if ((!exists $indexHash{chatWriteEscape($FORM{"sid"})})and($FORM{"comment"}ne"")){
			my %temp2=addHashDataBottom(\%baseHash,\%temp);
			saveFile("chat.csv",csvOutHash(\%temp2));
			}
		}
	}

sub chatWriteEscape{
	my $temp=$_[0];
	$temp =~ s/&/&at;/g ;
	$temp =~ s/\n/\<br\>/g ;
#	$temp =~ s/\n//g ;
	$temp =~ s/\r//g ;
	$temp =~ s/</&lt;/g ;
	$temp =~ s/\>/&gt;/g ;
	$temp =~ s/"/&quot;/g ;
	return $temp;
	}


1