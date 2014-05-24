#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			21 Apr 2011
# Last Edit Date:		24 Jun 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Newbie Bot give free buffs and ports up to the level you set in the constant: MAX_BUFFNPORT_LEVEL
# ==============================================================

use warnings;

use constant MAX_BUFFNPORT_LEVEL => 15;

sub NewbieBot_say{
	my $text = shift;
	my $name = plugin::val('$name');
	my $qglobals = plugin::var('qglobals');
	my $client = plugin::val('$client');
	my $ulevel = plugin::val('$ulevel');
	my $userid = plugin::val('$userid');
	
	# Destiniations
	my $blackburrow = quest::saylink("blackburrow", 1);
	my $butcher = quest::saylink("butcher", 1);
	my $crushbone = quest::saylink("crushbone", 1);
	my $everfrost = quest::saylink("everfrost", 1);
	my $feerrott = quest::saylink("feerrott", 1);
	my $fieldofbone = quest::saylink("fieldofbone", 1);
	my $freportw = quest::saylink("freportw", 1);
	my $guildlobby = quest::saylink("guildlobby", 1);
	my $misty = quest::saylink("misty", 1);
	my $poknowledge = quest::saylink("poknowledge", 1);
	my $qcat = quest::saylink("qcat", 1);
	my $qeytoqrg = quest::saylink("qeytoqrg", 1);
	my $shadeweaver = quest::saylink("shadeweaver", 1);
	my $steamfont = quest::saylink("steamfont", 1);
	my $tox = quest::saylink("tox", 1);
	my $GloomingDeep = quest::saylink("Glooming Deep", 1);
	
	if ($ulevel <= MAX_BUFFNPORT_LEVEL){
		if ($text=~/hail/i){
			#quest::selfcast(256);		#DS		DRU/7 Shield of Thistles
			#quest::selfcast(219);		#HP		CLR/7 Center
			#quest::selfcast(2521);		#STR	SHM/8 Talisman of the Beast
			#quest::selfcast(266);		#DEX	SHM/1 Dexterous Aura
			#quest::selfcast(269);		#AGI	SHM/3 Feet like Cat
			#quest::selfcast(278);		#Mv		SHM/9 Spirit of Wolf
			#quest::selfcast(697);		#RgnM	ENC/14 Breeze
			quest::castspell(256, $userid);		#DS		DRU/7 Shield of Thistles
			quest::castspell(219, $userid);		#HP		CLR/7 Center
			quest::castspell(2521, $userid);	#STR	SHM/8 Talisman of the Beast
			quest::castspell(266, $userid);		#DEX	SHM/1 Dexterous Aura
			quest::castspell(269, $userid);		#AGI	SHM/3 Feet like Cat
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(697, $userid);		#RgnM	ENC/14 Breeze
			$client->Message(315, "There's some buffs for you youngster. If you hand me any coins I can consolidate them for you into platinum pieces (and give you your change of course). And I will teleport a young one like you for free too if you need: $blackburrow, $butcher, $crushbone, $everfrost, $feerrott, $fieldofbone, $freportw, $guildlobby, $misty, $poknowledge, $qeytoqrg, $qcat, $shadeweaver, $steamfont, $tox. Or you could go visit the Mines of the $GloomingDeep.");
		}
		if ($text =~/blackburrow/i){
			$client->Message(315, "I remember being there and carrying so much loot I could hardly move.");
			quest::zone('blackburrow');
		}
		if ($text =~/butcher/i){
			$client->Message(315, "Do not mistakenly call them dorfs.");
			quest::zone('butcher');
		}
		if ($text =~/crushbone/i){
			$client->Message(315, "The Shiney Brass Shield!!!");
			quest::zone('crushbone');
		}
		if ($text =~/everfrost/i){
			$client->Message(315, "...good memories...watch out for mamas");
			quest::zone('everfrost');
		}
		if ($text =~/feerrott/i){
			$client->Message(315, "Off you go then...");
			quest::zone('feerrott');
		}
		if ($text =~/fieldofbone/i){
			$client->Message(315, "Off you go then...");
			quest::zone('fieldofbone');
		}
		if ($text =~/freportw/i){
			$client->Message(315, "Ah, I remember when I grew up there.");
			quest::zone('freportw');
		}
		if ($text =~/guildlobby/i){
			$client->Message(315, "Back to safety.");
			quest::zone('guildlobby');
		}
		if ($text =~/misty/i){
			$client->Message(315, "Have you noticed that Misty Thicket is not really that misty?");
			quest::zone('misty');
		}
		if ($text =~/poknowledge/i){
			$client->Message(315, "Off you go then...");
			quest::zone('poknowledge');
		}
		if ($text =~/qeytoqrg/i){
			$client->Message(315, "Off you go then...");
			quest::zone('qeytoqrg');
		}
		if ($text =~/qcat/i){
			$client->Message(315, "Off you go then...");
			quest::zone('qcat');
		}
		if ($text =~/shadeweaver/i){
			$client->Message(315, "Bang, zoom, to the moon!");
			quest::zone('shadeweaver');
		}
		if ($text =~/steamfont/i){
			$client->Message(315, "Off you go then...");
			quest::zone('steamfont');
		}
		if ($text =~/tox/i){
			$client->Message(315, "Off you go then...");
			quest::zone('tox');
		}
		if ($text =~/Glooming Deep/i){
			$client->Message(315, "A good place to learn.");
			quest::zone('tutorialb');
		}
		if ($text =~/reset/i){ #allows for reseting the qglobal, used for testing
			$client->SetGlobal("goldgreat_newbie_charm", 0, 5, "F");
			$client->Message(315, "qglobal goldgreat_newbie_charm reset to zero");
		}
	}
	else{
		if ($qglobals->{"goldgreat_newbie_charm"} == 0) {
			$client->Message(315, "Now then $name, you've grown up. Time for you to move on to bigger and better adventures.");
			$client->Message(315, "Here's a +1 sword to help you along, tell them you got it from the guy that sent you.");
			quest::summonitem(151001, 0);
			quest::ding(); # not really a ding, it's the quest complete fanfare
			$client->SetGlobal("goldgreat_newbie_charm", 1, 5, "F");
			# This next line makes sure that the PC cannot continue hail can receive the free item (without it thats what was happening). Seems the PC needed to zone for the global to take affect.
			$qglobals{goldgreat_newbie_charm} = 1;
		}
		else{
			$client->Message(315, "Ahh, quite the character you are $name, you little whipper-snapper, trying to get another +1 sword from me. Run along now ya rascal and go farm some stuff or something.");
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub NewbieBot_item{
	my($platinum, $gold, $silver, $copper) = (plugin::val('$platinum'), plugin::val('$gold'), plugin::val('$silver'), plugin::val('$copper'));
	my $CopperChangeAmount = ($copper%10); #Amount of copper to receive back
	$silver = $silver + (($copper-$CopperChangeAmount)/10);
	my $SilverChangeAmount = ($silver%10); #Amount of silver to receive back
	$gold = $gold + (($silver-$SilverChangeAmount)/10);
	my $GoldChangeAmount = ($gold%10); #Amount of gold to receive back
	$platinum = $platinum + (($gold-$GoldChangeAmount)/10);
	my $PlatChangeAmount = $platinum;
	if (($CopperChangeAmount > 0) || ($SilverChangeAmount > 0) || ($GoldChangeAmount > 0) || ($PlatChangeAmount > 0)){
		$client->Message(315, "Here's your change."); 
		quest::givecash($CopperChangeAmount,$SilverChangeAmount,$GoldChangeAmount,$PlatChangeAmount);
	}
}

return 1;	#This line is required at the end of every plugin file in order to use it