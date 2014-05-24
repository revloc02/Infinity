# ==============================================================
# Author:					Forest Colver
# Create Date:				3 Aug 2011
# Last Edit Date:			1 Sep 2011
# Software Application:		EQEmu, Infinity Server
# Description:				Start the task with a Charm Upgrade, recieve a random MOB to kill according to client level
# ==============================================================

#!/usr/bin/perl
use DBI;
use POSIX; # implements ceil(), floor(), and a number of other mathematical and trigonometric functions.

# constants
use constant MOB_LEVEL_MODIFIER => 3;
use constant MIN_MOB_LEVEL_TO_FIND => 16;
use constant MAX_MOB_LEVEL_TO_FIND => 69;
use constant ITEM_ID_TO_START_QUEST  => 252001; # Infinity Charm Upgrade
use constant MIN_CHARM_ID  => 251001;
use constant MAX_CHARM_ID  => 252000;

#database configuration information
$db="peq";
$host="localhost";
$user="root";
$password="33heLM70";

#connect to MySQL database
my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host", $user, $password);
my $sql = ""; # for creating SQL scripts
my $debug = 1;

sub EVENT_SAY {
	if (!defined $qglobals{charm_upgrade_task}) {
		quest::setglobal("charm_upgrade_task", 0, 5, "F");
	}
	my $infinityCharmUpgrade = quest::varlink(ITEM_ID_TO_START_QUEST);
	
	if ($text=~/Hail/i) {
		#quest::istaskcompleted(int taskid) check if task is complete
		if ($debug) {$client->Message(1,"charm_upgrade_task qglobals=$qglobals{charm_upgrade_task}");} #debug
		$client->Message(315,"Heya hun. Find a $infinityCharmUpgrade while you are adventuring and bring it to me and I can help you upgrade the magical Sword Charm you got from Goldgreat. Keep in mind though that part of your quest will be to destroy a random evil creature.");
	}
	if ($text=~/resetqglobal/i) {
		if ($debug) {
			# for debugging to reset qglobal
			$client->Message(1,"reset qglobal charm_upgrade_task");
			quest::setglobal("charm_upgrade_task", 0, 5, "F");
		}
	}
}

sub EVENT_ITEM {
	if (!defined $qglobals{charm_upgrade_task}) {
		quest::setglobal("charm_upgrade_task", 0, 5, "F");
	}
	my $prestigeLevel = $qglobals{prestige_level}; # this is the number of times a character has Prestiged
	my $itemIDtoStartQuest = ITEM_ID_TO_START_QUEST;
	
	my $infinityCharmUpgrade = quest::varlink(ITEM_ID_TO_START_QUEST);
	
	if (plugin::takeItems($itemIDtoStartQuest => 1)) {
		$sql = "CALL sps_isTaskAssigned($charid)";
		if ($debug) {$client->Message(1,"sql=$sql");} #debug
		my $getIsTaskAssigned = $dbh->prepare($sql);
		$getIsTaskAssigned->execute( );
		my @isTaskAssigned = $getIsTaskAssigned->fetchrow_array();
		if (@isTaskAssigned[0] < 0) {
			# TODO: resolve the -1, perhaps the -1 could be resolved in the sproc
			$client->Message(13,"ERROR: PC is assigned more than one Infinity Charm Upgrade task in the db. This needs to be debugged.");
		}
		if (@isTaskAssigned[0]) { # if is assigned a task in the character_tasks table
			if ($debug) {$client->Message(1,"PC has task# @isTaskAssigned[0] currently assigned to them already");} #debug
			$client->Message(315, "You already have a task that needs to be completed. When it is, give me your Infinity Charm and I'll upgrade it for you. Here's your $infinityCharmUpgrade back. (If ya don't like that quest, go to your Quest Journal [Alt-Q] and Remove it.)");
			quest::summonitem(ITEM_ID_TO_START_QUEST); # Infinity Charm Upgrade returned
			if ($qglobals{charm_upgrade_task} != @isTaskAssigned[0]) {
				if ($debug) {$client->Message(1,"synch-ing up the qglobal with the db because they were different");} #debug
				quest::setglobal("charm_upgrade_task", @isTaskAssigned[0], 5, "F"); # synch up the qglobal with the db
				# TODO: if a synch happens likely the Character_tasks table will have to be updated? This whole functionality may need to be moved to the sproc
			}
		}
		else {
			if ($debug) {$client->Message(1,"No assigned task in db");} #debug
			if ($qglobals{charm_upgrade_task} > 0) { # PC must have Removed the task from their Quest Journal
				quest::setglobal("charm_upgrade_task", 0, 5, "F"); # synch up the qglobal with the db
				if ($debug) {$client->Message(1,"qglobal was cleared, PC must have Removed the task from their Quest Journal");} #debug
			}
			getTask($prestigeLevel);
		}
	}
	my @itemArray = ();
	if ($item1) {push(@itemArray, $item1);}
	if ($item2) {push(@itemArray, $item2);}
	if ($item3) {push(@itemArray, $item3);}
	if ($item4) {push(@itemArray, $item4);}
	if ($debug) {$client->Message(1,"Parsed item list: @itemArray");} #debug
	foreach (@itemArray) {
		if (($_ >= MIN_CHARM_ID) && ($_ <= MAX_CHARM_ID)) {
			if (quest::istaskcompleted($qglobals{charm_upgrade_task})) {
				quest::ding(); # not really a ding, it's the quest complete fanfare
				$client->Message(315, "Great job! Here's your upgraded Infinity Charm.");
				my $upgradedCharmID = $_ + 1;
				plugin::takeItems($_ => 1);
				quest::summonitem($upgradedCharmID); # Infinity Charm one level higher
				quest::setglobal("charm_upgrade_task", 0, 5, "F"); # reset to zero
			}
			else {
				$client->Message(315,"Silly goose, you need to complete the task first then give me your charm.");
			}
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
	plugin::returnUnusedItems();
}

sub getTask {
	my $expansion = ($_[0]<1) ? 1 : $_[0];
	my $mobLevel = $ulevel + MOB_LEVEL_MODIFIER - ceil(sqrt(rand($ulevel))); #get a random level near the PC level, but results are skewed to be on the low side
	$mobLevel = ($mobLevel < MIN_MOB_LEVEL_TO_FIND) ? MIN_MOB_LEVEL_TO_FIND : $mobLevel; # at least level
	$mobLevel = ($mobLevel > MAX_MOB_LEVEL_TO_FIND) ? MAX_MOB_LEVEL_TO_FIND : $mobLevel; # no more than
	$sql = "SELECT id FROM tasks WHERE reward = 'Infinity Charm Upgrade' AND maxlevel = $mobLevel AND minlevel <= $expansion ORDER BY rand() limit 1";
	if ($debug) {$client->Message(1,"sql=$sql");} #debug
	my $setTask = $dbh->prepare($sql);
	$setTask->execute( );
	my @taskID = $setTask->fetchrow_array();
	if ($debug) {$client->Message(1,"taskID(0)=@taskID[0]");} #debug
	quest::assigntask(@taskID[0]);
	quest::setglobal("charm_upgrade_task", @taskID[0], 5, "F"); # task id is saved for a completed check
	$client->Message(315,"'K sugar, if y'all don't like that quest, Remove it from your Quest Journal [Alt-Q] and then you must bring me another $infinityCharmUpgrade and we can try another task. When you have completed the task, return and give me your Infinity Charm and I'll upgrade it.");
}