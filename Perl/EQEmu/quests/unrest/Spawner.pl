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
use constant SPAWN_RADIUS => 15;
use constant PROXIMITY_RADIUS => 25;

#database configuration information
$db="peq";
$host="localhost";
$user="root";
$password="33heLM70";

#connect to MySQL database
my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host", $user, $password);
my $debug = 1;
my $sql = ""; # for creating SQL scripts

sub EVENT_SPAWN {
	quest::set_proximity($x - PROXIMITY_RADIUS, $x + PROXIMITY_RADIUS, $y - PROXIMITY_RADIUS, $y + PROXIMITY_RADIUS);
}

sub EVENT_ENTER {
	if ($debug) {$client->Message(15, "You have entered proximity");} #debug
	#random encounter
	# 1. trap
	# 2. treasure
	# 3. nothing
	# 4. random mob from ldon
	# 5. random mob from all
	# 6. NPC
	
	# client level +(2,3,4) minus (random 1-35% round up)
	my $mobLevel = $ulevel + 1 + ceil(rand(3)) - ceil($ulevel * ceil(rand(35))/100);
	my $a = $x + int(rand(SPAWN_RADIUS*2)) - SPAWN_RADIUS;
	my $b = $y + int(rand(SPAWN_RADIUS*2)) - SPAWN_RADIUS;
	my $c = $z + 2;
	my $d = $h + int(rand(360));
	# sps_SpawnRandomMOB(MOBlevel, npcIDstart, npcIDend, globalMOB(T/F), globalNPC(T/F))
	$sql = "CALL sps_SpawnRandomMOB(0,63000,63096,0,0)";
	if ($debug) {$client->Message(315,"sql=$sql");} #debug
	my $randomMOB = $dbh->prepare($sql);
	$randomMOB->execute( );
	my @MOB = $randomMOB->fetchrow_array();
	if (defined(@MOB[0])) {
		quest::spawn2(@MOB[0], 0, 0, $a, $b, $c, $d);
		if ($debug) {$client->Message(15, "x=$a, y=$b");} #debug
	}
	else {
		if ($debug) {$client->Message(15, "MOB variable not defined, so sproc returned NULL");} #debug
	}
}