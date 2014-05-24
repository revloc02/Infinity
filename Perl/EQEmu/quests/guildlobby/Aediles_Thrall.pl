#!/usr/bin/perl
############################################
# ZONE: Guildlobby
# DATABASE: PEQ PoP-LoY
# LAST EDIT DATE: 24 Jun 2011
# VERSION: 1.1
# DEVELOPER: Congdar
# REVAMPED BY: Forest Colver
#
# *** NPC INFORMATION ***
#
# NAME: Aediles Thrall 151070
# TYPE: NPC
# RACE: Dwarf
# LEVEL: 71
#
# *** ITEMS GIVEN OR TAKEN ***
#
# see below
#
#
# *** QUESTS INVOLVED IN ***
#
# 1 - Custom Quest - Acquiring bots
#
#
# *** QUESTS AVAILABLE TO ***
#
# 1 - Anyone meeting level requirements
#
#
############################################

#use strict; # uncomment this line for some helpful errors and warning, recomment so that this script will work properly in game
use warnings;

# Some global settings for the quest.  Set them to your preferred levels and plat costs
# Level options for when a character can acquire more bots
my $firstBotLevel		= 1;
my $firstBotCost		= 2;
my $firstBotItem1		= 13072; # rat ear
my $firstBotItem1Qnty	= 4;

my $secondBotLevel		= 10;
my $secondBotCost		= 40;
my $secondBotItem1		= 13462; # Batwing Crunchies - Baking 46
my $secondBotItem1Qnty	= 2;
my $secondBotItem2		= 7021; # Tarnished Dagger - Smithing 18
my $secondBotItem2Qnty	= 1;
my $secondBotItem3		= 5048; # Tarnished Bastard Sword - Smithing 24
my $secondBotItem3Qnty	= 1;

my $thirdBotLevel		= 20;
my $thirdBotCost		= 200;
my $thirdBotItem1		= 13468; # Fish Fillets - Baking 82
my $thirdBotItem1Qnty	= 1;
my $thirdBotItem2		= 13037; # Gnomish Spirits - Brewing 102
my $thirdBotItem2Qnty	= 1;
my $thirdBotItem3		= 3061; # banded bracer - Smithing 95
my $thirdBotItem3Qnty	= 1;
my $thirdBotItem4		= 17969; # Hand Made Backpack - Tailoring 88
my $thirdBotItem4Qnty	= 1;

my $fourthBotLevel		= 30;
my $fourthBotCost		= 1000;
my $fourthBotItem1		= 16784; # Silver Ruby Veil - Jewelcraft 63
my $fourthBotItem1Qnty	= 1;
my $fourthBotItem2		= 13475; # fish roll - Baking 135
my $fourthBotItem2Qnty	= 1;
my $fourthBotItem3		= 17804; # tailored quiver - Tailoring 115
my $fourthBotItem3Qnty	= 1;
my $fourthBotItem4		= 16939; # small bowl - Pottery 102
my $fourthBotItem4Qnty	= 1;

my $fifthBotLevel		= 40;
my $fifthBotCost		= 5000;
my $fifthBotItem1		= 21024; # Small Fine Plate Boots - Smithing 168
my $fifthBotItem1Qnty	= 1;
my $fifthBotItem2		= 8689; # Class 4 ceramic hooked arrows - Fletching 135
my $fifthBotItem2Qnty	= 1;
my $fifthBotItem3		= 19993; # Pixie Powder Cinnesticks - Baking 202
my $fifthBotItem3Qnty	= 1;
my $fifthBotItem4		= 30362; # Golden Blue Diamond Pendant - Jewelcraft 228
my $fifthBotItem4Qnty	= 1;

# They have enough for one group, now they start creating raid bots up to the quest::spawnbotcount() limit.
# A rule setting Bots:SpawnBotCount of 11 is two full groups including you.
my $nextBotLevel		= 60;
my $nextBotCost			= 25000;
my $nextBotItem1		= 150000; # RoI upgrade
my $nextBotItem1Qnty	= 1;

my $nextExtraCost		= 250000;

sub EVENT_SAY {
	my $firstBotItem1Link = quest::varlink($firstBotItem1);
	my $secondBotItem1Link = quest::varlink($secondBotItem1);
	my $secondBotItem2Link = quest::varlink($secondBotItem2);
	my $secondBotItem3Link = quest::varlink($secondBotItem3);
	my $thirdBotItem1Link = quest::varlink($thirdBotItem1);
	my $thirdBotItem2Link = quest::varlink($thirdBotItem2);
	my $thirdBotItem3Link = quest::varlink($thirdBotItem3);
	my $thirdBotItem4Link = quest::varlink($thirdBotItem4);
	my $fourthBotItem1Link = quest::varlink($fourthBotItem1);
	my $fourthBotItem2Link = quest::varlink($fourthBotItem2);
	my $fourthBotItem3Link = quest::varlink($fourthBotItem3);
	my $fourthBotItem4Link = quest::varlink($fourthBotItem4);
	my $fifthBotItem1Link = quest::varlink($fifthBotItem1);
	my $fifthBotItem2Link = quest::varlink($fifthBotItem2);
	my $fifthBotItem3Link = quest::varlink($fifthBotItem3);
	my $fifthBotItem4Link = quest::varlink($fifthBotItem4);
	my $nextBotItem1Link = quest::varlink($nextBotItem1);

	my $help = quest::saylink("help",1);
	my $product = quest::saylink("product",1);
	my $AID = quest::saylink("AID",1);
	my $Individuals = quest::saylink("Individuals",1);
	my $interested = quest::saylink("interested",1);
	my $supplies = quest::saylink("supplies",1);

	if (defined $qglobals{bot_spawn_limit} && (quest::spawnbotcount() > $qglobals{bot_spawn_limit})) {
		if (($ulevel >= $firstBotLevel) && ($qglobals{bot_spawn_limit} <= 0)) {
			quest::settimer("face", 25);
			if ($text=~/Hail/i) {
				$client->Message(315, "Hey der youngster.  Lookin' fer a bit o' $help with yer adventurin'?");
			}
			if ($text=~/Help/i) {
				quest::emote("looks around the room and pauses a few seconds");
				$client->Message(315, "Well, I kin sell ye a $product ye can't find no place else.");
			}
			if ($text=~/Product/i) {
				quest::emote("looks around the room again and lowers his voice");
				$client->Message(315, "Shhh, i'm involved in wut I like ta call A.I.D., I kin $AID ye in yer adventurin'");
			}
			if ($text=~/AID/i) {
				quest::emote("looks around the room again and leans in");
				$client->Message(315, "It be 'Acquired Individuals Delivery' and it means I kin supply ye with $Individuals.");
			}
			if ($text=~/Individuals/i) {
				quest::emote("looks around the room again and whispers");
				$client->Message(315, "Shhh, not too loud... I kin deliver ye an Individual if yer $interested?");
			}
			if ($text=~/Interested/i) {
				$client->Message(315, "Let me tell ye, keepin' up a supply o' Individuals can be a costly endeavor and so's I kin feed 'em I need ye ta be collectin' up sum $supplies fer me.");
			}
			if ($text=~/Supplies/i) {
				$client->Message(315, "The Individual will cost ye $firstBotCost platinum pieces an' $firstBotItem1Qnty o' dem $firstBotItem1Link.");
			}
		}
		elsif (($ulevel >= $secondBotLevel) && ($qglobals{bot_spawn_limit} <= 1)) {
			if ($text=~/Hail/i) {
				$client->Message(315, "Ahh, a returnin' customer. Are ye $interested in another Individual?");
			}
			if ($text=~/Interested/i) {
				quest::emote("looks around the room");
				$client->Message(315, "Shhh, I kin deliver ye another Individual for $secondBotCost platinum an' $secondBotItem1Qnty o' dem $secondBotItem1Link and $secondBotItem2Qnty $secondBotItem2Link and $secondBotItem3Qnty $secondBotItem3Link.");
			}
		}
		elsif (($ulevel >= $thirdBotLevel) && ($qglobals{bot_spawn_limit} <= 2)) {
			if ($text=~/Hail/i) {
				$client->Message(315, "Ahh, good to see you again $name. Are ye $interested in another Individual?");
			}
			if ($text=~/Interested/i) {
				quest::emote("looks around the room");
				$client->Message(315, "Shhh, I kin deliver ye another Individual for $thirdBotCost platinum an' $thirdBotItem1Qnty o' dem $thirdBotItem1Link, $thirdBotItem2Qnty purty $thirdBotItem2Link, jus' $thirdBotItem3Qnty $thirdBotItem3Link, and also $thirdBotItem4Qnty sharp $thirdBotItem4Link... heh, dey needs ta 'ave supplies ya knows.");
			}
		}
		elsif (($ulevel >= $fourthBotLevel) && ($qglobals{bot_spawn_limit} <= 3)) {
			if ($text=~/Hail/i) {
				$client->Message(315, "Well back 'gain eh? How's tha help? Are ye $interested in another Individual?");
			}
			if ($text=~/Interested/i) {
				quest::emote("looks around the room");
				$client->Message(315, "Shhh, I kin deliver ye another Individual for $fourthBotCost platinum an' $fourthBotItem1Qnty $fourthBotItem1Link, $fourthBotItem2Qnty $fourthBotItem2Link, $fourthBotItem3Qnty $fourthBotItem3Link, and $fourthBotItem4Qnty $fourthBotItem4Link all fer maintainin' good supplies.");
			}
		}
		elsif (($ulevel >= $fifthBotLevel) && ($qglobals{bot_spawn_limit} <= 4)) {
			if ($text=~/Hail/i) {
				$client->Message(315, "So these mercenaries I'm supplyin' must be workin' out fer ya. Are ye $interested in another Individual?");
			}
			if ($text=~/Interested/i) {
				quest::emote("looks around the room");
				$client->Message(315, "Shhh, I kin deliver ye another Individual for $fifthBotCost platinum an' $fifthBotItem1Qnty $fifthBotItem1Link, $fifthBotItem2Qnty $fifthBotItem2Link, $fifthBotItem3Qnty $fifthBotItem3Link, and $fifthBotItem4Qnty $fifthBotItem4Link all fer maintainin' good supplies...and fer the missus too.");
			}
		}
		elsif (($ulevel >= $nextBotLevel) && ($qglobals{bot_spawn_limit} <= 5)) {
			if ($text=~/Hail/i) {
				$client->Message(315, "Ya've come 'gain, I must charge more. Are ye $interested in another Individual?");
			}
			if ($text=~/Interested/i) {
				quest::emote("looks around the room");
				$client->Message(315, "Shhh, I kin deliver ye another Individual for $nextBotCost platinum an' $nextBotItem1Qnty o' dem $nextBotItem1Link.");
			}
		}
		elsif (($ulevel >= $nextBotLevel) && ($qglobals{bot_spawn_limit} >= 6)) {
			if ($text=~/Hail/i) {
				$client->Message(315, "Ahh, a returnin' customer. Are ye $interested in another Individual?");
			}
			if ($text=~/Interested/i) {
			quest::emote("looks around the room");
				$client->Message(315, "Shhh, I kin deliver ye another Individual for $nextBotCost platinum an' $nextBotItem1Qnty o' dem $nextBotItem1Link.");
				$client->Message(315, "If ye dun have dem $nextBotItem1Link, ye can just pay me $nextExtraCost platinum.");
			}
		}
		else {
			if ($text=~/Hail/i) {
				$client->Message(315, "eh? Come back when yer a bit older. I kin help ye then.");
				quest::settimer("face", 5);
			}
		}
	}
	else {
		if ($text=~/Hail/i) {
			$client->Message(315, "eh? Mind yer own business, go away!");
			quest::settimer("face", 5);
			my $sbcount = quest::spawnbotcount();
			$client->Message(6,"You have $qglobals{bot_spawn_limit} out of $sbcount possible Individuals.");
		}
	}
}

sub EVENT_TIMER {
	if ($timer eq "face") {
		my $facemob = $entity_list->GetMobByNpcTypeID(151071);
		$npc->FaceTarget($facemob);
		quest::stoptimer("face");
	}
}

sub EVENT_ITEM {
	my $CopperChangeAmount = ($copper%10); #Amount of copper to receive back
	$silver = $silver + (($copper-$CopperChangeAmount)/10);
	my $SilverChangeAmount = ($silver%10); #Amount of silver to receive back
	$gold = $gold + (($silver-$SilverChangeAmount)/10);
	my $GoldChangeAmount = ($gold%10); #Amount of gold to receive back
	$platinum = $platinum + (($gold-$GoldChangeAmount)/10);
	my $PlatChangeAmount = $platinum;
	if (defined $qglobals{bot_spawn_limit} && (quest::spawnbotcount() > $qglobals{bot_spawn_limit}))
	{
		my $success = 0;
		if (($ulevel >= $firstBotLevel) && ($qglobals{bot_spawn_limit} <= 0))
		{
			if (($platinum >= $firstBotCost) && plugin::check_handin(\%itemcount, $firstBotItem1 => $firstBotItem1Qnty))
			{
				$PlatChangeAmount = $platinum - $firstBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		elsif (($ulevel >= $secondBotLevel) && ($qglobals{bot_spawn_limit} <= 1))
		{
			if (($platinum >= $secondBotCost) && plugin::check_handin(\%itemcount, $secondBotItem1 => $secondBotItem1Qnty) && plugin::check_handin(\%itemcount, $secondBotItem2 => $secondBotItem2Qnty) && plugin::check_handin(\%itemcount, $secondBotItem3 => $secondBotItem3Qnty))
			{
				$PlatChangeAmount = $platinum - $secondBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		elsif (($ulevel >= $thirdBotLevel) && ($qglobals{bot_spawn_limit} <= 2))
		{
			if (($platinum >= $thirdBotCost) && plugin::check_handin(\%itemcount, $thirdBotItem1 => $thirdBotItem1Qnty) && plugin::check_handin(\%itemcount, $thirdBotItem2 => $thirdBotItem2Qnty) && plugin::check_handin(\%itemcount, $thirdBotItem3 => $thirdBotItem3Qnty) && plugin::check_handin(\%itemcount, $thirdBotItem4 => $thirdBotItem4Qnty))
			{
				$PlatChangeAmount = $platinum - $thirdBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		elsif (($ulevel >= $fourthBotLevel) && ($qglobals{bot_spawn_limit} <= 3))
		{
			if (($platinum >= $fourthBotCost) && plugin::check_handin(\%itemcount, $fourthBotItem1 => $fourthBotItem1Qnty) && plugin::check_handin(\%itemcount, $fourthBotItem2 => $fourthBotItem2Qnty) && plugin::check_handin(\%itemcount, $fourthBotItem3 => $fourthBotItem3Qnty) && plugin::check_handin(\%itemcount, $fourthBotItem4 => $fourthBotItem4Qnty))
			{
				$PlatChangeAmount = $platinum - $fourthBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		elsif (($ulevel >= $fifthBotLevel) && ($qglobals{bot_spawn_limit} <= 4))
		{
			if (($platinum >= $fifthBotCost) && plugin::check_handin(\%itemcount, $fifthBotItem1 => $fifthBotItem1Qnty) && plugin::check_handin(\%itemcount, $fifthBotItem2 => $fifthBotItem2Qnty) && plugin::check_handin(\%itemcount, $fifthBotItem3 => $fifthBotItem3Qnty) && plugin::check_handin(\%itemcount, $fifthBotItem4 => $fifthBotItem4Qnty))
			{
				$PlatChangeAmount = $platinum - $fifthBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		elsif (($ulevel >= $nextBotLevel) && ($qglobals{bot_spawn_limit} <= 5))
		{
			if (($platinum >= $nextBotCost) && plugin::check_handin(\%itemcount, $nextBotItem1 => $nextBotItem1Qnty))
			{
				$PlatChangeAmount = $platinum - $nextBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		elsif (($ulevel >= $nextBotLevel) && ($qglobals{bot_spawn_limit} >= 6))
		{
			if (($platinum >= $nextBotCost) && plugin::check_handin(\%itemcount, $nextBotItem1 => $nextBotItem1Qnty)){
				$PlatChangeAmount = $platinum - $nextBotCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
			elsif ($platinum >= $nextExtraCost){
				$PlatChangeAmount = $platinum - $nextExtraCost; #Amount of platinum to receive back
				$success = $qglobals{bot_spawn_limit}+1;
			}
		}
		if ($success > 0) {
			quest::ding(); # not really a ding, it's the quest complete fanfare
			$client->Message(315, "Thanks $name!");
			quest::setglobal("bot_spawn_limit", $success, 5, "F");
			$client->Message(6,"You receive a character flag!");
			$client->Message(6,"You can now create and spawn another bot! See: '#bot help create' and '#bot spawn' commands.");
			my $sbcount = quest::spawnbotcount();
			$client->Message(6,"You have $success out of $sbcount possible Individuals.");
			$success = 0;
			if (($CopperChangeAmount > 0) || ($SilverChangeAmount > 0) || ($GoldChangeAmount > 0) || ($PlatChangeAmount > 0)){
				$client->Message(315, "Here's your change."); 
				quest::givecash($CopperChangeAmount,$SilverChangeAmount,$GoldChangeAmount,$PlatChangeAmount);
			}
		}
		else {
			$client->Message(315, "I don't need this.");
			plugin::return_items(\%itemcount);
			if (($CopperChangeAmount > 0) || ($SilverChangeAmount > 0) || ($GoldChangeAmount > 0) || ($PlatChangeAmount > 0))
			{
				$client->Message(315, "Here's your change."); 
				quest::givecash($CopperChangeAmount,$SilverChangeAmount,$GoldChangeAmount,$PlatChangeAmount);
			}
		}
	}
	else {
		$client->Message(315, "I don't need this.");
		plugin::return_items(\%itemcount);
		if (($CopperChangeAmount > 0) || ($SilverChangeAmount > 0) || ($GoldChangeAmount > 0) || ($PlatChangeAmount > 0))
		{
			$client->Message(315, "Here's your change."); 
			quest::givecash($CopperChangeAmount,$SilverChangeAmount,$GoldChangeAmount,$PlatChangeAmount);
		}
	}
	quest::settimer("face", 45);
}

sub EVENT_SPAWN {
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
	if (quest::botquest()) {
		if (!defined $qglobals{bot_spawn_limit}) {
			quest::setglobal("bot_spawn_limit", 0, 5, "F");
		}
	}
}

sub EVENT_SIGNAL {
	if ($signal == 1) {
		if ((defined $qglobals{bot_spawn_limit}) && ($qglobals{bot_spawn_limit} > 0)) {
			$client->Message(315, "Hey! No talkin' to da merchandise!");
		}
	}
}
# END of FILE Zone:bazaar -- Aediles_Thrall.pl

