# ==============================================================
# Author:								Forest Colver
# Create Date:					2 Sep 2011
# Last Edit Date:				2 Sep 2011
# Software Application:	EQEmu, Infinity Server
# Description:					Spawns a random MOB
# ==============================================================

#!/usr/bin/perl
use DBI;
use POSIX; # implements ceil(), floor(), and a number of other mathematical and trigonometric functions.

# constants
use constant SPAWN_OFFSET => 20;

#database configuration information
$db="peq";
$host="localhost";
$user="root";
$password="33heLM70";

#connect to MySQL database
my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host", $user, $password);
my $debug = 1;
my $sql = ""; # for creating SQL scripts

sub EVENT_SAY{
	if($text=~/Hail/i) {
		$client->Message(315,"Heya.");
		my $a = $x + int(rand(SPAWN_OFFSET)) - SPAWN_OFFSET/2;
		my $b = $y + int(rand(SPAWN_OFFSET)) - SPAWN_OFFSET/2;
		my $c = $z + 2;
		my $d = $h + int(rand(360));
		$randomMOB = int(rand(233000)) + 500;
		if ($debug) {$client->Message(315,"randomMOB=$randomMOB");} #debug
		quest::spawn2($randomMOB, 0, 0, $a, $b, $c, $d);
	}
}

sub EVENT_SPAWN {
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
	$client->Message(15, "You have entered proximity");
	#random encounter
	# 1. trap
	# 2. treasure
	# 3. nothing
	# 4. random mob from ldon
	#	5. random mob from all
	# 6. NPC
	
	# client level +(2,3,4) minus (random 1-35% round up)
	my $mobLevel = $ulevel + 1 + ceil(rand(3)) - ceil($ulevel * ceil(rand(35))/100);
	my $a = $x + int(rand(SPAWN_OFFSET)) - SPAWN_OFFSET/2;
	my $b = $y + int(rand(SPAWN_OFFSET)) - SPAWN_OFFSET/2;
	my $c = $z + 2;
	my $d = $h + int(rand(360));
	$sql = "CALL sps_SpawnRandomMOB($mobLevel,233000,233499,1,0)";
	if ($debug) {$client->Message(315,"sql=$sql");} #debug
	my $randomMOB = $dbh->prepare($sql);
	$randomMOB->execute( );
	my @MOB = $randomMOB->fetchrow_array();
	quest::spawn2(@MOB[0], 0, 0, $a, $b, $c, $d);
}