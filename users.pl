#!bin/perl

use warnings;
use strict;
use diagnostics;
use feature 'say';
use feature 'switch';
use Tk;
use Tk::LabEntry;

use List::Util qw( min max );

my $args_num=0;
$args_num=scalar(@ARGV);
#print $args_num;

my $mode;
my $pass;
my $pass_len;
my $user;
my $uid;
my $result;
my $filename;
my $entire;
my @uids;
my $message;
my $home;
my $gid;
my $gidnum;
my $groups;

my $option;
if ($args_num < 3 && $ARGV[0] ne "-g")
{
print "Tryby dzialania: -t tekstowy, -g graficzny \n 
Skrypt uzytkownicy. Dostepne opcje: \n 
-a dodanie uzytkownika args nazwa uzytkownika uid  \n
-ac sprawdzanie uid \n
-al dodanie do tworzonego konta losowego hasla \n
-as zapisanie danych do wybranego pliku \n
-m modyfikowanie grup uzytkownika agrs nazwa uzytkownika \n
-ms modyfikowanie shella
-mh modyfikowanie home directory
-mg zmiana grupy glownej
-mG modyfikowanie grup dodatkowych - grupy po przecinku!!!
-mu zmiana uid uzytkownika
-d usuwanie konta args: nazwa konta \n
-c Kopiowanie plikow kropkowych z podanego katalogu do home directory uzytkownika args: nazwa uzytkownika katalog 
-l zmiana hasla istniejacego uzytkownika na losowe \n"
;

}
else
{
	$mode=$ARGV[0];
	local $/;
	open(my $passfile, "<", "/etc/passwd")
	or die "Nie mozna otworzyc pliku: $!";
	$entire=<$passfile>;
	#print $entire;
	my @lines=split('\n',$entire);
	for (my $i=0; $i<scalar(@lines);$i++)
	{
		my @row=split(':',$lines[$i]);
		$uids[$i]=$row[2];
		
	}
	
	if ($mode eq "-t")
	{

		print "Tryb tekstowy \n";
		$option=$ARGV[1];
		#print index($option,"a");
		if (index($option,"a") ==1 && index($option,"-") == 0)
		{
			
			if ($args_num>=4)
			{	
				my %ids = map { $_ => 1 } @uids;
				if(exists($ids{$ARGV[3]}))
				{
					print "B³¹d! Podany id jest juz zajety \n";
					my $max= max(@uids) +1;
					print "Proponuje uzyc uid $max \n";
					exit;
				}
						$result=system ("useradd $ARGV[2] -u $ARGV[3] -m");
						#system ("echo $ARGV[2]:$pass | chpasswd");
						if (index($result,"2304") ==-1 && index($result,"1024") ==-1)
						{
							print "Utworzono uzytkownika $ARGV[2] z uid $ARGV[3] \n";
							$user=$ARGV[2];
							$uid=$ARGV[3];
							
							if(index($option,"l") !=-1)
							{
								$pass_len= int(rand(5))+6;
								my @letters=('A'..'Z','a'..'z');
								my $total=@letters;
								#print $pass_len;
								for  (my $i=0; $i<$pass_len;$i++)
								{
									if (rand()>0.5)
									{
									 $pass.=$letters[int (rand(scalar(@letters)))];
									}
									else
									{	
										$pass.=int(rand(10));
									}
								}
								system ("echo $user:$pass | chpasswd");
								print "Wygenerowano i ustawiono losowe haslo $pass dla uzytkownika $user \n";
							}
							
							if(index($option,"s") !=-1)
							{
								if ($args_num>=5)
								{
								$filename=$ARGV[4];
								open (my $writer, ">", "$filename")
								or die "Nie mo¿na otworzyæ pliku: $!";
								print $writer "Nazwa: ".$user;
								print $writer " UID: ".$uid;
								print $writer " Haslo: ".$pass;
								print "Zapisano dane do pliku $filename \n";
								}
								else
								{
									print "Blad! Nie zapisano danych do pliku! Za malo argumentow! \n";
									exit;
								}
						
							}
						}
						else
						{
							print "Uzytkownik $ARGV[2] juz istnieje lub uid $ARGV[3] jest juz zajete\n";
							exit;
						}
			}
		}
		elsif ($option eq "-d")
		{
			system ("userdel $ARGV[2]");
			print "Usunieto uzytkownika $ARGV[2] \n";
			
		}
		elsif ($option eq "-c")
		{
			my $home_dir;
			my @temp;
			$result=`getent passwd $ARGV[2]`;
			@temp=split(':',$result);
			$home_dir=$temp[5];
			if (-d $ARGV[3])
			{
			print $home_dir;	
			system ("cp $ARGV[3].[a-zA-Z0-9]* $home_dir");
			#print "Usunieto uzytkownika $ARGV[2] \n";
			}
			else
			{
				print "Nie ma takiego katalogu! \n";
				exit;
			}
			
		}
		elsif (index($option,"l") ==1 && index($option,"-") == 0)
		{
			$pass_len= int(rand(5))+6;
			my @letters=('A'..'Z','a'..'z');
			$user=$ARGV[2];
			my $total=@letters;
			#print $pass_len;
			for  (my $i=0; $i<$pass_len;$i++)
			{
				if (rand()>0.5)
				{
					 $pass.=$letters[int (rand(scalar(@letters)))];
				}
				else
				{	
					$pass.=int(rand(10));
				}
			}
			system ("echo $user:$pass | chpasswd");
			print "Wygenerowano i ustawiono losowe haslo $pass dla uzytkownika $user \n";
		}
		
		elsif (index($option,"s") ==1 && index($option,"-") == 0)
		{
			if ($args_num==4)
			{
				$user= $ARGV[2];
				$result=`getent passwd $user`;
				$filename=$ARGV[3];
				my @temp=split(':',$result);
				$uid=$temp[2];
				open (my $writer, ">", "$filename")
				or die "Nie mo¿na otworzyæ pliku: $!";
				print $writer "Nazwa: ".$user;
				print $writer " UID: ".$uid;
				print $writer " Haslo: ".$pass;
				print "Zapisano dane do pliku $filename \n";
			}
			else
			{
				print "Blad! Nie zapisano danych do pliku! Za malo argumentow! \n";
				exit;
			}
						
		}
		elsif  (index($option,"m") ==1 && index($option,"-") == 0)
		{	
			$user=$ARGV[2];
			#print "$user \n";
			my $position=3;
			my $shell;
			my $home;
			my $main_group;
			my $groups;
				
			if  (index($option,"s") !=-1)
			{		
				$shell=$ARGV[1+index($option,"s")];
				#print "$shell";
				system("usermod -s $shell $user");
				if ($? != 0)
				{ print "Wystapil blad przy zmianie powloki na: $shell dla usera: $user! \n"; 
					exit;	
				}
				print $position;				
			}
			if  (index($option,"h") !=-1)
			{		
			
				$home=$ARGV[1+index($option,"h")];
				#print "$home";
				system("usermod -m -d $home $user");
				if ($? != 0)
				{ print "Wystapil blad przy zmianie katalogu domowego: $home dla usera: $user! \n"; 
					exit;	
				}			
			}
			if  (index($option,"g") !=-1)
			{		
			
				$main_group=$ARGV[1+index($option,"g")];
				system("usermod -g $main_group $user");
				if ($? != 0)
				{ print "Wystapil blad przy zmianie grupy glownej na: $main_group dla usera: $user! \n"; 
					exit;	
				}
			
			}
			if  (index($option,"G") !=-1)
			{		
			
				$groups=$ARGV[1+index($option,"G")];
				#print "$groups";
				system("usermod -G $groups $user");
				if ($? != 0)
				{ print "Wystapil blad przy zmianie grup na: $groups dla usera: $user! \n"; 
					exit;	
				}
			
			}
			if  (index($option,"u") !=-1)
			{		
				
				my $new_id=$ARGV[1+index($option,"u")];
				print "$new_id";
				my %ids = map { $_ => 1 } @uids;
				if(exists($ids{$new_id}))
				{
					print "B³¹d! Podany id jest juz zajety \n";
					my $max= max(@uids) +1;
					print "Proponuje uzyc uid $max \n";
					exit;
				}
				system("usermod -u $new_id $user");			
			}		
		}
		
	}
	if ($mode eq "-g")
	{	my $key;
		my $r_option;
		my %options;
		my %rh;
		my $selected_user;
		
		%options = ( 'Dodaj uzytkownika' => '-a',
			     'Zmien istniejace uzytkownika' => '-m',
			     'Usun uzytkownika' => '-d');
				
		my $mw = MainWindow->new;
		my $dw;
		my $aw;	
		my $modw;
		
   		 $mw->Label(-text => 'Skrypt uzytkownicy! Wybierz co chcesz zrobic ')->pack;
		foreach $key (sort keys %options) {
		$rh{$key} = $mw->Radiobutton(-text     => $key,
                                 -anchor   => "w",
                                 -variable => \$r_option,
                                 -value    => $options{$key}
                                 )->pack;
    		$rh{$key}->pack(-fill => 'x');
			}
	

    		$mw->Button(-text => 'Wybierz',
			 	-command => sub{ 	if ($r_option eq "-d")
							{	
								delete_user($mw);	
							}
							elsif ($r_option eq "-a")
							{
								add_user($mw);
							}
							else
							{
								modify_user($mw);
							}	}) -> pack;
		$mw->Button(
        		-text    => 'Wyjdz',
        		-command => sub { exit },
  			  )->pack;

    			MainLoop;

		sub delete_user
		{
			$dw=MainWindow->new(-title=>"Usuwanie uzytkownikow");
			$dw->title("Usuwanie uzytkownikow");
			$_[0]->destroy;	
			my @user_uids;
		local $/;
		open(my $passfile, "<", "/etc/passwd")
		or die "Nie mozna otworzyc pliku: $!";
		$entire=<$passfile>;
		#print $entire;
		my @lines=split('\n',$entire);
		for (my $i=0; $i<scalar(@lines);$i++)
		{
			my @row=split(':',$lines[$i]);
			$user_uids[$i]=$row[0]." (uid: ".$row[2].") ";
		
		}
			
		my $lb=$dw->Scrolled("Listbox", -selectmode => "single",
					-listvariable =>\@user_uids)->pack();
		
			$dw->Label(-textvariable => \$message)->pack();
			$dw->Button(
        		-text    => 'Usun wybranego uzytkownika',
        		-command => sub {  #$selected_user=$lb->get( $lb->curselection );
						$user=$lb->get( $lb->curselection );
						print $lb->curselection;	
						my $number= $lb->index($lb->curselection);
						my $temp=index($user,"(");
						$user=substr($user, 0, $temp-1);
						$result=system ("userdel $user");
						if ($result == 0)
						{
							$message="Usunieto uzytkownika $user";
							splice(@user_uids, $number, 1);	
						} 
						else 
						{
							$message="Usuniecie uzytkownika $user nie powiod³o sie";
						}
						
  			  })->pack;
		$dw->Button(
        		-text    => 'Wyjdz',
        		-command => sub { exit },
  			  )->pack;	
		}
		
		sub add_user
		{
			my $home;
			my $var;

			local $/;
			open(my $passfile, "<", "/etc/passwd")
			or die "Nie mozna otworzyc pliku: $!";
			$entire=<$passfile>;
			#print $entire;
			my @lines=split('\n',$entire);
			for (my $i=0; $i<scalar(@lines);$i++)
			{
				my @row=split(':',$lines[$i]);
				$uids[$i]=$row[2];	
			}
			
			$aw=MainWindow->new(-title=>"Usuwanie uzytkownikow");
			$aw->title("Dodawanie uzytkownikow");
			$aw->geometry( "800x600" );
			$_[0]->destroy;	
		
			my $userbox=$aw->LabEntry(-label  => "Nazwa uzytkownika",
					      -textvariable => \$user)->pack;
			my $uidbox=$aw->LabEntry(-label  => "User ID",
					      -textvariable => \$uid)->pack;
			my $passbox=$aw->LabEntry(-label  => "Haslo", -show=> '*',
					      -textvariable => \$pass)->pack;
			 my $random = $aw->Checkbutton (
			-text => "Losowe haslo",
        			-variable => \$var,
        		-onvalue  => 'yes',
        		-offvalue => 'no'   )->pack;
			my $homebox=$aw->LabEntry(-label  => "Katalog domowy",
					      -textvariable => \$home)->pack;

			local $/;
			open(my $shellfile, "<", "/etc/shells");
			
			$entire=<$shellfile>;
			my @shells;
			#print $entire;
			my @lines=split('\n',$entire);
			for (my $i=1; $i<scalar(@lines);$i++)
			{
			my @row=split(':',$lines[$i]);
			$shells[$i-1]=$lines[$i];
		
			}
			$aw->Label(-text=>"Wybor powloki")->pack();
			my $ls=$aw->Scrolled("Listbox", -selectmode => "single",
					-listvariable =>\@shells)->pack();
			$ls->selectionSet(0);
			my $saving="no";
			my $save = $aw->Checkbutton (
			-text => "Zapisz do pliku",
        			-variable => \$saving,
        		-onvalue  => 'yes',
        		-offvalue => 'no'   )->pack;
			my $path;
			my $filebox=$aw->LabEntry(-label  => "Sciezka zapisu",
					      -textvariable => \$path)->pack;

			my $add_button=$aw->Button(
        		-text    => 'Dodaj uzytkownika',
        		-command => sub {
			if ( defined $user && defined $uid)
			{ 		

				my %ids = map { $_ => 1 } @uids;
				if(exists($ids{$uid}))
				{
					
					my $max= max(@uids) +1;
					$aw->messageBox(-type => "Ok",-message=> 						"Blad! Uid: $uid jest juz 						zajety. Proponuje uzyc: $max! ",-title=>"Blad");
				return;
				}
				

				if ($var eq "yes")
				{
					$pass_len= int(rand(5))+6;
					my @letters=('A'..'Z','a'..'z');
					my $total=@letters;
					#print $pass_len;
					for  (my $i=0; $i<$pass_len;$i++)
					{
						if (rand()>0.5)
						{
							 $pass.=$letters[int (rand(scalar(@letters)))];
						}
						else
						{	
							$pass.=int(rand(10));
						}
					}	
				}
				print "tworze";
				my $shell=$ls->get( $ls->curselection);
				my $command;
				$command="useradd $user -u $uid -m ";
				if (defined $home)
				{$command.="-d $home ";}
				if (defined $shell)
				{$command.="-s $shell";}
				print $command;
				my $writer;
				my $code;
				
				if ($saving eq "yes")
				{
						if (defined $path)
						{
							$code=open ($writer, ">", "$path");
							if ($code!=1)
							{$aw->messageBox(-type => "Ok",-message=>  "Nie mozna stworzyc pliku $path. Sprawdz czy nazwa poprawna!" ,-title=>"Blad");
							return;}
						}
						else
						{
							$aw->messageBox(-type => "Ok",-message=>  "Nie udalo sie zapisac danych do pliku $path. Sprawdz czy nazwa poprawna!" ,-title=>"Blad");
							return;
						}
				}
				$result=system ("$command");
				
				if ($result != 0)
				{
					$aw->messageBox(-type => "Ok",-message=> 						"Blad! Nie udalo sie stworzyc uzytkownika $user o uid $uid ",-title=>"Blad");
				}
				else 
				{
					if (defined $pass)
					{
						system ("echo $user:$pass | chpasswd");
					}
					$aw->messageBox(-type => "Ok",-message=> 						"Udalo sie stworzyc uzytkownika $user o uid $uid. Haslo: $pass",-title=>"Sukces");
					
					if ($saving eq "yes")
					{
								print $writer "Nazwa: ".$user;
								print $writer " UID: ".$uid;
								print $writer " Haslo: ".$pass;
								$aw->messageBox(-type => "Ok",-message=> 						"Zapisano dane do pliku $path",-title=>"Sukces");
					}
					exit;

				}

				}
			else 
			{
				$aw->messageBox(-type => "Ok",-message=> "Blad! Podaj nazwe uzytkownika i uid",-title=>"Blad");
			}
 			},
  			  )->pack();	
		
			$aw->Button(
        		-text    => 'Wyjdz',
        		-command => sub { exit },
  			  )->pack();	
		}
		
		sub modify_user
		{
			$modw=MainWindow->new(-title=>"Modyfikowanie uzytkownikow");
			$modw->title("Modyfikowanie uzytkownikow");
			$_[0]->destroy;	
			my $shell;
			my @user_uids;
			my $message;
			my $directory;
			my $startgroups;
			$modw->geometry( "1100x900" );
			local $/;
			open(my $passfile, "<", "/etc/passwd")
			or die "Nie mozna otworzyc pliku: $!";
			$entire=<$passfile>;
			#print $entire;
			my @lines=split('\n',$entire);
			for (my $i=0; $i<scalar(@lines);$i++)
			{
				my @row=split(':',$lines[$i]);
				$user_uids[$i]=$row[0]." (uid: ".$row[2].") ";
				$uids[$i]=$row[2];
			}
			$modw->Label(-text=>"Wybor uzytkownika")->grid(-column=>0,-row=>0);
			$modw->Label(-textvariable => \$message)->grid(-column=>2,-row=>1);
			$message="Uzytkownik: $user \n Katalog domowy:  \n Powloka:  \n Grupa glowna: \n Inne grupy: \n";
			my $lb=$modw->Scrolled("Listbox", -selectmode => "single",
						-listvariable =>\@user_uids)->grid(-column=>0,-row=>1);
			my $starthome;
			$modw->Button(
        		-text    => 'Wyswietl szczegoly',
        		-command => sub { 
			$user=$lb->get( $lb->curselection );
			my $temp=index($user,"(");
			$user=substr($user, 0, $temp-1);
			$gid=`getent passwd $user`;
			my @temp=split(':',$gid);
			$gidnum=$temp[3];
			$home=$temp[5];
			$shell=$temp[6];
			$groups=`groups $user`;
			@temp=split(':',$groups);
			$groups=$temp[1];
			@temp=split(" ",$groups);
			$groups="";
			my $key;
			foreach (@temp)
			{
				$groups.=$_.",";
			}
			$groups =substr ($groups,0,-1);
			$startgroups=$groups;

			$gid=$gidnum." - ".`id -gn $gidnum`;
			$starthome=$home;
			$message="Uzytkownik: $user \n Katalog domowy: $home \n Powloka: $shell  Grupa glowna: $gid  Wszytskie grupy: $groups\n";
				},
  			  )->grid(-column=>1,-row=>1);
			
			my $maingroup;
			my $uidbox=$modw->LabEntry(-label  => "Zmiana uid",
					      -textvariable => \$uid)->grid(-column=>0,-row=>2);
			my $gidbox=$modw->LabEntry(-label  => "Zmiana grup",
					      -textvariable => \$groups)->grid(-column=>1,-row=>2);
			my $homebox=$modw->LabEntry(-label  => "Zmiana Katalogu domowego",
					      -textvariable => \$home)->grid(-column=>2,-row=>2);
			#$modw->Label(-text=>"Zmiana powloki")->pack();
			local $/;
			open(my $shellfile, "<", "/etc/shells");
			
			$entire=<$shellfile>;
			my @shells;
			#print $entire;
			my @lines=split('\n',$entire);
			for (my $i=1; $i<scalar(@lines);$i++)
			{
			my @row=split(':',$lines[$i]);
			$shells[$i-1]=$lines[$i];
			}
			$modw->Label(-text=>"Zmiana powloki")->grid(-column=>0,-row=>3);
			my $passbox=$modw->LabEntry(-label  => "Nowe haslo",-show=> '*',
					      -textvariable => \$pass)->grid(-column=>1,-row=>3);
			my $coping;
			my $copy = $modw->Checkbutton (
			-text => "Kopiuj pliki kropkowe do z wybranego katalogu do katalogu domowego",
        			-variable => \$coping,
        		-onvalue  => 'yes',
        		-offvalue => 'no'   )->grid(-column=>1,-row=>5);
			my $draw;
			my $random = $modw->Checkbutton (
			-text => "Losowe haslo",
        			-variable => \$draw,
        		-onvalue  => 'yes',
        		-offvalue => 'no'   )->grid(-column=>1,-row=>6);
			my $directorybox=$modw->LabEntry(-label  => "Siezka zrodlowa",
					      -textvariable => \$directory)->grid(-column=>1,-row=>4);
			my $ls=$modw->Scrolled("Listbox", -selectmode => "single",
					-listvariable =>\@shells)->grid(-column=>0,-row=>4);
			$ls->selectionSet(0);

			local $/;
			open(my $groupfile, "<", "/etc/group")
			or die "Nie mozna otworzyc pliku: $!";
			$entire=<$groupfile>;
			#print $entire;	
			my @groups;
			my @gids;
			my @lines=split('\n',$entire);
			for (my $i=0; $i<scalar(@lines);$i++)
			{
				my @row=split(':',$lines[$i]);
				$groups[$i]=$row[0]." (gid: ".$row[2].") ";
				$gids[$i]=$row[2];
			
			}
			$modw->Label(-text=>"Zmiana grupy glownej")->grid(-column=>2,-row=>3);
			my $lg=$modw->Scrolled("Listbox", -selectmode => "single",
					-listvariable =>\@groups)->grid(-column=>2,-row=>4);
			$lg->selectionSet(0);

			#system("usermod -g $main_group $user");
			$modw->Button(
        		-text    => 'Modyfikuj',
        		-command => sub {
			#print $user;
			if (not defined $user)
			{
				$modw->messageBox(-type => "Ok",-message=>  "Nie wybrano uzytkownika",-title=>"Blad");
			}	

			if (defined $pass || $draw eq "yes")
			{
				if ($draw eq "yes")
				{
					$pass_len= int(rand(5))+6;
					my @letters=('A'..'Z','a'..'z');
					my $total=@letters;
					#print $pass_len;
					for  (my $i=0; $i<$pass_len;$i++)
					{
						if (rand()>0.5)
						{
							 $pass.=$letters[int (rand(scalar(@letters)))];
						}
						else
						{	
							$pass.=int(rand(10));
						}
					}
				}
				$result=system("echo $user:$pass | chpasswd");
				if ($result == 0)
				{
					$modw->messageBox(-type => "Ok",-message=> "Sukces! Pomyslnie zmieniono haslo uzytkownika $user na $pass",-title=>"Sukces");
				}
				else
				{
					$modw->messageBox(-type => "Ok",-message=> "Blad! Zmiana hasla dla uzytkownika $user nie powiodla sie",-title=>"Blad");
				return;	
				}
			}
			if (defined $uid)
			{
				my %ids = map { $_ => 1 } @uids;
				if(exists($ids{$uid}))
				{
					my $max= max(@uids) +1;
					$modw->messageBox(-type => "Ok",-message=> "Blad! Uid: $uid jest juz zajety. Proponuje uzyc: $max! ",-title=>"Blad");
				return;
				}
				else
				{$modw->messageBox(-type => "Ok",-message=> "Sukces! Pomyslnie zmieniono uid uzytkownika $user na $uid",-title=>"Sukces");}
			}
			if (defined $home && $starthome ne $home)
			{
				$result=system("usermod $user -m -d $home");
				print $result;
				if ($result == 0)
				{
					$modw->messageBox(-type => "Ok",-message=> "Sukces! Zmieniono katalog domowy na $home dla uzytkownika $user",-title=>"Sukces");
				}
				else
				{
					$modw->messageBox(-type => "Ok",-message=> "Blad! Zmieniana katalogu  domowy na $home dla uzytkownika $user nie powiodla sie",-title=>"Blad!");
				}
			}
			if ($lg->curselection ne "")
			{$maingroup=$gids[$lg->index($lg->curselection)];}
			if (defined $maingroup)
			{
					print $maingroup;
					$result=system("usermod $user -g $maingroup");
				print $result;
				if ($result == 0)
				{
					$modw->messageBox(-type => "Ok",-message=> "Sukces! Zmieniono grupe glowna na $maingroup dla uzytkownika $user",-title=>"Sukces");
				}
				else
				{
					$modw->messageBox(-type => "Ok",-message=> "Blad! Zmiana grupy glownej na  $maingroup dla uzytkownika $user nie powiodla sie",-title=>"Blad!");
				}		
			}

			if (defined $groups && $startgroups ne $groups)
			{
				$result=system("usermod $user -G $groups");
				print $result;
				if ($result == 0)
				{
					$modw->messageBox(-type => "Ok",-message=> "Sukces! Zmieniono grupy uzytkownika  na $groups dla uzytkownika $user",-title=>"Sukces")
				}
				else
				{
					$modw->messageBox(-type => "Ok",-message=> "Blad! Zmienia grup na na $groups dla uzytkownika $user nie powiodla sie",-title=>"Blad!");
				}
			}		
			if ($coping eq "yes")
			{
				if (-d $directory)
				{
					$result=system ("cp $directory/.[a-zA-Z0-9]* $home");
					if ($result == 0)
					{
					$modw->messageBox(-type => "Ok",-message=> "Sukces! Pomyslnie skopiowano pliki z  $directory do katalogu domowego: $home uzytkownika $user",-title=>"Sukces");
					}
					else 
					{$modw->messageBox(-type => "Ok",-message=> "Blad! Katalog $directory jest niepoprawny. Sprawdz czy nazwa poprawna",-title=>"Blad");
				return;}
				
				}
				else
				{$modw->messageBox(-type => "Ok",-message=> "Blad! Katalog $directory jest niepoprawny. Sprawdz czy nazwa poprawna",-title=>"Blad");
				return;}		
			}
			 },
  			  )->grid(-column=>1);				
			$modw->Button(
        		-text    => 'Wyjdz',
        		-command => sub { exit },
  			  )->grid(-column=>1);	

		}

	}	
}
