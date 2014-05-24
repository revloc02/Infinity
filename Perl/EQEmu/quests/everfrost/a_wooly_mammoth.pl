# ==============================================================
# Author:				Forest Colver
# Create Date:			3 Apr 2013
# Last Edit Date:		3 Apr 2013
# Software Application:	EQEmu, Infinity Server
# Description:			Random Roam
# ==============================================================

# NOTE: The MOB must have exact x, y and z spawn2 coordinates to work properly (z is the potential gotcha)

#!/usr/bin/perl

# constants
use constant MINIMUM_PAUSE_SECONDS => 5; # the minimum pause between movements
use constant PAUSE_RANGE_SECONDS => 60; # random pause range between movements
use constant X_ROAM_DISTANCE => 1000;
use constant Y_ROAM_DISTANCE => 1000;

sub EVENT_SPAWN {
my $min = MINIMUM_PAUSE_SECONDS;
my $range = PAUSE_RANGE_SECONDS;
my $randomspawn = int(rand($range)) + $min;
plugin::RandomRoam(X_ROAM_DISTANCE, Y_ROAM_DISTANCE);
quest::settimer(1,$randomspawn);
}

sub EVENT_TIMER {
plugin::RandomRoam(X_ROAM_DISTANCE, Y_ROAM_DISTANCE);
}