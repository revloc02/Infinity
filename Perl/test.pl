#!/usr/bin/perl
# just for testing out Perl code

use warnings;
use strict; # uncomment this line for some helpful errors and warning, recomment so that this script will work properly in game
# a list of globals vars to copy and paste in temporarily to use with "use strict" for removing errors
my %qglobals;
my $client, my $text, my $charid, my $name, my $ulevel, my $class, my $race, my $item1, my $item2, my $item3, my $item4, my $platinum, my $gold, my $silver, my $copper, my $npc;

use constant {
	TRUE => 1,
	FALSE => '',
	MAX_SCRIBE_LEVEL => 70,
	FIRST_COSTTIER_LEVEL => 20
};

my %levelTier_costMultiplier = (	# a cost multiplier for each level range
	1 => 1,
	10 => 2,
	20 => 3,
	30 => 4,
	40 => 5,
	50 => 8,
	60 => 12
);

main(@ARGV);

sub main {
	my $cost =0;
	message("cost = $cost");
	message("Hey name, you're done up to level " . MAX_SCRIBE_LEVEL . " already.");
	message("$levelTier_costMultiplier{20}");
	itemizeCostRequirementMessage("You need to give me at least ",5);
	itemizeCostRequirementMessage("You need to give me at least ",1203);
	itemizeCostRequirementMessage("You need to give me at least ",40);
	message(itemizedMoneyString(simplifyMoney(123456,0,0,0)));
	message(itemizedMoneyString(simplifyMoney(0,1230,0,0)));
	message(itemizedMoneyString(simplifyMoney(123456,0,400,0)));
	message(itemizedMoneyString(simplifyMoney(11,25,43,10)));
	my @classes = ("Warrior", "Wizard", "Druid");
	message(MatchClass(@classes));
}

# Args: Array classesOfTheItem
# Returns: boolean classMatch of char's class with item's classes
sub MatchClass {
	my $class = "Paladin";
	
	my $classMatch = FALSE;
	foreach (@_) {
		if ($_ eq $class) {
			$classMatch = TRUE;
		}
	}
	return $classMatch;
}

# Args: String messagePrefix, int amountInCopper
# Returns: void
sub itemizeCostRequirementMessage {
	my $c = ($_[1] % 10);
	my $s = (int($_[1] / 10) % 10);
	my $g = (int($_[1] / 100) % 10);
	my $p = int($_[1] / 1000);
	my @money;
	($p)? push(@money, "$p platinum") : 0;
	($g)? push(@money, "$g gold") : 0;
	($s)? push(@money, "$s silver") : 0;
	($c)? push(@money, "$c copper") : 0;
	my $message = "$_[0] " . (join(', ', @money));
	message($message);
}

# Args: Array (copper, silver, gold ,platinum)
# Returns: Array (copper, silver, gold ,platinum)
sub simplifyMoney {
	my $myTotalCopper = $_[0] + ($_[1]*10) + ($_[2]*100) + ($_[3]*1000);
	my $c = ($myTotalCopper % 10);
	my $s = (int($myTotalCopper / 10) % 10);
	my $g = (int($myTotalCopper / 100) % 10);
	my $p = int($myTotalCopper / 1000);
	return ($c, $s, $g, $p);	
}

# Args: Array (copper, silver, gold ,platinum)
# Returns: String platGoldSilverCopper
sub itemizedMoneyString {
	my @money;
	($_[3])? push(@money, "$_[3] platinum") : 0;
	($_[2])? push(@money, "$_[2] gold") : 0;
	($_[1])? push(@money, "$_[1] silver") : 0;
	($_[0])? push(@money, "$_[0] copper") : 0;
	return (join(', ', @money));
}

sub message {
	my $m = shift;
	print("$m\n");
}