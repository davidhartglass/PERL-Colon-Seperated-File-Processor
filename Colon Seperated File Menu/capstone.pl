#!/usr/bin/perl
#
#

system("clear");
$menuString = "\n\nMENU
\n========================\n
(p,P) Print users info\n
(a,A) Add new user\n
(s,S) Search user\n
(d,D) Delete user\n
(f,F) Display records by year\n
(x,X) Exit\n\n
Enter your choice: ";


$fileName = $ARGV[0];


if(@ARGV){

	print($menuString);
	$choice = <STDIN>;
	chomp($choice);

	while($choice ne "x" and $choice ne "X"){

		unless(-e $fileName){
			open my $fc, ">", $fileName;
			close $fc;
		}

		if($choice eq "p" or $choice eq "P"){
			printUsers();
			print($menuString);
			$choice = <STDIN>;
			chomp($choice);

		}

		elsif($choice eq "a" or $choice eq "A"){
			addUser();
			print($menuString);
			$choice = <STDIN>;
			chomp($choice);

		}

		elsif($choice eq "s" or $choice eq "S"){	
			searchUser();
			print($menuString);
			$choice = <STDIN>;
			chomp($choice);

		}

		elsif($choice eq "d" or $choice eq "D"){
			deleteUser();	
			print($menuString);
			$choice = <STDIN>;
			chomp($choice);
		}
		elsif($choice eq "f" or $choice eq "F"){
			searchUserByYear();
			print($menuString);
			$choice = <STDIN>;
			chomp($choice);

		}
		else{
			print("Invalid choice, please try again");
			print($menuString);
			$choice = <STDIN>;
			chomp($choice);
		}
	}
}
else{
	print "\nERROR: Must provide a filename\n";
}




#------------------------------------------------------------------------------------------------
#                                           Sub Routines                                        |
#------------------------------------------------------------------------------------------------

sub addUser{
	open(my $fh, '>>', $fileName) or die "Could not open file '$fileName' $!";

	print("Enter first name: ");
	my $enteredFirstName = <STDIN>;
	chomp($enteredFirstName);

	print ("Enter last name: ");
	my $enteredLastName = <STDIN>;
	chomp ($enteredLastName);
	
	print ("Enter occupation: ");
	my $occupation = <STDIN>;

	my $firstFourLetters = substr($enteredLastName, 0, 4);

	my $letter = substr($enteredFirstName, 0, 1);
	my $userName = uc($letter . $firstFourLetters);

	open(my $fileRead, '<:encoding(UTF-8)', $fileName) or die "Could not open file '$fileName' $!";

	while(my $line = <$fileRead>){
		chomp($line);
		my @Fields =  split /:/, $line;

		if(grep $_ eq $userName, @Fields){
			$userName = $userName . "1";
			chomp($userName);
		}
	}

	my $capFN = uc $enteredFirstName;
	my $capLN = uc $enteredLastName;
	my $capUN = uc $userName;
	my $capOC = uc $occupation;
	
	chomp($capFN);	
	chomp($capLN);	
	chomp($capUN);
	chomp($capOC);

	if (($capFN =~ /\b[A-Z]+\b/i) and ($capLN =~ /\b[A-Z]+\b/i)and ($capFN ne "") and ($capLN ne "")){
		$date = `date +%F`;
		chomp($date);
		print $fh "$capFN:$capLN:$capUN:$capOC:$date\n";	
	}
	else{
		print "Invalid characters in first name/last name\n";
	}
	close($fh);	
}

sub deleteUser{
	print("Enter first name of user to delete: ");
	my $name = <STDIN>; 
	chomp($name);

	while($name eq "" or $name eq undef or $name eq "\n"){
		print "INVALID NAME: \"$name\" please enter a valid first name: ";
		$name = <STDIN>;
		chomp($name);
	}	

	$name = uc $name;

	open(my $fh, '<', $fileName) or die "Could not open file '$fileName' $!";
	@Lines = <$fh>;
	close($fh);

	open(my $fh, '>', $fileName) or die "Could not open file '$fileName' $!";
	foreach (@Lines){
#			print $fh $_ unless ($_ =~ /^$name/i);
		if($_ =~ /^$name\:(\w)*\:(\w)*/i){

		}
		else{
			print $fh $_;
		}
	}	
	close($fh); 
}

sub searchUser{
	open(my $fh, '<:encoding(UTF-8)', $fileName)
		or die "Could not open file '$fileName' $!";

	print("Enter a first name to search for: ");
	$nameToFind = <STDIN>;
	chomp($nameToFind);

	printf "\nUsername\tFirst Name\tLast Name\tOccupation\t\t\t    Date Entered\n";
	print("------------------------------------------------------------------------------------------------\n");

	while(my $line = <$fh>){

		chomp($line);

		if($line =~ /^$nameToFind\:(\w)*\:(\w)*(\d)*\:/i){
			my @fields = split /:/, $line;
			printf("%-15s %-15s %-15s %-35s %-15s\n" , $fields[2], $fields[0], $fields[1], $fields[3], $fields[4]);
		}
	}
	close($fh);	

}

sub printUsers{
	open(my $fh, '<:encoding(UTF-8)', $fileName)
		or die "Could not open file '$fileName' $!";

	printf "\nUsername\tFirst Name\tLast Name\tOccupation\t\t\t\t      Date Entered\n";
	print("----------------------------------------------------------------------------------------------------------\n");

	my @lines = <$fh>;
	my  @sortedLines = sort {(split (/:/,$a))[2] cmp (split(/:/,$b))[2]} @lines;

	foreach(@sortedLines){
		chomp($_);
		my @splitFields = split /:/, $_;

		my $username = uc $splitFields[2];
		my $firstName = uc $splitFields[0];
		my $lastName = uc $splitFields[1];
		my $timeStamp = uc $splitFields[4];
		my $jobTitle = uc $splitFields[3];
		printf("%-15s %-15s %-15s %-45s %-15s\n", $username, $firstName, $lastName, $jobTitle, $timeStamp);

	}
	close($fh);	
}

sub searchUserByYear{
	open(my $fh, '<:encoding(UTF-8)', $fileName)
		or die "Could not open file '$fileName' $!";

	print("Enter a year to search for (Format YYYY): ");
	$year = <STDIN>;
	chomp($year);

	if($year =~ /\d\d\d\d/){
		chomp($line);
		print("\n$year Records\n--------------------------------------------------------------------------------------\n");
			
		while(my $line = <$fh>){
			if($line =~ /$year/i){
				my @fields = split /:/, $line;
				chomp($fields[4]);
				printf("%-15s %-15s %-15s %-15s %-15s\n" ,$fields[4], $fields[0], $fields[1], $fields[2], $fields[3]);
			}
		}
	}
	else{
		print "\nInvalid Year \"$year\"";
	}
	close($fh);	
}

