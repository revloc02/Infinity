#!/usr/bin/perl

sub soulbinder_say {
	my $text = shift;
	my $client = plugin::val('$client');
	my $bindmysoul = quest::saylink("bind my soul", 1);
	if($text=~/hail/i){
		$client->Message(315, "Greetings ${name} . When a hero of our world is slain their soul returns to the place it was last bound and the body is reincarnated. As a member of the Order of Eternity  it is my duty to $bindmysoul to this location if that is your wish.");
	} elsif($text=~/bind my soul/i) {
	    $client->Message(315, "Binding your soul. You will return here when you die.");
	    quest::selfcast(2049);
	}
}  
