#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			7 May 2014
# Last Edit Date:		7 May 2014
# Software Application:	EQEmu, Infinity Server
# Description:			Utility plugins for Infinity
# ==============================================================

use warnings;
use DBI;

# Args: String sqlStatement, boolean returnResults, boolean debug
# Returns: Array databaseResults
sub callDatabase {
	my $client = plugin::val('$client');
	my $db="peq";
	my $host="localhost";
	my $user="root";
	my $password="33heLM70";
	my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host", $user, $password) or $client->Message(13,"Failed to connect to database.");
	if ($_[2]) {$client->Message(1,"sql=$_[0]");} #debug
	my $getData = $dbh->prepare($_[0]);
	$getData->execute( );
	my @dataBaseResults = $getData->fetchrow_array();
	if ($_[1]) { # if returning results
		if (!defined $dataBaseResults[0]) { #if no valid results came back from the DB
			if ($_[2]) {$client->Message(13,"Failed to get valid results from the database.");} #debug
			if ($_[2]) {$client->Message(13,"Failed to get valid results from the database. (Error: $!)");} #debug
		}
		return (@dataBaseResults);
	}
}

return 1;	#This line is required at the end of every plugin file in order to use it