# ==============================================================
# Author:				Forest Colver
# Create Date:			15 Nov 2010
# Last Edit Date:		31 Mar 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Druid porter for pp
# Zone:					guildlobby
# ==============================================================

#SpellList is the array containing the names of the spells. SpellCost is the amount in pp for each spell. SpellID is the spell that is cast by the npc.
#Note: Each position in each array corresponds to the same position in the other arrays.
@SpellList = ("barindu","bloodfields","buriedsea","butcher","cobaltscar","commons","dawnshroud","dreadlands","eastkorlach","emeraldjungle","feerrott","greatdivide","grimling","iceclad","jaggedpine","lavastorm","lfaydark","misty","moors","natimbi","northkarana","potimea","qrg", "skyfire","sro","steamfont","steppes","stonebrunt","tox","twilight","wakening","wallofslaughter");
@SpellCost = ("32",     "32",         "32",       "2",      "10",        "2",      "15",        "15",        "32",         "15",           "15",      "15",         "5",       "15",     "15",        "15",       "2",       "15",   "32",   "32",     "5",          "32",     "5",   "15",     "15", "15",       "32",     "5",         "2",  "15",      "10",      "32");
@SpellID =   ("5733",   "6185",       "11982",    "552",    "2031",      "531",    "2427",      "1326",      "8237",       "1737",         "536",     "2029",       "2417",    "1433",   "1098",      "534",      "1826",    "538",  "9958", "4967",   "530",        "20540",  "2021","1736",   "535","537",      "9955",   "3794",      "533","2422",    "2030",    "6180");

$stance = 0;
$debug = 0;

sub EVENT_SPAWN {
      quest::settimer("standOrSit", 60);
}

sub EVENT_TIMER {
	if($timer eq "standOrSit") 	{
		if ($stance == 0) {
			$stance = int(rand(5));
			if ($stance == 3) {$stance = 1}
		}
		else {
			$stance = 0;
		}
		$npc->SetAppearance($stance);
	}
}

sub EVENT_SAY {
	my $port = quest::saylink("port",1);
	my $NPCName = $npc->GetCleanName();
	if ($text =~/Hail/i) {
		$client->Message(315, "$NPCName says, 'I can teleport you $name for a small donation (and I will give you change back if necessary). Would you like to see all of my $port destinations?'");
	}
	my $n = 0; #Counts each element in the Array for the While
	if ($text !~ /Hail/i) {
		while ($SpellList[$n]) {
			#This searches the list to find possible matches. The lc() command makes all text lowercase.
			#It is easier to make all text lower case for comparison, if the user types uppercase it will still match.
			if ((lc($SpellList[$n]) =~ lc($text) && lc($SpellList[$n]) ne lc($text)) || ($text =~ /port/i)) {
				my $SpellList = quest::saylink($SpellList[$n]);
				my $SpellCost = $SpellCost[$n];
				$client->Message(315, "For: $SpellCost pp, $SpellList");
			}
			
 			#This is the command that is executed when a the user enters a spell.
			if (lc($SpellList[$n]) eq lc($text) && $text !~ /^List$/i) {
				#Creates a global variable.  You must set the qgolbal field in the npc_types table to 1 for each npc you wish to handle global variables.
				#port is the name, $text is what the varible should be eq too, 0 only this npc, char, and zone apply to the variable, M5 is 5 minutes.
				quest::setglobal("port", $text, 0, "M5");
				#I'm not sure why I need the next line, the line above should set the $qglobals{port}, but it wouldn't work for me.
				$qglobals{port} = $text;
				$client->Message(315, "Please give me $SpellCost[$n]pp, and I'll cast $qglobals{port} for you!");
			}
			$n++;
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}
 
sub EVENT_ITEM {
	my $n = 0; #Counts each element in the Array for the While
	my $ported = 0;
	my $CopperChangeAmount = ($copper%10); #Amount of copper to receive back
	$silver = $silver + (($copper-$CopperChangeAmount)/10);
	my $SilverChangeAmount = ($silver%10); #Amount of silver to receive back
	$gold = $gold + (($silver-$SilverChangeAmount)/10);
	my $GoldChangeAmount = ($gold%10); #Amount of gold to receive back
	$platinum = $platinum + (($gold-$GoldChangeAmount)/10);
	if ($debug) {$client->Message(15,"You gave me: Copper=$CopperChangeAmount, Silver=$SilverChangeAmount, Gold=$GoldChangeAmount Platinum=$platinum");} #debug
	#Cycles through each spell in the array until it matches the requested spell, and the amount pp required.
	while ($SpellList[$n]) {
		if(($SpellList[$n] eq $qglobals{port}) && ($platinum >= $SpellCost[$n])) {
			my $PlatChangeAmount = $platinum - $SpellCost[$n]; #Amount of platinum to receive back
			#Returns the money if it is not the correct amount, or change.
			if(($CopperChangeAmount > 0) || ($SilverChangeAmount > 0) || ($GoldChangeAmount > 0) || ($PlatChangeAmount > 0)) {
				$client->Message(315, "Thank you for the $SpellCost[$n]pp $name, here's your change. Prepare for port to $qglobals{port}."); 
				quest::givecash($CopperChangeAmount,$SilverChangeAmount,$GoldChangeAmount,$PlatChangeAmount);
			}
			else {
				$client->Message(315, "Thank you for the $SpellCost[$n]pp $name, prepare for port to $qglobals{port}.");
			}
			$ported = 1; #set ported so that money is not returned again in the if-then statement below
			quest::delglobal("port"); #deletes the $qglobals{port} variable.
			quest::zone($SpellList[$n]);
      #quest::selfcast($SpellID[$n]);
		}
		$n++;
	}
	if ($debug) {$client->Message(15,"ported=$ported");} #debug
	if ($debug) {$client->Message(15,"You gave me: Copper=$CopperChangeAmount, Silver=$SilverChangeAmount, Gold=$GoldChangeAmount Platinum=$platinum");} #debug
	if ($debug) {$client->Message(15,"global=$qglobals{port}");} #debug
	#If character is still here, returns the money if it is too little or if a spell was not chosen.
	if(($ported == 0) && (($CopperChangeAmount > 0) || ($SilverChangeAmount > 0) || ($GoldChangeAmount > 0) || ($platinum > 0))) {
		if ($debug) {$client->Message(15,"global=$qglobals{port}");} #debug
		if ($qglobals{port} eq "") {
			$client->Message(315, "Tsk, tsk, $name, you haven't told me where you want to go.");
		}
		else {
			$client->Message(315, "Tsk, tsk, $name, that wasn't enough for the teleport. Maybe you should talk to Charity?"); 
		}
		quest::givecash($CopperChangeAmount,$SilverChangeAmount,$GoldChangeAmount,$platinum);
	}
}