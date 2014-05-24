# ==============================================================
# Author:		Forest Colver
# Create Date:	4 Nov 2010
# Description:	An NPC in zones away from hub zones willing to buff for some plat
# ==============================================================


#SpellList is the array containing the names of the spells. SpellCost is the amount in pp for each spell. SpellID is the spell that is cast by the npc.
#Note these are 3 arrays. Each position in the array corosponds to the same position in the other arrays.
#So I have this set so that if you say 'Spirit of Wolf' and pay 2 pp, then the npc will cast spell 278 on you.
#I am setting the amounts to pp just because they can be any amount you wish, this requires changing the EVENT_ITEM function to handle the other money types.
@SpellList = ("Bind Affinity","Chloroplast","Port to Arcstone","Port to Barindu","Port to Blightfire Moors","Port to Bloodfields","Port to Buried Sea","Port to Butcher","Port to Cobalt Scar","Port to Commons","Port to Dawnshroud","Port to Feerrott","Port to Great Divide","Port to Grimling","Port to Iceclad","Port to Karana","Port to Knowledge","Port to Lavastorm","Port to Misty","Port to Natimbi","Port to Ro","Port to Steamfont","Port to Stonebrunt","Port to Surefall Glade","Port to the Combines","Port to the Nexus","Port to The Steppes","Port to Toxxulia","Port to Twilight","Port to Undershore","Port to Wakening Lands","Port to Emerald Jungle","Everlasting Breath","Levitation","Natureskin","Protection of the Cabbage","Regrowth","Resist Cold","Resist Disease","Resist Fire","Resist Magic","Resist Poison","See Invisible","Shield of Blades","Shield of Thorns","Skin like Diamond","Skin like Nature","Port to Sky Fire Mountains","Spirit of Eagle","Spirit of the Shrew","Spirit of Wolf","Storm Strength");
@SpellCost = ("2", "10", "15", "15", "2", "15", "15", "5", "10", "5", "8", "8", "8", "5", "8", "5", "8", "8", "8", "15", "8", "8", "5", "5", "8", "5", "20", "5", "8", "15", "10", "8", "2", "2", "15", "15", "15", "8", "10", "5", "10", "10", "2", "15", "10", "8", "10", "8", "15", "8", "2", "10");
@SpellID = ("35", "145", "8965", "5731", "9957", "6184", "11981", "553", "1440", "551", "2429", "556", "1438", "2419", "1434", "550", "3184", "554", "558", "4966", "555", "557", "3792", "2020", "1517", "2432", "9954", "552", "2424", "8235", "1398", "1737", "2881", "2894", "1559", "2188", "1568", "61", "63", "60", "64", "62", "80", "1560", "356", "422", "423", "1736", "2517", "4054", "278", "430");

sub EVENT_SPAWN 
{
quest::settimer("buffy", 96);
quest::shout("Get your buffs here! Come see Buffy by the tree by the big bank");
quest::settimer("despawnbuffy", 1200)
}

sub EVENT_TIMER 
{
#$npc->SetAppearance(1);
if ($timer eq "buffy") 
{
my $random_number = int(rand(4));
if ($random_number == 0)
{
quest::shout("Get your buffs here! Come see Buffy by the tree by the big bank");
}
elsif ($random_number == 1)
{
quest::shout("Need a port? Come see Buffy by the tree by the big bank");
}
elsif ($random_number == 2)
{
quest::shout("Giving buffs for pp I'm by the tree by the big bank");
}
elsif ($random_number == 3)
{
quest::shout("Buffin and Portin by the tree by the big bank");
}
$npc->SetAppearance(int(rand(2)));
}
if ($timer eq "despawnbuffy") 
{
quest::say ("I am off to gather more experience. See you all soon!");
quest::depop();
}
}

sub EVENT_SAY
{
	my $all = quest::saylink("List", 1);
	my $ports = quest::saylink("Ports",1);
	my $buffs = quest::saylink("Buffs",1);
	#Spacer between Text messages to make them easier to read
	$client->Message(7, "-"); 
	my $NPCName = $npc->GetCleanName();
	if ($text =~/Hail/i)
	{
		$npc->SetAppearance(0);
		$client->Message(315, "$NPCName whispers to you, 'If you need a buff or a Port just let me know, or I can $all them for you. If you prefer to just see the $buffs or $ports I can do that too. You may also enter a partial name and I can find it.'");
	}
	#Counts each row for the While
	my $count = 1;
	#Counts each element in the Array for the While
	my $n = 0;
	if ($text !~ /Hail/i)
	{
		while ($SpellList[$n])
		{
			#This searches the list to find possible matches. The lc() command makes all text lowercase.
			#It is easier to make all text lower case for comparison, if the user types uppercase it will still match.
			if ((lc($SpellList[$n]) =~ lc($text) && lc($SpellList[$n]) ne lc($text)) || ($text =~ /^List$/i)) 
			{
				my $SpellList = quest::saylink($SpellList[$n]);
				my $SpellCost = $SpellCost[$n];
				$client->Message(315, "$NPCName whispers to you, 'Possible match is: $SpellList and it costs $SpellCost pp");
			}
			if ((lc($SpellList[$n]) =~ lc($text) && lc($SpellList[$n]) ne lc($text)) || (($text =~ /Buffs/i) && ($SpellList[$n] !~ /Port to/i))) 
			{
				my $SpellList = quest::saylink($SpellList[$n]);
				my $SpellCost = $SpellCost[$n];
				$client->Message(315, "$NPCName whispers to you, 'Possible match is: $SpellList and it costs $SpellCost pp");
			}
			if ((lc($SpellList[$n]) =~ lc($text) && lc($SpellList[$n]) ne lc($text)) || (($text =~ /Ports/i) && ($SpellList[$n] =~ /Port to/i)) ) 
			{
				my $SpellList = quest::saylink($SpellList[$n]);
				my $SpellCost = $SpellCost[$n];
				$client->Message(315, "$NPCName whispers to you, 'Possible match is: $SpellList and it costs $SpellCost pp");
			}

			#This is the command that is executed when a the user enters a spell.
			if (lc($SpellList[$n]) eq lc($text) && $text !~ /^List$/i)
			{
				#Creates a global variable. You must set the qgolbal field in the npc_types table to 1 for each npc you wish to handle global variables.
				#buff is the name, $text is what the varible should be eq too, 0 only this npc, char, and zone apply to the variable, M5 is 5 minutes.
				quest::setglobal("buff", $text, 0, "M5");
				#I'm not sure why I need the next line, the line above should set the $qglobals{buff}, but it wouldn't work for me.
				$qglobals{buff} = $text;
				$client->Message(315, "Please give me $SpellCost[$n]pp, and I'll cast $qglobals{buff} for you!");
			}
			$n++;
			$count++;
		}
	}
} 

sub EVENT_ITEM
{
	my $correctmoney = 0;
	my $count = 1; #Counts each row for the While
	my $n = 0; #Counts each element in the Array for the While
	my $blnChange = 0; #Keeps track if the player should receive change back from the transaction
	my $intChangeAmount = 0; #Amount of money to receive back
	#Cycles through each spell in the array until it matches the requested spell, and the amount pp required.
	while ($SpellList[$n])
	{
		#if (($SpellList[$n] eq $qglobals{buff}) && ($platinum == $SpellCost[$n]))
		if (($SpellList[$n] eq $qglobals{buff}) && ($platinum > $SpellCost[$n]))
		{
			$client->Message(315, "Thank you for the $SpellCost[$n]pp, prepare for $qglobals{buff}!");
			if ($SpellList[$n] =~ /Port to/i)
			{
				quest::selfcast($SpellID[$n]) 
			}
			else
			{
				$npc->CastSpell($SpellID[$n], $userid);
			}
			#clear global buff variable
			$qglobals{buff} = "";
			if ($platinum == $SpellCost[$n])
			{
				#set this to 1 so that we don't return money we shouldn't.
				$correctmoney = 1;
			}
			else
			{
				$blnChange = 1;
				$intChangeAmount = $SpellCost[$n];
			}
		}
		$n++;
		$count++;
	}
	#Returns the money if it is not the correct amount.
	if ($correctmoney == 0 )
	{
		if (($copper > 0) || ($silver > 0) || ($gold > 0) || ($platinum > 0))
		{
			if ($blnChange = 1)
			{
				$client->Message(315, "Here's your change."); 
				quest::givecash($copper,$silver,$gold,($platinum-$intChangeAmount));
				$blnChange = 0;
				$intChangeAmount = 0;
			}
			else
			{
				$client->Message(315, "I don't need these coins, you may have them back."); 
				quest::givecash($copper,$silver,$gold,$platinum);
			}
		}
	}
	#deletes the $qglobals{buff} variable.
	quest::delglobal("buff");
}