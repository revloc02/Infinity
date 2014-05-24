#!/usr/bin/perl
# ==============================================================
# Author:					Forest Colver
# Create Date:				30 Oct 2010
# Last Edit Date:			1 Dec 2011
# Software Application:		EQEmu, Infinity Server
# Description:				Information provider for new spawns, and a source for a couple of free coins
# ==============================================================

use warnings;
use POSIX; # implements ceil(), floor(), and a number of other mathematical and trigonometric functions.

sub EVENT_SAY {
	my $information = quest::saylink("information",1);
	
	my $infinityPvP = quest::saylink("PvP",1);
	
	my $whereToStart = quest::saylink("where to start",1);
	my $Shadeweavers = quest::saylink("Shadeweavers Thicket",1);
	my $rustyWeapons = quest::saylink("rusty weapons",1);
	
	my $serverInfo = quest::saylink("server",1);
	my $chat = quest::saylink("chat",1);
	my $developer = quest::saylink("developer",1);
	my $maxLevel = quest::saylink("max level",1);
	my $reset = quest::saylink("reset",1);
	my $bindWound = quest::saylink("bind wound",1);
	my $casualPlay = quest::saylink("bind wound",1);
	my $Nektulos = quest::saylink("Nektulos",1);
	my $rules = quest::saylink("rules",1);
	my $evil = quest::saylink("evil",1);
	my $nice = quest::saylink("nice",1);
	my $swearing = quest::saylink("swearing",1);
	my $cheating = quest::saylink("cheating",1);
	my $banned = quest::saylink("banned",1);
	
	my $Aediles = quest::saylink("Aediles",1);
	my $infinityBots = quest::saylink("bots",1);
	
	my $RoI = quest::saylink("Ring",1);
	my $IC = quest::saylink("Charm",1);
	my $Prestige = quest::saylink("Prestige",1);
	my $NoDrop = quest::saylink("NoDrop",1);
	my $Goldgreat = quest::saylink("Goldgreat",1);
	
	my $SpellScriber = quest::saylink("Spell Scriber",1);
	my $price = quest::saylink("price",1);
	my $calculate = quest::saylink("calculate",1);
	
	my $Koolag = quest::saylink("Koolag",1);
	my $infinityArmor = quest::saylink("Infinity Armor",1);
	my $statGems = quest::saylink("Stat Gems",1);
	my $statCrystals = quest::saylink("Stat Crystals",1);
	my $infinityArmorToken = quest::saylink("Armor Token",1);
	my $magicallySmelt = quest::saylink("magically smelt",1);
	my $strCompute = quest::saylink("compute",1);
	my $gemRecipe = quest::saylink("recipe",1);
	my $leftovers = quest::saylink("left overs",1);
	my $tomorrow = quest::saylink("tomorrow",1);
	
	my $hints = quest::saylink("hints",1);
	
	my $sparecoins = quest::saylink("spare coins",1);
	
	my $infinityJewelersKit = quest::varlink(153000);
	my $ringOfInfinityUpgrade = quest::varlink(150000);
	my $fusionElixir = quest::varlink(153034);
	
	my $NPCName = $npc->GetCleanName();
	if ($text =~/Hail/i) {
		$client->Message(315, "Greetings $name, and welcome to Infinity Server where progression has no end. My name is $NPCName and I can provide you with free $information, or I have a few $sparecoins if you need a boost.");
	}
	if ($text =~ /information/i) {
		$client->Message(315, "What would you like to learn about? $infinityPvP, $whereToStart, $serverInfo information, $infinityBots, $RoI of Infinity, $SpellScriber, Infinity $IC, $Prestige Quest, $NoDrop Trader, tip and $hints.");
	}
	
	#tips and hints
	if ($text =~ /hints/i) {
		$client->Message(315, "One of the best places to find the rusty weapons that $Aediles asks for is grimling skeletons in Shar Vahl.");
		$client->Message(315, "Everfrost is a good place to find High Quality bear skins for making HandMade Backpacks (for more carrying space).");
		$client->Message(315, "The more you $Prestige the more valuable Infinity rewards will be, more content will be available, and travel will become easier.");
		$client->Message(315, "All character crafted items have triple stats on them to make tradeskills much more enticing.");
	}
	
	#PvP
	if ($text =~ /pvp/i) {
		$client->Message(315, "Some zones are set up as PvP zones. Watch out these zones require corpse runs, and there is a exp penalty for dieing. Somewhere in the zone is a boss that drops a very powerful temporary item. The PvP zones are: dawnshroud, unrest");
	}
	
	#Where to start
	if ($text =~ /where to start/i)	{
		$client->Message(315, "You should talk to $Goldgreat first. Karie is the $SpellScriber, and you should get started with $Koolag on your Infinity armor. Get $rustyWeapons from West Freeport, oh and that's also a great place to find batwings for $Aediles. If you need bags go slay Gor Taku Scouts in $Shadeweavers. Also, check with Castlen Drewe in the Plane of Knowledge if you need something worthwhile to do.");
	}
	if ($text =~ /Shadeweavers Thicket/i)	{
		$client->Message(315, "$Goldgreat will help you get there.");
	}
	if ($text =~ /rusty weapons/i)	{
		$client->Message(315, "The Newbie Merchant has shapening stones to make these into something more respectable...and useful.");
	}
	
	# server rules, flavor and philosophy
	if ($text =~ /server/i)	{
		$client->Message(315, "Which server topic would you like: $rules, server $reset, $maxLevel, $bindWound, $casualPlay, $Nektulos, $developer, $chat. And as the MOTD says this server really is under development right now, and characters really will be purged from the database from time to time, so play at your own risk.");
	}
	if ($text =~ /chat/i)	{
		$client->Message(315, "Chat functions (i.e. ooc, auction, tells) will not be available until a character is 5th level or has logged 72 hours of playing time. This is an anti-spam mechanism.");
	}
	if ($text =~ /developer/i)	{
		$client->Message(315, "The developer of the server can be reached with the following email: forestwolves at hotmail.com.");
	}
	if ($text =~ /max level/i)	{
		$client->Message(315, "The player level soft cap is 70 (but you can go higher than this). Level progresion beyond 70 is exponential. As much exp as it took to get to level 70, it takes twice that to get to 71. And as much then as it took to get to 71 it takes double that to get to 72, and so on. Remember you can do the $Prestige quest at level 65, so you may want to participate in that before leveling beyond 65 and especially beyond 70.");
	}
	if ($text =~ /reset/i)	{
		$client->Message(315, "The server will reset every night. This is to allow changes to the items table that take place in game to be loaded from the database so PCs can benefit from their efforts.");
	}
	if ($text =~ /bind wound/i)	{
		$client->Message(315, "The skill Bind Wound has been significantly upgraded so that it actually is useful. Now any class with higher than 200 bind wound skill can bind to 70% health, not just monks (but this can go up to 100% with the right AAs). Also, as your bind wound skill increases the healing it does increases exponentially.");
	}
	if ($text =~ /casual play/i)	{
		$client->Message(315, "Although the server can accomodate fanatic players, it is intended to have a more casual player base. Furthermore, there definitely will be a fair amount of young kids playing on the server. You can expect some players acting like children because they will be childen. See also some of the $rules.");
	}
	if ($text =~ /Nektulos/i)	{
		$client->Message(315, "If Nektulos Forest is broken (a black void when you zone in), you need to go to your EQ installation folder (e.g. C:/Program Files (x86)/Sony/EverQuest) and change the file 'nektulos.eqg' to 'nektulos.eqg.backup' to fix it.");
	}
	if ($text =~ /rules/i)	{
		$client->Message(315, "Infinity Server Rules:");
		$client->Message(315, "1. Don't be $evil.");
		$client->Message(315, "2. Play $nice.");
		$client->Message(315, "3. No $swearing.");
		$client->Message(315, "4. No $cheating.");
	}
	if ($text =~ /evil/i)	{
		$client->Message(315, "Yeah, I borrowed this from Google, and I also take it seriously. I am not talking about your character being evil and killing good NPCs, I mean you the player, don't be evil. Don't grieve, don't spam, don't advertise, don't cheat, don't whine, etc....this rule pretty much covers everything. You will be $banned for breaking this rule.");
	}
	if ($text =~ /nice/i)	{
		$client->Message(315, "Just be respectful and polite.");
	}
	if ($text =~ /swearing/i)	{
		$client->Message(315, "There will be kids on this server, so really watch your language. Don't like that, go play somewhere else, I don't care. Swearing could get you $banned.");
	}
	if ($text =~ /cheating/i)	{
		$client->Message(315, "You will get $banned for sure if you cheat.");
	}
	if ($text =~ /banned/i)	{
		$client->Message(315, "Basically I own the server and I can do whatver I want. If I decide to ban you, it does not have to be just or fair, I'll just ban you and you can go cry in your pillow.");
	}
	
	# Aediles Thrall and bots
	if ($text =~ /Aediles/i)	{
		$client->Message(315, "He'll set you up with assistance from mercenary-like individuals, or $infinityBots for short.");
	}
	if ($text =~ /bots/i)	{
		$client->Message(315, "Bots are NPCs that you can take on adventures with you, like mercenaries. Go talk to $Aediles to get set up. Getting the first bot is easy. Getting up to 5 bots is difficult but not unreasonable. Beyond that it is unreasonable.");
	}
	
	if ($text =~ /Ring/i)	{
		$client->Message(315, "Your Ring of Infinity can be upgraded, but you must find a $ringOfInfinityUpgrade to improve it. There's a chance for this to drop off of any creature (except merchants, bankers, and quest NPCs). When you find one combine it with your ring in your $infinityJewelersKit.");
	}
	
	# Laney and the Infinity Charm
	if ($text =~ /Charm/i)	{
		$client->Message(315, "When you get to 16th level you can Hail $Goldgreat and he will give you a nifty charm to assist you in furthering your adventures. Then go to Laney to get quests to upgrade your charm.");
	}
	
	# Karie and spells
	if ($text =~ /Spell Scriber/i)	{
		$client->Message(315, "For a small $price the Spell Scriber automatically scribes your spells for you. No more searching for spells.");
	}
	if ($text =~/price/i)
	{
		$client->Message(315, "You can scribe multiple levels at a time, just give Karie some money and she will $calculate how many levels that covers and get right to work. She can scribe spells beyond your level too, you just won't be able to use them until you are experienced enough.");
	}
	if ($text =~/calculate/i)
	{
		$client->Message(315, "Yes, the formula is a bit complex, but let me try and explain it to you. First off caster classes are double the cost of a hybrid class (casters have more spells right). So here are the hybrid prices: For levels 1-19 the cost is 1 gold for level one spells, 2 gold for level two spells, 3 gold for level three spells, and so on. Levels 20-39 is twice that, and levels 40-59 is doubled again (so four times 1-19). So to scribe 43rd level spells on a caster class is 43 for the level, times 2 for caster, and times 4 for spells above level 40, 43 x 2 x 4 = 344 gold. Level 60 and higher costs platinum equivalent to the level of spells scribed, so 60 platinum for level 60 spells, 61 platinum for level 61 spells, and so on up to level 70 (and casters classes are double that). Now mind you, don't you fret about remembering the formula, just hand Karie some money and she'll scribe your spells and give you your change.");
	}
	
	# Lenelila and Prestige Quest
	if ($text =~ /Prestige/i)	{
		$client->Message(315, "When you get to a high level you can start over at first level to get a valuable ear ring and level up its stats with each Prestige iteration (leveling from 1 to XX). The first time you Pretige you can do it at level 50. The next three Prestiges can be done at level 60, and from then on you must be at least level 65. Doing the Prestige Quest also enables access to several other benefits.");
	}
	
	# Buddy and no-drop trades
	if ($text =~ /NoDrop/i)	{
		$client->Message(315, "If you find an item you can't use or trade, take it to Buddy and he'll try to trade you an item of similar value that you can use.");
	}
	
	# Goldgreat
	if ($text =~ /Goldgreat/i)	{
		$client->Message(315, "He'll help you get a good start, and then when you've progressed enough he'll bequeath a precious $IC as a gift to you.");
	}
	
	# Koolag and Infinity Armor
	if ($text =~/Koolag/i)	{
		$client->Message(315,"Koolag makes special tailor-made armor infused with unique gems found here in Norrath. You will make crystals from these gems that will be smithed into the armor he sells. He will also store the crystals for you. Hand him an $infinityArmor piece and he'll $magicallySmelt all your crystals to it. Hand him a $infinityArmorToken and he'll give you your customized armor piece.");
	}
	if ($text =~/stat crystals/i)	{
		$client->Message(315,"Infinity Crystals are made from $statGems. $Koolag will keep your crystals in storage for you--just hand them to him and they'll be safe. When you are ready, give him one of your personal $infinityArmor pieces and he'll $magicallySmelt all the crystals in your storage into it. The crystals imbue the armor with power (and raise the stats).");
	}
	if ($text =~/stat gems/i)	{
		$client->Message(315,"Infinity Gems can be combined with some $fusionElixir (which $Koolag sells) in an $infinityJewelersKit to create Infinity $statCrystals. Make sure you get the $gemRecipe right though.");
	}
	if ($text =~/Infinity Armor/i)	{
		$client->Message(315,"$Koolag sells Infinity Armor pieces for each armor type (plate, chain, leather, and cloth). Make sure you purchase the right type or you will have wasted your money. After you buy a piece hand it back to him and he'll tailor it to only fit you, but that will take a day though. (Doing this creates a new item in the database, which can't be accessed until the $serverInfo resets. The server resets every night. You will receive a $infinityArmorToken for the armor piece type you turned in so that the next day you can redeem it.)");
	}
	if ($text =~/Armor Token/i) {
		$client->Message(315,"Infinity Armor Tokens are used to redeem brand new $infinityArmor pieces that he have custom tailored for you (but only after the $serverInfo has reset). Once you have received a custom armor piece you can then bring it to $Koolag so he can $magicallySmelt $statCrystals into it.");
	}
	if ($text =~/magically smelt/i)	{
		$client->Message(315,"Yes, it is quite a process requiring some deep magic and heavy smithing. $Koolag will only use the $statCrystals that he got in storage for you. And he will have to $strCompute how many crystals to use each time he updates one of your $infinityArmor pieces according to how much there is in yout storage and what crystals have already been imbued into your armor piece. (The new stats added to an armor piece will not appear until after the $serverInfo resets.)");
	}
	if ($text =~/compute/i)	{
		$client->Message(315,"Well, it takes 1 crystal to raise a stat to +1. It takes 2 crystals to go from +1 to +2, and then 3 crystals to go from +2 to +3 and so on. So he just check all of your $statCrystals in storage, and for all of the stats you have enough crystals to do some smelting on the particular piece you've just handed to me, he just perform it all at once. So what he am saying is he apply all of the crystals that he can for a given armor piece, easier that way. Do you worry now, he am great at calculations and any $leftovers will stay in your storage for the next $infinityArmor piece you want imbued.");
	}
	if ($text =~/left overs/i)	{
		$client->Message(315,"Good question, lemme give you an example, prolly the best way to explain. Say you have 4 STR Crystals, 7 AC Crystals, 2 Mana Point Crystals and nothing else in storage. Then you hand him some Infinity Boots that already have +2 STR but no other stats. he will try to apply everything that you have in your storage to your boots. To go from +2 to +3 costs 3 STR Crystals with one left over that would remain in your storage. For AC +1 costs 1, +2 costs to more than that, and +3 an additional 3, so 6 AC Crystals total leaving one. And then for Mana Points he could make the boots +1. So he will $magicallySmelt all of those changes, and you get boots that are +3 STR, +3 AC, and +1 Mana Points (the new stats on the boots will not appear until after the $serverInfo resets). In storage you would have 1 STR Crystal, 1 AC Crystal, and 1 Mana Point Crystal that could then be used for some other $infinityArmor piece (although, unless you added more $statCrystals to your storage you could only upgrade armor pieces that have no STR, AC or Mana Points on them already since it costs one crystal to go from zero to +1, and all you have is one crystal each in those categories). ");
	}
	if ($text =~/recipe/i)	{
		$client->Message(315,"When combining $statGems into $statCrystals you always need one $fusionElixir, which $Koolag can sell to you. As for the rest of the recipe, for Hit Point Crystals, Mana Point Crystals, and Endurance Point Crystals you'll need 2 gems (of the same type of course), and all the other stat crystals take 9 gems of the same kind to make a crystal.");
	}
	if ($text =~/tomorrow/i)	{
		$client->Message(15,"The Infinity Server gets reset every night when it reboots. This allows changes in the database to be loaded for client (your) use. This includes having an armor piece tailor made for your character, and adding stats to your custom $infinityArmor.");
	}
	
	if ($text =~ /spare coins/i) {
		if (defined $qglobals{charity_count}) {
			quest::setglobal("charity_count", $qglobals{charity_count} + 1, 5, "F");
		}
		else {
			quest::setglobal("charity_count", 1, 5, "F");
		}
		my $random_copper = ceil(rand(8)); # 1-8
		my $random_silver = int(rand(2)); # 0-1
		quest::givecash($random_copper,$random_silver,0,0);
		$client->Message(315, "There ya go.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}
