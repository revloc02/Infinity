#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			9 Nov 2011
# Last Edit Date:		21 Feb 2013
# Software Application:	EQEmu, Infinity Server
# Description:			Prestige Quest (de-level) for an earring that levels
# ==============================================================

use warnings;
use DBI;
use POSIX; # implements ceil(), floor(), and a number of other mathematical and trigonometric functions.

use constant {
	TRUE => 1,
	FALSE => '',
	MAX_NONINFINITY_ITEM_ID => 250000, # the maximum non-Infinity item in the db. In other words player are allowed to prestige wearing their Infinity Items and custom Infinity Armor
	FIRST_PRESTIGE_ITEM => 252101, # Prestige Item Level 1
	LAST_PRESTIGE_ITEM => 252200,
	CRYSTALS_PER_PRESTIGE => 20,
	REWARD_ROI_UPGRADE_ID => 250000, # bonus reward ROI upgrade
	ADDITIONAL_REWARDS_FREQUENCY => 2, # 2=every even Prestige (3 would be every third Prestige)
	AA_NEEDED_EXPONENT => 1.6, # 
	DS_CRYSTAL_BONUS_EXPONENT => 1.5, # Bonus Damage Shield Crystals exponent of Prestige Level

	# crystal reward ranges
	ENDUR => 		10,
	MANA => 		86,
	HP =>			353,
	AC => 			1039,
	POI => 			1725,
	MAG => 			2411,
	DIS => 			3097,
	FIR => 			3783,
	COL => 			4469,
	STR => 			5155,
	STA => 			5841,
	AGI => 			6527,
	DEX => 			7213,
	WIS => 			7899,
	INT => 			8585,
	CHA => 			9271,
	ATK => 			9317,
	HP_REGEN => 	9320,
	MANA_REGEN => 	9321,
	ENDUR_REGEN => 	9322,
	ACCURACY => 	9398,
	AVOIDANCE => 	9406,
	COMBAT_EFFECTS => 	9429,
	DOT_SHIELD => 	9437,
	STUN_RESIST => 	9445,
	STRIKETHROUGH => 9453,
	SPELL_SHIELD =>	9461,
	SHIELD => 		9469,
	DAMAGE_SHIELD => 9621,
	HASTE => 		9950,
	REROLL_1 => 	9990,
	REROLL_5 => 	9999,
	REROLL_10 => 	10000
};

my $debug = TRUE;
my $bonusDsCrystals = TRUE; # boolean: add a bonus of Damage Shield crystals on to crystal rewards
	
sub EVENT_SAY {
	establishQuestGlobals();
	my $prestigeLevel = $qglobals{prestige_level}; # this is the number of times a character has Prestiged
	my $ready = quest::saylink("ready",1);
	
	if ($text=~/Hail/i) {
		if ($debug) {$client->Message(1,"prestige_level qglobals=$prestigeLevel");} #debug
		$client->Message(315,"123Prestige Quest is when you reach a high level and then start over at level 1. Your first time you can Pretige at level 50. The second through fourth time you can Prestige at level 60. After that you can Prestige at level 65. You will receive a useful earring that upgrades every time you Prestige. In order to Prestige you must remove all weapons and armor except for Infinity Items and your own custom Infinity Armor. Are you $ready to Prestige?");
	}
	if ($text =~ /ready/i)	{
		if ($qglobals{prestige_level} == 0) {
			if (prestigeReady($prestigeLevel)) {
				executePrestige($prestigeLevel, FIRST_PRESTIGE_ITEM);
				$client->Message(315,"You are on your way $name.");
			}
		}
		else {
			$client->Message(315,"$name you have Prestiged before, you need to turn in your earring each time you Prestige again.");
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	establishQuestGlobals();
	my $prestigeLevel = $qglobals{prestige_level};
	my @itemArray = ();
	
	if ($item1) {push(@itemArray, $item1);}
	if ($item2) {push(@itemArray, $item2);}
	if ($item3) {push(@itemArray, $item3);}
	if ($item4) {push(@itemArray, $item4);}
	
	my $index = 0;
	while ($index <= $#itemArray ) { # the $#array construction returns the subscript, or index, of the last element of the array
		if (($itemArray[$index] >= FIRST_PRESTIGE_ITEM) && ($itemArray[$index] < LAST_PRESTIGE_ITEM)) {
			if (prestigeReady($prestigeLevel)) {
				plugin::takeItems($itemArray[$index] => 1);
				executePrestige($prestigeLevel, (FIRST_PRESTIGE_ITEM + $prestigeLevel));
				$client->Message(315,"Gaining more Prestige you are $name.");
			}
		}
		if ($itemArray[$index] == LAST_PRESTIGE_ITEM) {
			$client->Message(315,"$name you've Prestiged as high as you can go. I guess that is why it is called a Finite earring.");
		}
		$index++;
	}
	plugin::returnUnusedItems();
}

# Args: int prestigeLevel, int prestigeItemLevel
# Returns: void
sub executePrestige {
	$_[0]++;
	additionalRewards($_[0]);
	crystalRewards($_[0]);
	adjustInfinityArmorStats($_[0]);
	quest::summonitem($_[1]);
	$client->UnmemSpellAll();
	quest::level(1);
	quest::setglobal("prestige_level", $_[0], 5, "F");
	quest::ding(); # not really a ding, it's the quest complete fanfare
}

# Args: int prestigeLevel
# Returns: boolean allReadyToPrestige
sub prestigeReady {
	my $allReady = FALSE;
	my $levelToAllowPrestige = 65;
	if ($_[0] == 0) {$levelToAllowPrestige = 50;} # Classic EQ max level
	if (($_[0] >= 1) && ($_[0] <= 3)) {$levelToAllowPrestige = 60;} # Kunark through Luclin max level
	# if (($_[0] >= 4) && ($_[0] <= 7)) {$levelToAllowPrestige = 65;} # Planes of Power through Discord max level (this is if I wanted to make the default $levelToAllowPrestige = 70)
	if ($debug) {$client->Message(1,"_= $_[0] ");} #debug
	if ($debug) {$client->Message(1,"levelToAllowPrestige=$levelToAllowPrestige");} #debug
	if ($ulevel >= $levelToAllowPrestige) {
		my $s_id;	#slot_id that will be looked at, defined in the for loop
		my $ii = 0;	#how many total items you have in your inventory
		for ($s_id = 0; $s_id <= 21; $s_id++) {	#look at just visible slots 0-21
			my $temp = $client->GetItemIDAt($s_id);
			if (($client->GetItemIDAt($s_id) > 0) && ($client->GetItemIDAt($s_id) <= MAX_NONINFINITY_ITEM_ID)) {
				$ii++;
			}
		}
		if ($ii == 0) {
			if ($_[0] < 10) {
				$allReady = TRUE;
			}
			else {
				my $spentAAs = $client->GetSpentAA();
				my $spentAAneeded = int($_[0]**AA_NEEDED_EXPONENT);
				if ($debug) {$client->Message(1,"spentAAs = $spentAAs, spentAAneeded = $spentAAneeded");} #debug
				if ($spentAAs >= $spentAAneeded) {
					$allReady = TRUE;
				}
				else {
					$client->Message(315,"Sorry $name, you need to have $spentAAneeded AA Points Spent to Prestige this time.");
				}
			}
		}
		else {
			$client->Message(315,"Sorry $name, you've got like $ii more items you need to remove (you can only be wearing custom Infinity Armor, remove all other armor and weapons).");
		}
	}
	else {
		$client->Message(315,"Sorry $name, you must be at least level $levelToAllowPrestige to Prestige this time.");
	}
	return $allReady;
}

# Args: int prestigeLevel
# Returns: void
sub adjustInfinityArmorStats { #Find PCs Inf Armor, divide HP, MP, and EP by previous Prestige level, and then multiply it by new Prestige level
	if ($_[0] > 1) {
		my $sql = "CALL spu_PrestigeIncreaseArmorStats('$name', $_[0])";
		plugin::callDatabase($sql,FALSE,$debug);
		$client->Message(315,"Your Infinity Armor has been upgraded, hp, mp, ep, regen, and mana regen are now in multiples of $_[0] (changes will take effect when the server resets), and will continue to increment in multiples of $_[0] as you turn in more Crystals.");
	}
}

# Args: int prestigeLevel
# Returns: void
sub additionalRewards {
	if ($_[0]%ADDITIONAL_REWARDS_FREQUENCY == 0) { # for example if ADDITIONAL_REWARDS_FREQUENCY=2 then you get an additional reward every even level
		my $roiUpgradeLink = quest::varlink(REWARD_ROI_UPGRADE_ID);
		$client->Message(315,"You get a $roiUpgradeLink for Pretiging this time.");
		quest::summonitem(REWARD_ROI_UPGRADE_ID);
	}
}

# Args: int prestigeLevel
# Returns: void
sub crystalRewards {
	if ($debug) {$client->Message(1,"crystalRewards prestige = $_[0]");} #debug
	my $extraRolls = 0;
	my @crystalReward = ();
	my $maxIterations = $_[0]*CRYSTALS_PER_PRESTIGE;
	if ($debug) {$client->Message(1,"maxIterations = $maxIterations");} #debug
	for (my $p = 0; $p < $maxIterations; $p++) {
		my $randReward = ceil(rand(10000));
		if (($randReward >= 1) && ($randReward <= ENDUR)) {
			$crystalReward[2]++; # endur
		}
		if (($randReward >= (ENDUR+1)) && ($randReward <= MANA)) {
			$crystalReward[3]++; # mana
		}
		if (($randReward >= (MANA+1)) && ($randReward <= HP)) {
			$crystalReward[4]++; # hp
		}
		if (($randReward >= (HP+1)) && ($randReward <= AC)) {
			$crystalReward[5]++; # AC
		}
		if (($randReward >= (AC+1)) && ($randReward <= POI)) {
			$crystalReward[6]++; # POI
		}
		if (($randReward >= (POI+1)) && ($randReward <= MAG)) {
			$crystalReward[7]++; # MAG
		}
		if (($randReward >= (MAG+1)) && ($randReward <= DIS)) {
			$crystalReward[8]++; # DIS
		}
		if (($randReward >= (DIS+1)) && ($randReward <= FIR)) {
			$crystalReward[9]++; # FIR
		}
		if (($randReward >= (FIR+1)) && ($randReward <= COL)) {
			$crystalReward[10]++; # COL
		}
		if (($randReward >= (COL+1)) && ($randReward <= STR)) {
			$crystalReward[11]++; # STR
		}
		if (($randReward >= (STR+1)) && ($randReward <= STA)) {
			$crystalReward[12]++; # STA
		}
		if (($randReward >= (STA+1)) && ($randReward <= AGI)) {
			$crystalReward[13]++; # AGI
		}
		if (($randReward >= (AGI+1)) && ($randReward <= DEX)) {
			$crystalReward[14]++; # DEX
		}
		if (($randReward >= (DEX+1)) && ($randReward <= WIS)) {
			$crystalReward[15]++; # WIS
		}
		if (($randReward >= (WIS+1)) && ($randReward <= INT)) {
			$crystalReward[16]++; # INT
		}
		if (($randReward >= (INT+1)) && ($randReward <= CHA)) {
			$crystalReward[17]++; # CHA
		}
		if (($randReward >= (CHA+1)) && ($randReward <= ATK)) {
			$crystalReward[18]++; # ATK
		}
		if (($randReward >= (ATK+1)) && ($randReward <= HP_REGEN)) {
			$crystalReward[19]++; # HP regen
		}
		if (($randReward >= (HP_REGEN+1)) && ($randReward <= MANA_REGEN)) {
			$crystalReward[20]++; # mana regen
		}
		if (($randReward >= (MANA_REGEN+1)) && ($randReward <= ENDUR_REGEN)) {
			$crystalReward[21]++; # endur regen
		}
		if (($randReward >= (ENDUR_REGEN+1)) && ($randReward <= ACCURACY)) {
			$crystalReward[22]++; # accuracy
		}
		if (($randReward >= (ACCURACY+1)) && ($randReward <= AVOIDANCE)) {
			$crystalReward[23]++; # avoidance
		}
		if (($randReward >= (AVOIDANCE+1)) && ($randReward <= COMBAT_EFFECTS)) {
			$crystalReward[24]++; # combat eff
		}
		if (($randReward >= (COMBAT_EFFECTS+1)) && ($randReward <= DOT_SHIELD)) {
			$crystalReward[25]++; # DOT shield
		}
		if (($randReward >= (DOT_SHIELD+1)) && ($randReward <= STUN_RESIST)) {
			$crystalReward[26]++; # stun resist
		}
		if (($randReward >= (STUN_RESIST+1)) && ($randReward <= STRIKETHROUGH)) {
			$crystalReward[27]++; # strikethrough
		}
		if (($randReward >= (STRIKETHROUGH+1)) && ($randReward <= SPELL_SHIELD)) {
			$crystalReward[28]++; # spell shield
		}
		if (($randReward >= (SPELL_SHIELD+1)) && ($randReward <= SHIELD)) {
			$crystalReward[29]++; # shield
		}
		if (($randReward >= (SHIELD+1)) && ($randReward <= DAMAGE_SHIELD)) {
			$crystalReward[30]++; # damage shield
		}
		if (($randReward >= (DAMAGE_SHIELD+1)) && ($randReward <= HASTE)) {
			$crystalReward[31]++; # haste
		}
		if (($randReward >= (HASTE+1)) && ($randReward <= REROLL_1)) {
			$p--; # reroll this current roll and...
			$maxIterations=$maxIterations+1; # ...get an extra roll
			$extraRolls++;
		}
		if (($randReward >= (REROLL_1+1)) && ($randReward <= REROLL_5)) {
			$p--; # reroll this current roll and...
			$maxIterations=$maxIterations+5; # ...get an extra 5 rolls
			$extraRolls=$extraRolls+5;
		}
		if (($randReward >= (REROLL_5+1)) && ($randReward <= REROLL_10)) {
			$p--; # reroll this current roll and...
			$maxIterations=$maxIterations+10; # ...get an extra 10 rolls
			$extraRolls=$extraRolls+10;
		}
	}
	if ($extraRolls) {
		$client->Message(315,"Wow $name, you were lucky and got $extraRolls extra Crystals this time. Yay, more stats for you!");
	}
	if ($bonusDsCrystals) {
		my $bonusDsCrystalsCount = ceil($_[0]**DS_CRYSTAL_BONUS_EXPONENT);
		$crystalReward[30] = $crystalReward[30]+$bonusDsCrystalsCount;
		$client->Message(315,"You have Prestiged $_[0] times so you get $bonusDsCrystalsCount Damage Shield Crystals and $maxIterations more random Crystals automatically added to your Crystal Storage with Koolag.");
	}
	else {
		$client->Message(315,"You have Prestiged $_[0] times so you get $maxIterations random Crystals automatically added to your Crystal Storage with Koolag.");
	}
	
	displayCrystals(@crystalReward);
	saveCrystals(@crystalReward);
}

# Args: int 32crystalRewards
# Returns: void
sub displayCrystals {
	$client->Message(10,"================== Crystal Rewards ==================");
	$client->Message(16,"AC:$_[5]");
	$client->Message(270,"STR:$_[11] DEX:$_[14] STA:$_[12] CHA:$_[17] WIS:$_[15] INT:$_[16] AGI:$_[13]");
	$client->Message(18,"HP:$_[4] Mana:$_[3] Endur:$_[2]") ;  
	$client->Message(285,"SV-FIR:$_[9] SV-DIS:$_[8] SV-COL:$_[10] SV-MAG:$_[7] SV-POI:$_[6]");
	$client->Message(14,"Atk:$_[18] HPRegen:$_[19] ManaRegen:$_[20] EndurRegen:$_[21]") ;  
	$client->Message(15,"DmgShld:$_[30] CmbtEff:$_[24] Shld:$_[29] SpellShld:$_[28]");
	$client->Message(290,"Avoid:$_[23] Accuracy:$_[22] StunResist:$_[26]");
	$client->Message(13,"StrikeThrough:$_[27] DOTShld:$_[25] Haste:$_[31]");
}

# Args: int 32crystalRewards
# Returns: void
sub saveCrystals {
	for (my $i = 0; $i < 32; $i++) { #make NULLs into zeros
		if (!$_[$i]) {
			$_[$i] = 0;
		}
	}
	# need to make sure a record exists to be updated
	my @recordExists = plugin::callDatabase("SELECT CharacterID FROM inf_characterarmorcrystals WHERE CharacterID = $charid;",TRUE,$debug);
	if ($recordExists[0]) {
		plugin::callDatabase("UPDATE inf_characterarmorcrystals SET EndurancePoints=EndurancePoints+$_[2], ManaPoints=ManaPoints+$_[3], HitPoints=HitPoints+$_[4], ArmorClass=ArmorClass+$_[5], PoisonResist=PoisonResist+$_[6], MagicResist=MagicResist+$_[7], DiseaseResist=DiseaseResist+$_[8], FireResist=FireResist+$_[9], ColdResist=ColdResist+$_[10], Strength=Strength+$_[11], Stanima=Stanima+$_[12], Agility=Agility+$_[13], Dexterity=Dexterity+$_[14], Wisdom=Wisdom+$_[15], Intelligence=Intelligence+$_[16], Charisma=Charisma+$_[17], Attack=Attack+$_[18], HitPointsRegen=HitPointsRegen+$_[19], ManaRegen=ManaRegen+$_[20], EnduranceRegen=EnduranceRegen+$_[21], Accuracy=Accuracy+$_[22], Avoidance=Avoidance+$_[23], CombatEffects=CombatEffects+$_[24], DOTShielding=DOTShielding+$_[25], StunResist=StunResist+$_[26], StrikeThrough=StrikeThrough+$_[27], SpellShielding=SpellShielding+$_[28], Shielding=Shielding+$_[29], DamageShield=DamageShield+$_[30], Haste=Haste+$_[31] WHERE CharacterID = $charid;");
	} else {
		plugin::callDatabase("INSERT INTO inf_characterarmorcrystals (CharacterID, EndurancePoints, ManaPoints, HitPoints, ArmorClass, PoisonResist, MagicResist, DiseaseResist, FireResist, ColdResist, Strength, Stanima, Agility, Dexterity, Wisdom, Intelligence, Charisma, Attack, HitPointsRegen, ManaRegen, EnduranceRegen, Accuracy, Avoidance, CombatEffects, DOTShielding, StunResist, StrikeThrough, SpellShielding, Shielding, DamageShield, Haste) VALUES ($charid, $_[2], $_[3], $_[4], $_[5], $_[6], $_[7], $_[8], $_[9], $_[10], $_[11], $_[12], $_[13], $_[14], $_[15], $_[16], $_[17], $_[18], $_[19], $_[20], $_[21], $_[22], $_[23], $_[24], $_[25], $_[26], $_[27], $_[28], $_[29], $_[30], $_[31]);");
	}
}

# Args: none
# Returns: void
sub establishQuestGlobals { # if a quest_global does not exist, this will create one
	quest::setglobal("epic_weapon_level", 0, 5, "F") unless defined $qglobals{epic_weapon_level};
	quest::setglobal("prestige_level", 0, 5, "F") unless defined $qglobals{prestige_level};
	quest::setglobal("guildhall_flag", 0, 5, "F") unless defined $qglobals{guildhall_flag};
	quest::setglobal("spells_scribed_level", 0, 5, "F") unless defined $qglobals{spells_scribed_level};
	quest::setglobal("goldgreat_newbie_charm", 0, 5, "F") unless defined $qglobals{goldgreat_newbie_charm};
}