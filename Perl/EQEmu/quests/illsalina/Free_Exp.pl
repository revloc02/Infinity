# ==============================================================
# Author:		Forest Colver
# Create Date:	30 Oct 2010
# Description:	He give free Exp for the purpose of testing. Also will list the Message() color numbers
# ==============================================================

sub EVENT_SAY
{
	my $onethousand = quest::saylink("1k", 1);
	my $tenthousand = quest::saylink("10k", 1);
	my $hundredthousand = quest::saylink("100k", 1);
	my $onemillion = quest::saylink("1M", 1);
	my $tenmillion = quest::saylink("10M", 1);
	my $hundredmillion = quest::saylink("100M", 1);
	my $onebillion = quest::saylink("1G", 1);
	my $seecolors = quest::saylink("See colors", 1);
	if ($text =~/hail/i)
	{
		$client->Message(315, "I can give you:");
		$client->Message(315, "1k : $onethousand");
		$client->Message(315, "10k : $tenthousand");
		$client->Message(315, "100k : $hundredthousand");
		$client->Message(315, "1M : $onemillion");
		$client->Message(315, "10M : $tenmillion");
		$client->Message(315, "100M : $hundredmillion");
		$client->Message(315, "1G : $onebillion");
		$client->Message(315, "$seecolors");
	}
	if ($text =~/1k/i)
	{
		quest::exp(1000);
	}
	if ($text =~/10k/i)
	{
		quest::exp(10000);
	}
	if ($text =~/100k/i)
	{
		quest::exp(100000);
	}
	if ($text =~/1M/i)
	{
		quest::exp(1000000);
	}
	if ($text =~/10M/i)
	{
		quest::exp(10000000);
	}
	if ($text =~/100M/i)
	{
		quest::exp(100000000);
	}
	if ($text =~/1G/i)
	{
		quest::exp(1000000000);
	}
	if ($text =~/See colors/i)
	{
		for ($count = 0; $count < 21; $count++)
		{
			$client->Message($count, "# $count is this color in Message()");
		}
		for ($count = 260; $count < 342; $count++)
		{
			$client->Message($count, "# $count is this color in Message()");
		}
	}
}