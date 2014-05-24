#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			3 Aug 2011
# Last Edit Date:		16 Sep 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Hand in a piece of Infinity armor and an Infinity Crystal and have the armor upgraded
# ==============================================================

use DBI;
use warnings;

use constant {
	TRUE => 1,
	FALSE => '',
	MIN_CRYSTAL_ID => 253101,
	MAX_CRYSTAL_ID => 256400,
	MIN_NEW_INFINITY_ARMOR_ID => 252501,
	MAX_NEW_INFINITY_ARMOR_ID => 252528,
	MIN_NEW_INFINITY_CLOTH_ID => 252501,
	MAX_NEW_INFINITY_CLOTH_ID => 252507,
	MIN_NEW_INFINITY_LEATHER_ID => 252508,
	MAX_NEW_INFINITY_LEATHER_ID => 252514,
	MIN_NEW_INFINITY_CHAIN_ID => 252515,
	MAX_NEW_INFINITY_CHAIN_ID => 252521,
	MIN_NEW_INFINITY_PLATE_ID => 252522,
	MAX_NEW_INFINITY_PLATE_ID => 252528,
	MIN_INFINITY_ARMOR_TOKEN_ID => 252551,
	MAX_INFINITY_ARMOR_TOKEN_ID => 252558,
	HEAD_SLOT_TOKEN_ID => 252551,
	ARM_SLOT_TOKEN_ID => 252552,
	RIGHT_WRIST_SLOT_TOKEN_ID => 252553,
	LEFT_WRIST_SLOT_TOKEN_ID => 252554,
	HAND_SLOT_TOKEN_ID => 252555,
	CHEST_SLOT_TOKEN_ID => 252556,
	LEGS_SLOT_TOKEN_ID => 252557,
	FEET_SLOT_TOKEN_ID => 252558,
	INFINITY_JEWELERS_KIT_ID => 253000,
	ARMORCRYSTAL_FUSIONELIXIR => 253034
};

my %GetArmorType = (	#Convert each Class Name into an Armor Type Name
	"Warrior" => "Plate",
	"Paladin" => "Plate",
	"Cleric" => "Plate",
	"Shadowknight" => "Plate",
	"Bard" => "Plate",
	"Rogue" => "Chain",
	"Berserker" => "Chain",
	"Ranger" => "Chain",
	"Shaman" => "Chain",
	"Monk" => "Leather",
	"Beastlord" => "Leather",
	"Druid" => "Leather",
	"Wizard" => "Cloth",
	"Magician" => "Cloth",
	"Enchanter" => "Cloth",
	"Necromancer" => "Cloth"
);

#database configuration information
#$db="peq";
#$host="localhost";
#$user="root";
#$password="33heLM70";

#connect to MySQL database
#$dbh = DBI->connect ("DBI:mysql:database=$db:host=$host", $user, $password);
#my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host;mysql_multi_results=1", $user, $password) or die "Failed to connect";
#$sql = ""; # for creating SQL scripts

my $debug = 1;
	
sub EVENT_SAY {
	my $infinityArmor = quest::saylink("Infinity Armor",1);
	my $infinityStorage = quest::saylink("storage",1);
	my $statGems = quest::saylink("Stat Gems",1);
	my $statCrystals = quest::saylink("Stat Crystals",1);
	my $infinityArmorToken = quest::saylink("Armor Token",1);
	my $magicallySmelt = quest::saylink("magically smelt",1);
	my $strCompute = quest::saylink("compute",1);
	my $gemRecipe = quest::saylink("recipe",1);
	my $leftovers = quest::saylink("left overs",1);
	my $tomorrow = quest::saylink("tomorrow",1);

	my $infinityJewelersKit = quest::varlink(INFINITY_JEWELERS_KIT_ID);
	my $fusionElixir = quest::varlink(ARMORCRYSTAL_FUSIONELIXIR);
	
	if ($text=~/Hail/i) {
		$client->Message(315,"Hand me $statCrystals and I will store them for you. Would you like to see what you have in $infinityStorage? Hand me an $infinityArmor piece and I'll $magicallySmelt all your crystals to it. Hand me a $infinityArmorToken and I'll give you your newly customized armor piece.");
		if ($debug) {
			$client->Message(315,"Your class is $class.");
			$client->Message(315,"Your armor is $GetArmorType{$class}");
		}
	}
	if ($text =~/storage/i)	{
		#$sql = "SELECT * FROM inf_characterarmorcrystals WHERE CharacterID = $charid;";
		#my $showStorage = $dbh->prepare($sql);
		#$showStorage->execute();
		#my @row = $showStorage->fetchrow_array();
		my @row = callDatabase("SELECT * FROM inf_characterarmorcrystals WHERE CharacterID = $charid;",1);
		DisplayCrystals(@row, "$name`s Crystals");
	}
	
	if ($text =~/test/i)	{
		my @row = callDatabase("UPDATE launcher SET dynamics=4 WHERE name = 'zone';",1);
		$client->Message(315,"database results are: $row[0]");
	}
	
	if ($text =~/stat crystals/i)	{
		$client->Message(315,"Infinity Crystals are made from $statGems. I will keep your crystals in $infinityStorage for you--just hand them to me and they'll be safe. When you are ready, give me one of your personal $infinityArmor pieces and I'll $magicallySmelt all the crystals in your storage into it and then give it back to you. The crystals imbue the armor with power (and raise the stats).");
	}
	if ($text =~/stat gems/i)	{
		$client->Message(315,"Infinity Gems can be combined with some $fusionElixir (which I sell) in an $infinityJewelersKit to create Infinity $statCrystals. Make sure you get the $gemRecipe right though.");
	}
	if ($text =~/Infinity Armor/i)	{
		$client->Message(315,"I sell Infinity Armor pieces for each armor type (plate, chain, leather, and cloth). Make sure you purchase the right type or you will have wasted your money. After you buy a piece hand it back to me and I'll tailor it to only fit you, but that will take a day though. (Doing this creates a new item in the database, which can't be accessed until the server resets. The server resets every night. For this first time only you will receive a $infinityArmorToken for the armor piece type you turned in so that the next day you can redeem it.)");
	}
	if ($text =~/Armor Token/i) {
		$client->Message(315,"Infinity Armor Tokens are used to redeem brand new $infinityArmor pieces that I have custom tailored for you (but only after the server has reset). The token trade in is a first-time only process. Once you have received a custom armor piece you can then bring it to me and hand it in so I can $magicallySmelt $statCrystals into it.");
	}
	if ($text =~/magically smelt/i)	{
		$client->Message(315,"Yes, it is quite a process requiring some deep magic and heavy smithing. Hand me one of your armor pieces and I'll use the $statCrystals that I got in $infinityStorage to add stats to it for you. And I do have to $strCompute how many crystals to use each time I update one of your $infinityArmor pieces according to how much there is in yout storage and what crystals have already been imbued into your armor piece. (The new stats added to an armor piece will not appear until after the server resets.)");
	}
	if ($text =~/compute/i)	{
		$client->Message(315,"Well, it takes 1 crystal to raise a stat to +1. It takes 2 crystals to go from +1 to +2, and then 3 crystals to go from +2 to +3 and so on. So I just check all of your $statCrystals in $infinityStorage, and for all of the stats you have enough crystals to do some smelting on the particular piece you've just handed to me, I just perform it all at once. So what I am saying is I apply all of the crystals that I can for a given armor piece, easier that way. Do you worry now, I am great at calculations and any $leftovers will stay in your storage for the next $infinityArmor piece you want imbued.");
	}
	if ($text =~/left overs/i)	{
		$client->Message(315,"Good question, lemme give you an example, prolly the best way to explain. Say you have 4 STR Crystals, 7 AC Crystals, 2 Mana Point Crystals and nothing else in $infinityStorage. Then you hand me some Infinity Boots that already have +2 STR but no other stats. I will try to apply everything that you have in your storage to your boots. To go from +2 to +3 costs 3 STR Crystals with one left over that would remain in your storage. For AC +1 costs 1, +2 costs to more than that, and +3 an additional 3, so 6 AC Crystals total leaving one. And then for Mana Points I could make the boots +1. So I $magicallySmelt all of those changes, and you get boots that are +3 STR, +3 AC, and +1 Mana Points (the new stats on the boots will not appear until after the server resets). In storage you would have 1 STR Crystal, 1 AC Crystal, and 1 Mana Point Crystal that could then be used for some other $infinityArmor piece (although, unless you added more $statCrystals to your storage you could only upgrade armor pieces that have no STR, AC or Mana Points on them already since it costs one crystal to go from zero to +1, and all you have is one crystal each in those categories). ");
	}
	if ($text =~/recipe/i)	{
		$client->Message(315,"When combining $statGems into $statCrystals you always need one $fusionElixir, which I can sell to you. As for the rest of the recipe, for Hit Point Crystals, Mana Point Crystals, and Endurance Point Crystals you'll need 2 gems (of the same type of course), and all the other stat crystals take 9 gems of the same kind to make a crystal.");
	}
	if ($text =~/tomorrow/i)	{
		$client->Message(15,"[Out-of-character Koolag explains, 'The Infinity Server gets reset every night when it reboots. This allows changes in the database to be loaded for client (your) use. This includes both having a new armor piece tailor made for your character (the one-time-only token trade-in thing), and adding stats to your custom $infinityArmor.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	my @itemArray = ();
	my $prestigeLevel = $qglobals{prestige_level};
	if ($prestigeLevel < 1) {$prestigeLevel = 1;} # If it is zero it will mess up the stats in the formula below, so make it at least 1

	# parse each given item into an array @itemArray
	if ($item1) {push(@itemArray, $item1);}
	if ($item2) {push(@itemArray, $item2);}
	if ($item3) {push(@itemArray, $item3);}
	if ($item4) {push(@itemArray, $item4);}
	
	#pull while loop and initial if statements for first 3 out here
	@itemArray = ProcessCrystals(@itemArray);
	@itemArray = CustomizeArmor(@itemArray);
	@itemArray = DeliverArmor(@itemArray);
	
	foreach (@itemArray) {
		#my $sql = "CALL sps_IdentifyCustomArmorPiece($_, $charid)";
		#if ($debug) {$client->Message(1,"$sql");} #debug
		#my $identifyCustomArmor = $dbh->prepare($sql);
		#$identifyCustomArmor->execute();
		#my @customArmor = $identifyCustomArmor->fetchrow_array();
		my @customArmor = callDatabase("CALL sps_IdentifyCustomArmorPiece($_, $charid)",TRUE);
		if ($customArmor[0] > 0) {
			if ($debug) {$client->Message(1,"It is custom armor.");} #debug
			#$sql = "SELECT * FROM inf_characterarmorcrystals WHERE CharacterID = $charid;";
			#if ($debug) {$client->Message(1,"$sql");} #debug
			#my $getCrystals = $dbh->prepare($sql);
			#$getCrystals->execute();
			#my @crystalStorage = $getCrystals->fetchrow_array();
			my @crystalStorage = callDatabase("SELECT * FROM inf_characterarmorcrystals WHERE CharacterID = $charid;",TRUE);
			DisplayCrystals(@crystalStorage, "$name`s Crystals");
			#$sql = "SELECT 0, $charid, endur, mana, hp, ac, pr, mr, dr, fr, cr, astr, asta, aagi, adex, awis, aint, acha, attack, regen, manaregen, enduranceregen, accuracy, avoidance, combateffects, dotshielding, stunresist, strikethrough, spellshield, shielding, damageshield, haste, weight, light, 0 FROM items WHERE id = $_;";
			#if ($debug) {$client->Message(1,"$sql");} #debug
			#my $getItemStats = $dbh->prepare($sql);
			#$getItemStats->execute();
			#my @currentStats = $getItemStats->fetchrow_array();
			my @currentStats = callDatabase("SELECT 0, $charid, endur, mana, hp, ac, pr, mr, dr, fr, cr, astr, asta, aagi, adex, awis, aint, acha, attack, regen, manaregen, enduranceregen, accuracy, avoidance, combateffects, dotshielding, stunresist, strikethrough, spellshield, shielding, damageshield, haste, weight, light, 0 FROM items WHERE id = $_;",TRUE);
			if ($debug) {$client->Message(13,"Old stats");DisplayCrystals(@currentStats, "Old Stats");} #debug
			for(my $i = 2; $i <= 33; $i++) {
				if ((($i >= 2) && ($i <= 4)) || (($i >= 19) && ($i <= 20))) { #if the stat is one of the points stats (HP, MP, EP) or regen, mana regen
					$currentStats[$i] = int($currentStats[$i] / $prestigeLevel); #convert from prestigeLevel points per crystal-point to accomodate the coming increment 
				}
				if ($i == 32) { # if the stat is weight
					while (($crystalStorage[$i] > 0) && ($currentStats[$i] > 1)) {
						# decrease the weight by ~25%
						if ($debug) {$client->Message(1,"starting weight=$currentStats[$i]");} #debug
						$currentStats[$i] = int($currentStats[$i]/1.33334 + 0.5); # doing an int on the number plus 0.5 is essentially the same as rounding it off (Perl doesn't have a round func)
						if ($debug) {$client->Message(1,"new weight=$currentStats[$i]");} #debug
						$crystalStorage[$i] = $crystalStorage[$i] - 1; #take off one crystal
					}
					if ($currentStats[$i] == 1) {
						$client->Message(315,"The weight for this armor piece has reached 1 and that's the lowest it can go.");
					}
				}
				else {
					while ($crystalStorage[$i] > $currentStats[$i]) {
						$currentStats[$i]++; #increment the stat
						$crystalStorage[$i] = $crystalStorage[$i] - $currentStats[$i]; #take off the price of the stat increase
					}
				}
				if ((($i >= 2) && ($i <= 4)) || (($i >= 19) && ($i <= 20))) { #if the stat is one of the points stats (HP, MP, EP)
					$currentStats[$i] = $currentStats[$i] * $prestigeLevel; #convert back to prestigeLevel points per increment 
				}
			}
			#my $updateItemsSql = "UPDATE items SET endur=$currentStats[2], mana=$currentStats[3], hp=$currentStats[4], ac=$currentStats[5], pr=$currentStats[6], mr=$currentStats[7], dr=$currentStats[8], fr=$currentStats[9], cr=$currentStats[10], astr=$currentStats[11], asta=$currentStats[12], aagi=$currentStats[13], adex=$currentStats[14], awis=$currentStats[15], aint=$currentStats[16], acha=$currentStats[17], attack=$currentStats[18], regen=$currentStats[19], manaregen=$currentStats[20], enduranceregen=$currentStats[21], accuracy=$currentStats[22], avoidance=$currentStats[23], combateffects=$currentStats[24], dotshielding=$currentStats[25], stunresist=$currentStats[26], strikethrough=$currentStats[27], spellshield=$currentStats[28], shielding=$currentStats[29], damageshield=$currentStats[30], haste=$currentStats[31], weight=$currentStats[32], light=$currentStats[33] WHERE id = $_;";
			#if ($debug) {$client->Message(1,"$updateItemsSql");} #debug
			#my $setItemStats = $dbh->prepare($updateItemsSql);
			#$setItemStats->execute();
			callDatabase("UPDATE items SET endur=$currentStats[2], mana=$currentStats[3], hp=$currentStats[4], ac=$currentStats[5], pr=$currentStats[6], mr=$currentStats[7], dr=$currentStats[8], fr=$currentStats[9], cr=$currentStats[10], astr=$currentStats[11], asta=$currentStats[12], aagi=$currentStats[13], adex=$currentStats[14], awis=$currentStats[15], aint=$currentStats[16], acha=$currentStats[17], attack=$currentStats[18], regen=$currentStats[19], manaregen=$currentStats[20], enduranceregen=$currentStats[21], accuracy=$currentStats[22], avoidance=$currentStats[23], combateffects=$currentStats[24], dotshielding=$currentStats[25], stunresist=$currentStats[26], strikethrough=$currentStats[27], spellshield=$currentStats[28], shielding=$currentStats[29], damageshield=$currentStats[30], haste=$currentStats[31], weight=$currentStats[32], light=$currentStats[33] WHERE id = $_;",FALSE);
			#$sql = "UPDATE inf_characterarmorcrystals SET EndurancePoints=$crystalStorage[2], ManaPoints=$crystalStorage[3], HitPoints=$crystalStorage[4], ArmorClass=$crystalStorage[5], PoisonResist=$crystalStorage[6], MagicResist=$crystalStorage[7], DiseaseResist=$crystalStorage[8], FireResist=$crystalStorage[9], ColdResist=$crystalStorage[10], Strength=$crystalStorage[11], Stanima=$crystalStorage[12], Agility=$crystalStorage[13], Dexterity=$crystalStorage[14], Wisdom=$crystalStorage[15], Intelligence=$crystalStorage[16], Charisma=$crystalStorage[17], Attack=$crystalStorage[18], HitPointsRegen=$crystalStorage[19], ManaRegen=$crystalStorage[20], EnduranceRegen=$crystalStorage[21], Accuracy=$crystalStorage[22], Avoidance=$crystalStorage[23], CombatEffects=$crystalStorage[24], DOTShielding=$crystalStorage[25], StunResist=$crystalStorage[26], StrikeThrough=$crystalStorage[27], SpellShielding=$crystalStorage[28], Shielding=$crystalStorage[29], DamageShield=$crystalStorage[30], Haste=$crystalStorage[31], Weight=$crystalStorage[32], Luminescence=$crystalStorage[33] WHERE CharacterID = $charid;";
			#if ($debug) {$client->Message(1,"$sql");} #debug
			#my $UPDATEcharacterarmorcrystals = $dbh->prepare($sql);
			#$UPDATEcharacterarmorcrystals->execute();
			callDatabase("UPDATE inf_characterarmorcrystals SET EndurancePoints=$crystalStorage[2], ManaPoints=$crystalStorage[3], HitPoints=$crystalStorage[4], ArmorClass=$crystalStorage[5], PoisonResist=$crystalStorage[6], MagicResist=$crystalStorage[7], DiseaseResist=$crystalStorage[8], FireResist=$crystalStorage[9], ColdResist=$crystalStorage[10], Strength=$crystalStorage[11], Stanima=$crystalStorage[12], Agility=$crystalStorage[13], Dexterity=$crystalStorage[14], Wisdom=$crystalStorage[15], Intelligence=$crystalStorage[16], Charisma=$crystalStorage[17], Attack=$crystalStorage[18], HitPointsRegen=$crystalStorage[19], ManaRegen=$crystalStorage[20], EnduranceRegen=$crystalStorage[21], Accuracy=$crystalStorage[22], Avoidance=$crystalStorage[23], CombatEffects=$crystalStorage[24], DOTShielding=$crystalStorage[25], StunResist=$crystalStorage[26], StrikeThrough=$crystalStorage[27], SpellShielding=$crystalStorage[28], Shielding=$crystalStorage[29], DamageShield=$crystalStorage[30], Haste=$crystalStorage[31], Weight=$crystalStorage[32], Luminescence=$crystalStorage[33] WHERE CharacterID = $charid;",FALSE);
			DisplayCrystals(@crystalStorage, "$name`s Crystals");
			$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
			DisplayCrystals(@currentStats, "New Stats*");
			$client->Message(281,"*These new stats will not be loaded onto your armor piece until the server resets.");
			plugin::takeItems($_ => 1); # remove item from default items list/array (so it is not returned with the default plugin::returnUnusedItems)
			quest::summonitem($_); #manual (as opposed to using the plugin) return of the newly modified custom armor piece
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
	plugin::returnUnusedItems();
}

# Args: String sqlStatement, Boolean returnResults
# Returns: Array databaseResults
sub callDatabase {
	my $db="peq";
	my $host="localhost";
	my $user="root";
	my $password="33heLM70";
	my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host", $user, $password);
	#my $dbh = DBI->connect ("DBI:mysql:database=$db:host=$host;mysql_multi_results=1", $user, $password) or die "Failed to connect";
	my @dataBaseResults = ();
	if ($debug) {$client->Message(1,"sql=$_[0]");} #debug
	my $getData = $dbh->prepare($_[0]);
	$getData->execute( );
	@dataBaseResults = $getData->fetchrow_array();
	if ($_[1]) { # if returning results
		if (!defined $dataBaseResults[0]) { #if no valid results came back from the DB
			if ($debug) {$client->Message(13,"Failed to get valid results from the database.");} #debug
		}
		return (@dataBaseResults);
	}
}

sub ProcessCrystals {
	my $displayCharacterCrystalStorage = 0;
	my @oneCrystal = ();
	# my @_ = @_;
	if ($debug) {$client->Message(1,"ProcessCrystals _= @_");} #debug
	# iterate over the @_ array removing some items (to reduce overhead in the last foreach loop)
	my $index = 0;
	while ($index <= $#_ ) {
		if (($_[$index] >= MIN_CRYSTAL_ID) && ($_[$index] <= MAX_CRYSTAL_ID)) {
			#$sql = "CALL spu_CharacterArmorCrystal($_[$index], $charid)";
			#if ($debug) {$client->Message(1,"sql=$sql");} #debug
			#my $armorCrystal = $dbh->prepare($sql);
			#$armorCrystal->execute( );
			#@oneCrystal = $armorCrystal->fetchrow_array();
			@oneCrystal = callDatabase("CALL spu_CharacterArmorCrystal($_[$index], $charid)",1);
			if (defined $oneCrystal[1]) { #if some valid results came back from the DB
				$displayCharacterCrystalStorage = 1;
				my $crystalItemLink = quest::varlink($_[$index]);
				$client->Message(315,"Ok $name, I've added that $crystalItemLink to your storage.");
				plugin::takeItems($_[$index] => 1);
				splice(@_, $index, 1); # remove item from the array (to reduce overhead in the last foreach loop)
			}
			else {
				$client->Message(13,"ERROR: Likely with the database connection, please try again.");
				$index++;
			}
		}
		else {
			$index++;
		}
	}
	if ($displayCharacterCrystalStorage) {
		DisplayCrystals(@oneCrystal, "$name`s Crystals");
	}
	return @_;
}

sub CustomizeArmor { # First time only, putting the characters name on a new item in the db
	my @itemArray = @_;
	my $index = 0; #reset for new loop
	while ($index <= $#itemArray ) {
		if ($debug) {$client->Message(1,"Checking $itemArray[$index]");} #debug
		if (($itemArray[$index] >= MIN_NEW_INFINITY_ARMOR_ID) && ($itemArray[$index] <= MAX_NEW_INFINITY_ARMOR_ID)) {
			# check the char class against the item ID to make sure they are handing in the right one
			my $armorMatchClass = 0;
			if ($GetArmorType{$class} =~/cloth/i) {
				if (($itemArray[$index] >= MIN_NEW_INFINITY_CLOTH_ID) && ($itemArray[$index] <= MAX_NEW_INFINITY_CLOTH_ID)) {
					$armorMatchClass = 1;
				}
				else {
					$client->Message(315,"Ummm $name, $class`s cannot wear that kind of Infinity armor. You needed to purchase $GetArmorType{$class}.");
				}
			}
			elsif ($GetArmorType{$class} =~/leather/i) {
				if (($itemArray[$index] >= MIN_NEW_INFINITY_LEATHER_ID) && ($itemArray[$index] <= MAX_NEW_INFINITY_LEATHER_ID)) {
					$armorMatchClass = 1;
				}
				else {
					$client->Message(315,"Ummm $name, $class`s cannot wear that kind of Infinity armor. You needed to purchase $GetArmorType{$class}.");
				}
			}
			elsif ($GetArmorType{$class} =~/chain/i) {
				if (($itemArray[$index] >= MIN_NEW_INFINITY_CHAIN_ID) && ($itemArray[$index] <= MAX_NEW_INFINITY_CHAIN_ID)) {
					$armorMatchClass = 1;
				}
				else {
					$client->Message(315,"Ummm $name, $class`s cannot wear that kind of Infinity armor. You needed to purchase $GetArmorType{$class}.");
				}
			}
			elsif ($GetArmorType{$class} =~/plate/i) {
				if (($itemArray[$index] >= MIN_NEW_INFINITY_PLATE_ID) && ($itemArray[$index] <= MAX_NEW_INFINITY_PLATE_ID)) {
					$armorMatchClass = 1;
				}
				else {
					$client->Message(315,"Ummm $name, $class`s cannot wear that kind of Infinity armor. You needed to purchase $GetArmorType{$class}.");
				}
			}
			if ($armorMatchClass) {
				if ($debug) {$client->Message(1,"$itemArray[$index] = is new armor");} #debug
				#$sql = "CALL spi_CustomArmorPiece($itemArray[$index], $charid, '$name')";
				#if ($debug) {$client->Message(1,"$sql");} #debug
				#my $newCustomArmor = $dbh->prepare($sql);
				#$newCustomArmor->execute();
				#my @newArmor = $newCustomArmor->fetchrow_array();
				my @newArmor = callDatabase("CALL spi_CustomArmorPiece($itemArray[$index], $charid, '$name')",1);
				if ($debug) {$client->Message(1,"Result (slots)= $newArmor[1]");} #debug
				if ($newArmor[1] > -1) { # newArmor[0] = id; newArmor[1] = slot; newArmor[2] = right/left wrist
					plugin::takeItems($itemArray[$index] => 1);
					splice(@itemArray, $index, 1); # remove item from the array (to reduce overhead in the last foreach loop)
					$client->Message(315,"Your new custom Infinity armor piece ID# = $newArmor[0], and here's a token so you can retrieve it when the server resets. (This token trade-in is a first-time-only process.)");
					if ($newArmor[1] == 4) { # Head slot
						quest::summonitem(HEAD_SLOT_TOKEN_ID);
					}
					elsif ($newArmor[1] == 128) { # Arm slot
						quest::summonitem(ARM_SLOT_TOKEN_ID);
					}
					elsif ($newArmor[1] == 1536) { # Right Wrist slot
						if ($newArmor[2] == 1) {
							quest::summonitem(RIGHT_WRIST_SLOT_TOKEN_ID);
						}
						else {
							quest::summonitem(LEFT_WRIST_SLOT_TOKEN_ID);
						}
					}
					elsif ($newArmor[1] == 4096) { # Hand slot
						quest::summonitem(HAND_SLOT_TOKEN_ID);
					}
					elsif ($newArmor[1] == 131072) { # Chest slot
						quest::summonitem(CHEST_SLOT_TOKEN_ID);
					}
					elsif ($newArmor[1] == 262144) { # Legs slot
						quest::summonitem(LEGS_SLOT_TOKEN_ID);
					}
					elsif ($newArmor[1] == 524288) { # Feet slot
						quest::summonitem(FEET_SLOT_TOKEN_ID);
					}
					else {
						$client->Message(13,"ERROR: Unknown slot returned from spi_CustomArmorPiece.");
					}
				}
				else {
					$client->Message(315,"You have already established a custom Infinity armor piece for this slot, the ID# = $newArmor[0].");
					$index++;
				}
			}
			else {
				$index++;
			}
		}
		else {
			$index++;
		}
	}
	return @itemArray;
}

sub DeliverArmor {
	my @itemArray = @_;
	my $infinityArmor = quest::saylink("Infinity Armor",1);
	my $index = 0; #reset for new loop
	while ($index <= $#itemArray ) {
		if (($itemArray[$index] >= MIN_INFINITY_ARMOR_TOKEN_ID) && ($itemArray[$index] <= MAX_INFINITY_ARMOR_TOKEN_ID)) {
			if ($debug) {$client->Message(1,"$itemArray[$index] = is a token");} #debug
			#my $sql = "CALL sps_RetrieveCustomArmorPiece($itemArray[$index], $charid)";
			#if ($debug) {$client->Message(1,"$sql");} #debug
			#my $getCustomArmor = $dbh->prepare($sql);
			#$getCustomArmor->execute();
			#my @personalArmor = $getCustomArmor->fetchrow_array();
			my @personalArmor = callDatabase("CALL sps_RetrieveCustomArmorPiece($itemArray[$index], $charid)",TRUE);
			if ($debug) {$client->Message(1,"result= $personalArmor[0]");} #debug
			if ($personalArmor[0] > -1) {
				my $VerifiedID = $client->GetItemStat($personalArmor[0], "id");
				if (!$VerifiedID)
				{
					if ($debug) {$client->Message(1,"This item does not yet exist.");} #debug
					$client->Message(315,"I could not find your $infinityArmor $name, the server needs to reset before I can.");
					quest::summonitem($itemArray[$index]); #manual return of the currently unredeemable token (server needs to reset)
				}
				else
				{
					if ($debug) {$client->Message(1,"This item exists.");} #debug
					$client->Message(315,"Here you go $name, a customized, shiny, new piece of $infinityArmor.");
					quest::summonitem($personalArmor[0]);
				}
				plugin::takeItems($itemArray[$index] => 1); # either way token is taken, but may have been returned manually, see above
				splice(@itemArray, $index, 1); # remove item from the array (to reduce overhead in the last foreach loop)
			}
			else {
				$client->Message(13,"ERROR: Could not find the item in the database.");
				$index++;
			}
		}
		else {
			$index++;
		}
	}
	return @itemArray;
}

sub DisplayCrystals {
	$client->Message(10,"================== $_[35] ==================");
	$client->Message(16,"AC:$_[5]");
	$client->Message(270,"STR:$_[11] DEX:$_[14] STA:$_[12] CHA:$_[17] WIS:$_[15] INT:$_[16] AGI:$_[13]");
	$client->Message(18,"HP:$_[4] Mana:$_[3] Endur:$_[2]") ;  
	$client->Message(285,"SV-FIR:$_[9] SV-DIS:$_[8] SV-COL:$_[10] SV-MAG:$_[7] SV-POI:$_[6]");
	$client->Message(14,"Atk:$_[18] HPRegen:$_[19] ManaRegen:$_[20] EndurRegen:$_[21]") ;  
	$client->Message(15,"DmgShld:$_[30] CmbtEff:$_[24] Shld:$_[29] SpellShld:$_[28]");
	$client->Message(290,"Avoid:$_[23] Accuracy:$_[22] StunResist:$_[26]");
	$client->Message(13,"StrikeThrough:$_[27] DOTShld:$_[25] Haste:$_[31]");
	$client->Message(4,"Weight:$_[32] Luminescence:$_[33]");
}