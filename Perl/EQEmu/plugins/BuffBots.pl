# ==============================================================
# Author:				Forest Colver
# Create Date:			4 Nov 2010
# Last Edit Date:		4 Jul 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Hail Buff Bot for buffs appropriate to level
# ==============================================================

sub BuffBot_say
{
	my $text = shift;
	my $name = shift;
	my $client = shift;
	my $ulevel = shift;
	my $userid = shift;
	if($text=~/hail/i)
	{
		quest::castspell(2742, $userid);		#Purify Soul - removes poison, curse and disease
		if ($ulevel <= 10)
		{
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
		}
		elsif ($ulevel <= 20)
		{
			#quest::selfcast(273);		#DS		DRU/17 Shield of Barbs
			#quest::selfcast(89);		#HP		CLR/17 Daring
			#quest::selfcast(147);		#STR	SHM/18 Spirit Strength
			#quest::selfcast(3575);		#SpHst	CLR/15 Blessing of Piety
			#quest::selfcast(278);		#Mv		SHM/9 Spirit of Wolf
			#quest::selfcast(697);		#RgnM	ENC/14 Breeze
			quest::castspell(273, $userid);		#DS		DRU/17 Shield of Barbs
			quest::castspell(89, $userid);		#HP		CLR/17 Daring
			quest::castspell(147, $userid);		#STR	SHM/18 Spirit Strength
			quest::castspell(3575, $userid);	#SpHst	CLR/15 Blessing of Piety
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(697, $userid);		#RgnM	ENC/14 Breeze
		}
		elsif ($ulevel <= 30)
		{
			#quest::selfcast(129);		#DS		DRU/27 Shield of Brambles
			#quest::selfcast(144);		#RgnHP	SHM/23 Regeneration
			#quest::selfcast(312);		#HP		CLR/32 Valor
			#quest::selfcast(151);		#STR	SHM/28 Raging Strength
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(174);		#RgnM	ENC/26 Clarity
			quest::castspell(129, $userid);		#DS		DRU/27 Shield of Brambles
			quest::castspell(144, $userid);		#RgnHP	SHM/23 Regeneration
			quest::castspell(312, $userid);		#HP		CLR/32 Valor
			quest::castspell(151, $userid);		#STR	SHM/28 Raging Strength
			quest::castspell(3575, $userid);	#SpHst	CLR/15 Blessing of Piety
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(174, $userid);		#RgnM	ENC/26 Clarity
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
		}
		elsif ($ulevel <= 40)
		{
			#quest::selfcast(432);		#DS		DRU/37 Shield of Spikes
			#quest::selfcast(145);		#RgnHP	SHM/39 Chloroplast
			#quest::selfcast(3692);		#HP		CLR/40 Temperance
			#quest::selfcast(153);		#STR	SHM/39 Furious Strength
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(1694);		#RgnM	ENC/42 Boon of the Clear Mind
			quest::castspell(432, $userid);		#DS		DRU/37 Shield of Spikes
			quest::castspell(145, $userid);		#RgnHP	SHM/39 Chloroplast
			quest::castspell(3692, $userid);	#HP		CLR/40 Temperance
			quest::castspell(153, $userid);		#STR	SHM/39 Furious Strength
			quest::castspell(3576, $userid);	#SpHst	CLR/35 Blessing of Faith
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(174, $userid);		#RgnM	ENC/26 Clarity
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
		}
		elsif ($ulevel <= 50)
		{
			#quest::selfcast(356);		#DS		DRU/47 Shield of Thorns
			#quest::selfcast(145);		#RgnHP	SHM/39 Chloroplast
			#quest::selfcast(3692);		#HP		CLR/40 Temperance
			#quest::selfcast(3454);		#STR,D	SHM/49 Infusion of Spirit
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(1693);		#RgnM	ENC/52 Clarity II
			quest::castspell(356, $userid);		#DS		DRU/47 Shield of Thorns
			quest::castspell(145, $userid);		#RgnHP	SHM/39 Chloroplast
			quest::castspell(3692, $userid);	#HP		CLR/40 Temperance
			quest::castspell(3454, $userid);	#STR,D	SHM/49 Infusion of Spirit
			quest::castspell(3576, $userid);	#SpHst	CLR/35 Blessing of Faith
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(1693, $userid);	#RgnM	ENC/52 Clarity II
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
		}
		elsif ($ulevel <= 60)
		{
			#quest::selfcast(1560);		#DS		DRU/58 Shield of Blades
			#quest::selfcast(1568);		#RgnHP	SHM/52 Regrowth
			#quest::selfcast(1447);		#HP		CLR/60 Aegolism
			#quest::selfcast(1432);		#STR,D	SHM/60 Focus of Spirit
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(2570);		#RgnM	ENC/60 Koadic's Endless Intellect
			quest::castspell(1560, $userid);	#DS		DRU/58 Shield of Blades
			quest::castspell(1568, $userid);	#RgnHP	SHM/52 Regrowth
			quest::castspell(1447, $userid);	#HP		CLR/60 Aegolism
			quest::castspell(1432, $userid);	#STR,D	SHM/60 Focus of Spirit
			quest::castspell(3576, $userid);	#SpHst	CLR/35 Blessing of Faith
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::selfcast(2570);				#RgnM	ENC/60 Koadic's Endless Intellect
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
			quest::castspell(1397, $userid);	#Atk	RNG/51 Strength of Nature
			quest::castspell(1377, $userid);	#stats	SHM/60 Primal Avatar
		}
		elsif ($ulevel <= 63)
		{
			#quest::selfcast(3448);		#DS		DRU/63 Shield of Bracken
			#quest::selfcast(3433);		#RgnHP	DRU/61 Replenishment
			#quest::selfcast(3467);		#HP		CLR/62 Virtue
			#quest::selfcast(3235);		#STR,D	SHM/62 Focus of Soul
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(3350);		#RgnM	ENC/63 Tranquility
			quest::castspell(3448, $userid);	#DS		DRU/63 Shield of Bracken
			quest::castspell(3433, $userid);	#RgnHP	DRU/61 Replenishment
			quest::castspell(3467, $userid);	#HP		CLR/62 Virtue
			quest::castspell(3235, $userid);	#STR,D	SHM/62 Focus of Soul
			quest::castspell(3472, $userid);	#SpHst	CLR/62 Blessing of Reverence
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(3350, $userid);	#RgnM	ENC/63 Tranquility
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
			quest::castspell(2886, $userid);	#SeeInv	SHM/58 Acumen of Dar Khura
			quest::castspell(1397, $userid);	#Atk	RNG/51 Strength of Nature
			quest::castspell(2112, $userid);	#stats	SHM/60 Ancient Feral Avatar
		}
		elsif ($ulevel <= 67)
		{
			#quest::selfcast(5358);		#DS		DRU/67 Nettle Shield
			#quest::selfcast(5342);		#RgnHP	DRU/66 Oaken Vigor
			#quest::selfcast(5257);		#HP		CLR/67 Conviction
			#quest::selfcast(3397);		#STR,D	SHM/65 Focus of the Seventh
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(3360);		#RgnM	ENC/65 Voice of Quellious
			quest::castspell(5358, $userid);	#DS		DRU/67 Nettle Shield
			quest::castspell(5342, $userid);	#RgnHP	DRU/66 Oaken Vigor
			quest::castspell(5257, $userid);	#HP		CLR/67 Conviction
			quest::castspell(3397, $userid);	#STR,D	SHM/65 Focus of the Seventh
			quest::castspell(5258, $userid);	#SpHst	CLR/67 Blessing of Devotion
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(3360, $userid);	#RgnM	ENC/65 Voice of Quellious
			quest::castspell(5390, $userid);	#		SHM/66 Spirit of Sense
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
			quest::castspell(5507, $userid);	#Spd	Enc/67 Speed of Salik
			quest::castspell(2886, $userid);	#SeeInv	SHM/58 Acumen of Dar Khura
			quest::castspell(5404, $userid);	#Dmg	SHM/67 Spirit of Might
			quest::castspell(1397, $userid);	#Atk	RNG/51 Strength of Nature
			quest::castspell(7259, $userid);	#stats	SHM/65 Ferine Avatar
		}
		else
		{
			#quest::selfcast(5358);		#DS		DRU/67 Nettle Shield
			#quest::selfcast(5342);		#RgnHP	DRU/66 Oaken Vigor
			#quest::selfcast(5257);		#HP		CLR/67 Conviction
			#quest::selfcast(5396);		#STR,D	SHM/68 Wunshi's Focusing
			#quest::selfcast(4054);		#Mv		SHM/29 Spirit of Shrew
			#quest::selfcast(5513);		#RgnM	ENC/68 Clairvoyance
			quest::castspell(5358, $userid);	#DS		DRU/67 Nettle Shield
			quest::castspell(5342, $userid);	#RgnHP	DRU/66 Oaken Vigor
			quest::castspell(5257, $userid);	#HP		CLR/67 Conviction
			quest::castspell(5396, $userid);	#STR,D	SHM/68 Wunshi's Focusing
			quest::castspell(5258, $userid);	#SpHst	CLR/67 Blessing of Devotion
			quest::castspell(278, $userid);		#Mv		SHM/9 Spirit of Wolf
			quest::castspell(5513, $userid);	#RgnM	ENC/68 Clairvoyance
			quest::castspell(5390, $userid);	#		SHM/66 Spirit of Sense
			quest::castspell(170, $userid);		#AtkSpd	Enc/21 Alacrity
			quest::castspell(5507, $userid);	#Spd	Enc/67 Speed of Salik
			quest::castspell(2886, $userid);	#SeeInv	SHM/58 Acumen of Dar Khura
			quest::castspell(5404, $userid);	#Dmg	SHM/67 Spirit of Might
			quest::castspell(1397, $userid);	#Atk	RNG/51 Strength of Nature
			quest::castspell(7259, $userid);	#stats	SHM/65 Ferine Avatar
		}
		$client->Message(315, "Xana says, 'And bless you, $name.'");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text
}  

return 1;	#This line is required at the end of every plugin file in order to use it