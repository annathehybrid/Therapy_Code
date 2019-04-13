#!/usr/bin/env perl
use strict;
use warnings;

# this script will calculate how many minutes of therapy each therapist gave
# and classify the type of therapy to its insurance type
#
# the inputs are a csv file with:
# 	Patient name (not needed)
#	Disc (not needed, it shows the job description)
#	Payer source (this shows which kind of insurance the patient gets)
#	Therapist (therapist's name)
#	Minutes
#	Units (where the patient's room is?)
#
# the outputs are a csv file with:
# 	Therapist name
#	Minutes worked, with columns of insurance

# open the raw csv file from therapist
my $filename_raw = 'anna.csv';
open (my $csv, '<', $filename_raw) || die "cant open the raw file";


# read the entire csv file into an array
# split by new line
my @data;
foreach (<$csv>) {
	chomp;
	push @data, split(/\n/);
};
close ($filename_raw);

# we should check where in the array our relevant data elements are
my $number_therapist_name = 0;
my $number_minutes_worked = 0;
my $number_insurance = 0;

# this function will find the relevant column for the outputs we want
# it will go to the headers, split them, and assign numeric header values to the therapist name, minutes worked, and insurance
# the headers should be on line 4
# print "$data[4]";
my @headers = split (/\,/, $data[4]);


my $count = 0;
foreach my $item (@headers) {
	if ($item =~ "Therapist") {
		$number_therapist_name = $count;
		#print "yay it's $item and $count!\n";
	};
	
	if ($item =~ "Minutes") {
		$number_minutes_worked = $count;
		#print "yay it's $item and $count!\n";
	};

	if ($item =~ "Payer Source") {
		$number_insurance = $count;
		#print "yay it's $item and $count!\n";
	};	
	
	$count = $count + 1;
};


# output the relevant data onto an array called data_with_relevant_information
# when we split this one, the therapist name (Last name, first name) will be split again, which pushes the minutes worked one place
# make a new array with just the relevant columns
# header is line 4, so we have to start from line 5 of data array
# also check that we're not going into blank or totals
my @data_with_relevant_information;
my @data_cells;
for (my $i = 5; $i < (scalar(@data)); $i++) {
# if there is actually stuff on the line

	if (length ($data[$i]) > 25) {
	#split the line by comma
		my @data_cells = split (/\,/, $data[$i]);
		# push in therapist name, insurance type, and minutes worked
		my $therapist_name = join (',', $data_cells[$number_therapist_name], $data_cells[$number_therapist_name + 1]);
		my $relevant_information = 
			join(',',
			$therapist_name,
			$data_cells[$number_insurance],
			$data_cells[$number_minutes_worked + 1]);
			
		push @data_with_relevant_information, $relevant_information;

	};
};



my $medicare_a = 0;
my $medicare_b_nvs = 0;

my $managed_care_a = 0;
my $managed_care_part_b_nvs = 0;

my $others = 0;

my %hash_of_arrays_insurance_and_types;
my @array_in_a_hash = (0, 0, 0, 0, 0);

foreach my $item (@data_with_relevant_information) {

	my @data_intermediate = split (/\,/, $item);
	my $therapist_name = join (',', $data_intermediate[0], $data_intermediate[1]);


	if (exists($hash_of_arrays_insurance_and_types{$therapist_name}))
	{
		
		if ($data_intermediate[2] =~ "Medicare A") {
			#print "Medicare A is $data_intermediate[2] and $array_in_a_hash[0]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[0] =
			$hash_of_arrays_insurance_and_types{$therapist_name}[0]  + $data_intermediate[3];
		}
		elsif ($data_intermediate[2] =~ "Medicare B") {
			#print "Medicare B is $data_intermediate[2]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[1] =
			$hash_of_arrays_insurance_and_types{$therapist_name}[1]  + $data_intermediate[3];
		}
		elsif ($data_intermediate[2] =~ "Managed Care A") {
			#print "Managed Care A is $data_intermediate[2]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[2] =
			$hash_of_arrays_insurance_and_types{$therapist_name}[2]  + $data_intermediate[3];
		}
		elsif ($data_intermediate[2] =~ "Managed Care Part B") {
			#print "Managed Care B is $data_intermediate[2]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[3] =
			$hash_of_arrays_insurance_and_types{$therapist_name}[3]  + $data_intermediate[3];
		}
		else {
			print "it's something else";
			$hash_of_arrays_insurance_and_types{$therapist_name}[4] =
			$hash_of_arrays_insurance_and_types{$therapist_name}[4]  + $data_intermediate[3];

		};
	
	
	}
	else {
		#print "not found, but added $therapist_name \n";
		
		$hash_of_arrays_insurance_and_types{$therapist_name} = [0, 0, 0, 0];
		
		if ($data_intermediate[2] =~ "Medicare A") {
			#print "Medicare A is $data_intermediate[2] and $array_in_a_hash[0]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[0] =
			$data_intermediate[3];
		}
		elsif ($data_intermediate[2] =~ "Medicare B") {
			#print "Medicare B is $data_intermediate[2]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[1] =
			$data_intermediate[3];
		}
		elsif ($data_intermediate[2] =~ "Managed Care A") {
			#print "Managed Care A is $data_intermediate[2]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[2] =
			$data_intermediate[3];
		}
		elsif ($data_intermediate[2] =~ "Managed Care Part B") {
			#print "Managed Care B is $data_intermediate[2]\n";
			$hash_of_arrays_insurance_and_types{$therapist_name}[3] =
			$data_intermediate[3];
		}
		else {
			print "it's something else";
			$hash_of_arrays_insurance_and_types{$therapist_name}[4] =
			$data_intermediate[3];

		};
		#$hash_of_arrays_insurance_and_types{} = @array_in_a_hash;
		#push(@{ $hash_of_arrays_insurance_and_types{$therapist_name} }, 3);

		
	};
};



# time to print to a file
# what is today's date
my @date = split (/ /, scalar localtime);
#foreach my $item (@date) {
#	print "$item\n";
#};

my $year = $date[4];
my $month = $date[1];
my $day = $date[2];

my $output_filename = join('_', $year,$month,$day);



# now output the files
open(my $output_file, ">", "$output_filename.csv") or die "Can't open a file";

print $output_file "Therpist name, Medicare A, Medicare B (NVS), Managed Care A, Managed Care Part B (NVS)\n"; 

foreach my $string (sort keys %hash_of_arrays_insurance_and_types) {
	
	
	my $line = join(',',
		$string,
		$hash_of_arrays_insurance_and_types{$string}[0],
		$hash_of_arrays_insurance_and_types{$string}[1],
		$hash_of_arrays_insurance_and_types{$string}[2],
		$hash_of_arrays_insurance_and_types{$string}[3],
		);

	#print $output_file "$string" "hello" "\n";
	
	print $output_file "$line\n";

	#print "$string: @{$hash_of_arrays_insurance_and_types{$string}}\n"; 
};




close($output_file)