# ==============================================================
# Author:				Forest Colver
# Create Date:			4 Nov 2010
# Last Edit Date:		4 May 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Free transport to common zones
# ==============================================================

my $debug = 1;

sub TaxiBot_say {
	my $qglobals = plugin::var('qglobals');
	my $prestigeLevel = $qglobals->{"prestige_level"}; # this is the number of times a character has Prestiged
	
	my $text = shift;
	my $name = shift;
	my $client = shift;
	
	my $abysmal = quest::saylink('abysmal', 1);
	my $acrylia = quest::saylink('acrylia', 1);
	my $airplane = quest::saylink('airplane', 1);
	my $akanon = quest::saylink('akanon', 1);
	my $akheva = quest::saylink('akheva', 1);
	my $anguish = quest::saylink('anguish', 1);
	my $arena = quest::saylink('arena', 1);
	my $barindu = quest::saylink('barindu', 1);
	my $barter = quest::saylink('barter', 1);
	my $bazaar = quest::saylink('bazaar', 1);
	my $bazaar = quest::saylink('bazaar', 1);
	my $befallen = quest::saylink('befallen', 1);
	my $beholder = quest::saylink('beholder', 1);
	my $blackburrow = quest::saylink('blackburrow', 1);
	my $bloodfields = quest::saylink('bloodfields', 1);
	my $bothunder = quest::saylink('bothunder', 1);
	my $broodlands = quest::saylink('broodlands', 1);
	my $burningwood = quest::saylink('burningwood', 1);
	my $butcher = quest::saylink('butcher', 1);
	my $cabeast = quest::saylink('cabeast', 1);
	my $cabwest = quest::saylink('cabwest', 1);
	my $cauldron = quest::saylink('cauldron', 1);
	my $causeway = quest::saylink('causeway', 1);
	my $cazicthule = quest::saylink('cazicthule', 1);
	my $chambersa = quest::saylink('chambersa', 1);
	my $chambersb = quest::saylink('chambersb', 1);
	my $chambersc = quest::saylink('chambersc', 1);
	my $chambersd = quest::saylink('chambersd', 1);
	my $chamberse = quest::saylink('chamberse', 1);
	my $chambersf = quest::saylink('chambersf', 1);
	my $charasis = quest::saylink('charasis', 1);
	my $chardok = quest::saylink('chardok', 1);
	my $chardokb = quest::saylink('chardokb', 1);
	my $citymist = quest::saylink('citymist', 1);
	my $cobaltscar = quest::saylink('cobaltscar', 1);
	my $codecay = quest::saylink('codecay', 1);
	my $commons = quest::saylink('commons', 1);
	my $crushbone = quest::saylink('crushbone', 1);
	my $crystal = quest::saylink('crystal', 1);
	my $cshome = quest::saylink('cshome', 1);
	my $dalnir = quest::saylink('dalnir', 1);
	my $dawnshroud = quest::saylink('dawnshroud', 1);
	my $delvea = quest::saylink('delvea', 1);
	my $delveb = quest::saylink('delveb', 1);
	my $dranik = quest::saylink('dranik', 1);
	my $dranikcatacombsa = quest::saylink('dranikcatacombsa', 1);
	my $dranikcatacombsb = quest::saylink('dranikcatacombsb', 1);
	my $dranikcatacombsc = quest::saylink('dranikcatacombsc', 1);
	my $dranikhollowsa = quest::saylink('dranikhollowsa', 1);
	my $dranikhollowsb = quest::saylink('dranikhollowsb', 1);
	my $dranikhollowsc = quest::saylink('dranikhollowsc', 1);
	my $draniksewersa = quest::saylink('draniksewersa', 1);
	my $draniksewersb = quest::saylink('draniksewersb', 1);
	my $draniksewersc = quest::saylink('draniksewersc', 1);
	my $draniksscar = quest::saylink('draniksscar', 1);
	my $dreadlands = quest::saylink('dreadlands', 1);
	my $droga = quest::saylink('droga', 1);
	my $dulak = quest::saylink('dulak', 1);
	my $eastkarana = quest::saylink('eastkarana', 1);
	my $eastwastes = quest::saylink('eastwastes', 1);
	my $echo = quest::saylink('echo', 1);
	my $ecommons = quest::saylink('ecommons', 1);
	my $emeraldjungle = quest::saylink('emeraldjungle', 1);
	my $erudnext = quest::saylink('erudnext', 1);
	my $erudnint = quest::saylink('erudnint', 1);
	my $erudsxing = quest::saylink('erudsxing', 1);
	my $everfrost = quest::saylink('everfrost', 1);
	my $fearplane = quest::saylink('fearplane', 1);
	my $feerrott = quest::saylink('feerrott', 1);
	my $felwithea = quest::saylink('felwithea', 1);
	my $felwitheb = quest::saylink('felwitheb', 1);
	my $ferubi = quest::saylink('ferubi', 1);
	my $fhalls = quest::saylink('fhalls', 1);
	my $fieldofbone = quest::saylink('fieldofbone', 1);
	my $firiona = quest::saylink('firiona', 1);
	my $freporte = quest::saylink('freporte', 1);
	my $freportn = quest::saylink('freportn', 1);
	my $freportw = quest::saylink('freportw', 1);
	my $frontiermtns = quest::saylink('frontiermtns', 1);
	my $frozenshadow = quest::saylink('frozenshadow', 1);
	my $fungusgrove = quest::saylink('fungusgrove', 1);
	my $gfaydark = quest::saylink('gfaydark', 1);
	my $greatdivide = quest::saylink('greatdivide', 1);
	my $griegsend = quest::saylink('griegsend', 1);
	my $grimling = quest::saylink('grimling', 1);
	my $grobb = quest::saylink('grobb', 1);
	my $growthplane = quest::saylink('growthplane', 1);
	my $guildhall = quest::saylink('guildhall', 1);
	my $guildlobby = quest::saylink('guildlobby', 1);
	my $guka = quest::saylink('guka', 1);
	my $gukb = quest::saylink('gukb', 1);
	my $gukbottom = quest::saylink('gukbottom', 1);
	my $gukc = quest::saylink('gukc', 1);
	my $gukd = quest::saylink('gukd', 1);
	my $guke = quest::saylink('guke', 1);
	my $gukf = quest::saylink('gukf', 1);
	my $gukg = quest::saylink('gukg', 1);
	my $gukh = quest::saylink('gukh', 1);
	my $guktop = quest::saylink('guktop', 1);
	my $gunthak = quest::saylink('gunthak', 1);
	my $halas = quest::saylink('halas', 1);
	my $harbingers = quest::saylink('harbingers', 1);
	my $hateplane = quest::saylink('hateplane', 1);
	my $hateplaneb = quest::saylink('hateplaneb', 1);
	my $hatesfury = quest::saylink('hatesfury', 1);
	my $highkeep = quest::saylink('highkeep', 1);
	my $highpass = quest::saylink('highpass', 1);
	my $hohonora = quest::saylink('hohonora', 1);
	my $hohonorb = quest::saylink('hohonorb', 1);
	my $hole = quest::saylink('hole', 1);
	my $hollowshade = quest::saylink('hollowshade', 1);
	my $iceclad = quest::saylink('iceclad', 1);
	my $ikkinz = quest::saylink('ikkinz', 1);
	my $inktuta = quest::saylink('inktuta', 1);
	my $innothule = quest::saylink('innothule', 1);
	my $jaggedpine = quest::saylink('jaggedpine', 1);
	my $kael = quest::saylink('kael', 1);
	my $kaesora = quest::saylink('kaesora', 1);
	my $kaladima = quest::saylink('kaladima', 1);
	my $kaladimb = quest::saylink('kaladimb', 1);
	my $karnor = quest::saylink('karnor', 1);
	my $katta = quest::saylink('katta', 1);
	my $kedge = quest::saylink('kedge', 1);
	my $kerraridge = quest::saylink('kerraridge', 1);
	my $kithicor = quest::saylink('kithicor', 1);
	my $kodtaz = quest::saylink('kodtaz', 1);
	my $kurn = quest::saylink('kurn', 1);
	my $lakeofillomen = quest::saylink('lakeofillomen', 1);
	my $lakerathe = quest::saylink('lakerathe', 1);
	my $lavastorm = quest::saylink('lavastorm', 1);
	my $letalis = quest::saylink('letalis', 1);
	my $lfaydark = quest::saylink('lfaydark', 1);
	my $maiden = quest::saylink('maiden', 1);
	my $mira = quest::saylink('mira', 1);
	my $mirb = quest::saylink('mirb', 1);
	my $mirc = quest::saylink('mirc', 1);
	my $mird = quest::saylink('mird', 1);
	my $mire = quest::saylink('mire', 1);
	my $mirf = quest::saylink('mirf', 1);
	my $mirg = quest::saylink('mirg', 1);
	my $mirh = quest::saylink('mirh', 1);
	my $miri = quest::saylink('miri', 1);
	my $mirj = quest::saylink('mirj', 1);
	my $mischiefplane = quest::saylink('mischiefplane', 1);
	my $mistmoore = quest::saylink('mistmoore', 1);
	my $misty = quest::saylink('misty', 1);
	my $mmca = quest::saylink('mmca', 1);
	my $mmcb = quest::saylink('mmcb', 1);
	my $mmcc = quest::saylink('mmcc', 1);
	my $mmcd = quest::saylink('mmcd', 1);
	my $mmce = quest::saylink('mmce', 1);
	my $mmcf = quest::saylink('mmcf', 1);
	my $mmcg = quest::saylink('mmcg', 1);
	my $mmch = quest::saylink('mmch', 1);
	my $mmci = quest::saylink('mmci', 1);
	my $mmcj = quest::saylink('mmcj', 1);
	my $mseru = quest::saylink('mseru', 1);
	my $nadox = quest::saylink('nadox', 1);
	my $najena = quest::saylink('najena', 1);
	my $natimbi = quest::saylink('natimbi', 1);
	my $necropolis = quest::saylink('necropolis', 1);
	my $nedaria = quest::saylink('nedaria', 1);
	my $nektulos = quest::saylink('nektulos', 1);
	my $nektulos = quest::saylink('nektulos', 1);
	my $neriaka = quest::saylink('neriaka', 1);
	my $neriakb = quest::saylink('neriakb', 1);
	my $neriakc = quest::saylink('neriakc', 1);
	my $netherbian = quest::saylink('netherbian', 1);
	my $nexus = quest::saylink('nexus', 1);
	my $nightmareb = quest::saylink('nightmareb', 1);
	my $northkarana = quest::saylink('northkarana', 1);
	my $nro = quest::saylink('nro', 1);
	my $nurga = quest::saylink('nurga', 1);
	my $oasis = quest::saylink('oasis', 1);
	my $oggok = quest::saylink('oggok', 1);
	my $oot = quest::saylink('oot', 1);
	my $overthere = quest::saylink('overthere', 1);
	my $paineel = quest::saylink('paineel', 1);
	my $paludal = quest::saylink('paludal', 1);
	my $paw = quest::saylink('paw', 1);
	my $permafrost = quest::saylink('permafrost', 1);
	my $poair = quest::saylink('poair', 1);
	my $podisease = quest::saylink('podisease', 1);
	my $poeartha = quest::saylink('poeartha', 1);
	my $poearthb = quest::saylink('poearthb', 1);
	my $pofire = quest::saylink('pofire', 1);
	my $poinnovation = quest::saylink('poinnovation', 1);
	my $pojustice = quest::saylink('pojustice', 1);
	my $poknowledge = quest::saylink('poknowledge', 1);
	my $ponightmare = quest::saylink('ponightmare', 1);
	my $postorms = quest::saylink('postorms', 1);
	my $potactics = quest::saylink('potactics', 1);
	my $potimea = quest::saylink('potimea', 1);
	my $potimeb = quest::saylink('potimeb', 1);
	my $potorment = quest::saylink('potorment', 1);
	my $potranquility = quest::saylink('potranquility', 1);
	my $povalor = quest::saylink('povalor', 1);
	my $powar = quest::saylink('powar', 1);
	my $powater = quest::saylink('powater', 1);
	my $provinggrounds = quest::saylink('provinggrounds', 1);
	my $qcat = quest::saylink('qcat', 1);
	my $qey2hh1 = quest::saylink('qey2hh1', 1);
	my $qeynos = quest::saylink('qeynos', 1);
	my $qeynos2 = quest::saylink('qeynos2', 1);
	my $qeytoqrg = quest::saylink('qeytoqrg', 1);
	my $qinimi = quest::saylink('qinimi', 1);
	my $qrg = quest::saylink('qrg', 1);
	my $qvic = quest::saylink('qvic', 1);
	my $qvicb = quest::saylink('qvicb', 1);
	my $rathemtn = quest::saylink('rathemtn', 1);
	my $riftseekers = quest::saylink('riftseekers', 1);
	my $rivervale = quest::saylink('rivervale', 1);
	my $riwwi = quest::saylink('riwwi', 1);
	my $ruja = quest::saylink('ruja', 1);
	my $rujb = quest::saylink('rujb', 1);
	my $rujc = quest::saylink('rujc', 1);
	my $rujd = quest::saylink('rujd', 1);
	my $ruje = quest::saylink('ruje', 1);
	my $rujf = quest::saylink('rujf', 1);
	my $rujg = quest::saylink('rujg', 1);
	my $rujh = quest::saylink('rujh', 1);
	my $ruji = quest::saylink('ruji', 1);
	my $rujj = quest::saylink('rujj', 1);
	my $runnyeye = quest::saylink('runnyeye', 1);
	my $scarlet = quest::saylink('scarlet', 1);
	my $sebilis = quest::saylink('sebilis', 1);
	my $shadeweaver = quest::saylink('shadeweaver', 1);
	my $shadowhaven = quest::saylink('shadowhaven', 1);
	my $shadowrest = quest::saylink('shadowrest', 1);
	my $sharvahl = quest::saylink('sharvahl', 1);
	my $sirens = quest::saylink('sirens', 1);
	my $skyfire = quest::saylink('skyfire', 1);
	my $skyshrine = quest::saylink('skyshrine', 1);
	my $sleeper = quest::saylink('sleeper', 1);
	my $sncrematory = quest::saylink('sncrematory', 1);
	my $snlair = quest::saylink('snlair', 1);
	my $snplant = quest::saylink('snplant', 1);
	my $snpool = quest::saylink('snpool', 1);
	my $soldunga = quest::saylink('soldunga', 1);
	my $soldungb = quest::saylink('soldungb', 1);
	my $soldungc = quest::saylink('soldungc', 1);
	my $solrotower = quest::saylink('solrotower', 1);
	my $soltemple = quest::saylink('soltemple', 1);
	my $southkarana = quest::saylink('southkarana', 1);
	my $sro = quest::saylink('sro', 1);
	my $sseru = quest::saylink('sseru', 1);
	my $ssratemple = quest::saylink('ssratemple', 1);
	my $steamfont = quest::saylink('steamfont', 1);
	my $stillmoona = quest::saylink('stillmoona', 1);
	my $stillmoonb = quest::saylink('stillmoonb', 1);
	my $stonebrunt = quest::saylink('stonebrunt', 1);
	my $swampofnohope = quest::saylink('swampofnohope', 1);
	my $tacvi = quest::saylink('tacvi', 1);
	my $taka = quest::saylink('taka', 1);
	my $takb = quest::saylink('takb', 1);
	my $takc = quest::saylink('takc', 1);
	my $takd = quest::saylink('takd', 1);
	my $take = quest::saylink('take', 1);
	my $takf = quest::saylink('takf', 1);
	my $takg = quest::saylink('takg', 1);
	my $takh = quest::saylink('takh', 1);
	my $taki = quest::saylink('taki', 1);
	my $takj = quest::saylink('takj', 1);
	my $templeveeshan = quest::saylink('templeveeshan', 1);
	my $tenebrous = quest::saylink('tenebrous', 1);
	my $thedeep = quest::saylink('thedeep', 1);
	my $thegrey = quest::saylink('thegrey', 1);
	my $thenest = quest::saylink('thenest', 1);
	my $thundercrest = quest::saylink('thundercrest', 1);
	my $thurgadina = quest::saylink('thurgadina', 1);
	my $thurgadinb = quest::saylink('thurgadinb', 1);
	my $timorous = quest::saylink('timorous', 1);
	my $tipt = quest::saylink('tipt', 1);
	my $torgiran = quest::saylink('torgiran', 1);
	my $tox = quest::saylink('tox', 1);
	my $trakanon = quest::saylink('trakanon', 1);
	my $tutoriala = quest::saylink('tutoriala', 1);
	my $tutorialb = quest::saylink('tutorialb', 1);
	my $twilight = quest::saylink('twilight', 1);
	my $txevu = quest::saylink('txevu', 1);
	my $umbral = quest::saylink('umbral', 1);
	my $unrest = quest::saylink('unrest', 1);
	my $uqua = quest::saylink('uqua', 1);
	my $veeshan = quest::saylink('veeshan', 1);
	my $veksar = quest::saylink('veksar', 1);
	my $velketor = quest::saylink('velketor', 1);
	my $vexthal = quest::saylink('vexthal', 1);
	my $vxed = quest::saylink('vxed', 1);
	my $wakening = quest::saylink('wakening', 1);
	my $wallofslaughter = quest::saylink('wallofslaughter', 1);
	my $warrens = quest::saylink('warrens', 1);
	my $warslikswood = quest::saylink('warslikswood', 1);
	my $westwastes = quest::saylink('westwastes', 1);
	my $yxtta = quest::saylink('yxtta', 1);
	
	my $ListA = quest::saylink("ListA",1);
	my $ListB = quest::saylink("ListB",1);
	my $ListC = quest::saylink("ListC",1);
	
	my $Classic = quest::saylink("Classic",1);
	my $Kunark = quest::saylink("Kunark",1);
	my $Velious = quest::saylink("Velious",1);
	my $Luclin = quest::saylink("Luclin",1);
	my $PoP = quest::saylink("PoP",1);
	my $Ykesha = quest::saylink("Ykesha",1);
	my $LDoN = quest::saylink("LDoN",1);
	my $Discord = quest::saylink("Discord",1);
	my $Omens = quest::saylink("Omens",1);
	my $DoN = quest::saylink("DoN",1);
	my $Darkhollow = quest::saylink("Darkhollow",1);
	
	if ($text =~/hail/i) {
		if ($debug) {$client->Message(1,"prestigeLevel=$prestigeLevel");} #debug
		$client->Message(315, "Yo $name, howya doo-in? Where to mac? Do you want $ListA, $ListB, or $ListC.");
		$client->Message(315, "$Classic");
		if ($prestigeLevel >= 1) {
			$client->Message(315, "$Kunark");
		}
		if ($prestigeLevel >= 2) {
			$client->Message(315, "$Velious");
		}
		if ($prestigeLevel >= 3) {
			$client->Message(315, "$Luclin");
		}
		if ($prestigeLevel >= 4) {
			$client->Message(315, "$PoP");
		}
		if ($prestigeLevel >= 5) {
			$client->Message(315, "$Ykesha");
		}
		if ($prestigeLevel >= 6) {
			$client->Message(315, "$LDoN");
		}
		if ($prestigeLevel >= 7) {
			$client->Message(315, "$Discord");
		}
		if ($prestigeLevel >= 8) {
			$client->Message(315, "$Omens");
		}
		if ($prestigeLevel >= 9) {
			$client->Message(315, "$DoN");
		}
		if ($prestigeLevel >= 10) {
			$client->Message(315, "$Darkhollow");
		}
	}
	
	if ($text =~/Classic/i) {
		if ($prestigeLevel == 0) { # default Classic list
			$client->Message(315, "$beholder, $fearplane, $felwitheb, $freportn, $guktop, $halas, $hateplane, $highkeep, $hole, $kaladimb, $lakerathe, $lfaydark, $neriakc, $nro, $oot, $qey2hh1, $southkarana");
		}
		if ($prestigeLevel >= 1) { # expanded Classic list
			$client->Message(315, "$airplane, $beholder, $cazicthule, $fearplane, $felwitheb, $freportn, $gukbottom, $guktop, $halas, $hateplane, $hateplaneb, $highkeep, $highpass, $hole, $jaggedpine, $kaladimb, $lakerathe, $lfaydark, $mistmoore, $nedaria, $neriakc, $nro, $oasis, $oot, $paw, $permafrost, $qey2hh1, $rathemtn, $runnyeye, $soldunga, $soldungb, $southkarana, $unrest");
		}
	}
	if ($text =~/Kunark/i) {
		if ($prestigeLevel == 1) { # default Kunark list
			$client->Message(315, "$burningwood, $erudsxing, $firiona, $frontiermtns, $lakeofillomen, $timorous, $trakanon");
		}
		if ($prestigeLevel >= 2) { # expanded Kunark list
			$client->Message(315, "$burningwood, $charasis, $chardok, $citymist, $droga, $erudsxing, $firiona, $frontiermtns, $karnor, $kurn, $lakeofillomen, $nurga, $sebilis, $swampofnohope, $timorous, $trakanon, $veksar, $warslikswood");
		}
	}
	if ($text =~/Velious/i) {
		if ($prestigeLevel == 2) { # default Velious list
			$client->Message(315, "$crystal, $eastwastes, $growthplane, $thurgadinb, $westwastes");
		}
		if ($prestigeLevel >= 3) { # expanded Velious list
			$client->Message(315, "$crystal, $eastwastes, $frozenshadow, $growthplane, $kael, $mischiefplane, $necropolis, $skyshrine, $sleeper, $thurgadinb, $velketor, $westwastes");
		}
	}
	if ($text =~/Luclin/i) {
		if ($prestigeLevel == 3) { # default Luclin list
			$client->Message(315, "$echo, $fungusgrove, $katta, $maiden, $netherbian $paludal, $sseru, $thegrey");
		}
		if ($prestigeLevel >= 4) { # expanded Luclin list
			$client->Message(315, "$acrylia, $akheva, $echo, $fungusgrove, $griegsend, $hollowshade, $katta, $letalis, $maiden, $mseru, $netherbian $paludal, $scarlet, $shadowhaven, $sseru, $ssratemple, $tenebrous, $thedeep, $thegrey, $umbral");
		}
	}
	if ($text =~/PoP/i) {
		if ($prestigeLevel == 4) { # default PoP list
			$client->Message(315, "$bothunder, $hohonora, $podisease, $poeartha, $poinnovation $pojustice, $ponightmare");
		}
		if ($prestigeLevel >= 5) { # expanded PoP list
			$client->Message(315, "$bothunder, $codecay, $hohonora, $hohonorb, $nightmareb, $poair, $podisease, $poeartha, $poearthb, $pofire, $poinnovation $pojustice, $ponightmare, $postorms, $potactics, $potimea, $potimeb, $potorment, $povalor, $powater, $solrotower");
		}
	}
	if ($text =~/Ykesha/i) {
		if ($prestigeLevel == 5) { # default Ykesha list
			$client->Message(315, "$dulak");
		}
		if ($prestigeLevel >= 6) { # expanded Ykesha list
			$client->Message(315, "$chardokb, $dulak, $hatesfury, $nadox, $soldungc, $torgiran");
		}
	}
	if ($text =~/LDoN/i) {
		if ($prestigeLevel == 5) { # default LDoN list
			$client->Message(315, "$mirc");
		}
		if ($prestigeLevel >= 6) { # expanded LDoN list
			$client->Message(315, "$mirc, $ruji");
		}
	}
	if ($text =~/Discord/i) {
		if ($prestigeLevel == 5) { # default Discord list
			$client->Message(315, "$abysmal, $ikkinz, $inktula, $sncrematory, $snlair, $snplant, $snpool, $tipt, $uqua");
		}
		if ($prestigeLevel >= 6) { # expanded Discord list
			$client->Message(315, "$abysmal, $ferubi, $ikkinz, $inktula, $kodtaz, $qinimi, $qvic, $riwwi, $sncrematory, $snlair, $snplant, $snpool, $tipt, $uqua, $vxed, $yxtta");
		}
	}
	if ($text =~/Omens/i) {
		if ($prestigeLevel == 5) { # default Omens list
			$client->Message(315, "");
		}
		if ($prestigeLevel >= 6) { # expanded Omens list
			$client->Message(315, "");
		}
	}
	
	if ($text =~/ListA/i) {
		$client->Message(315, "$airplane, $blackburrow, $cauldron, $citymist, $draniksscar, $dulak, $eastkorlach, $ecommons, $erudsxing, $fieldofbone, $frontiermtns, $griegsend, $gukbottom, $hateplane, $hateplaneb, $highkeep, $highpasshold, $hole, $iceclad, $jaggedpine, $lfaydark, $maiden, $mseru, $neriaka, $netherbian, $nkarana, $oasis, $oot, $paludal, $ruji, $scarlet, $sseru, $timorous, $trakanon, $unrest, $veksar, $westwastes.");
	}
	if ($text =~/ListB/i) {
		$client->Message(315, "$ssratemple, $vexthal, $akheva, $acrylia, $sirens, $sleeper, $velketor, $frozenshadow, $crystal, $karnor, $nurga, $droga, $sebilis, $charasis, $veeshan, $chardok, $kedge, $mistmoore, $cazicthule, $soltemple, $growthplane, $mischiefplane, $letalis, $poeartha, $pofire, $poearthb, $bothunder, $hohonora, $hohonorb, $poair, $potactics, $potorment, $powater, $solrotower, $codecay, $nightmareb, $postorms.");
	}
	if ($text =~/ListC/i) {
		$client->Message(315, "$povalor, $podisease, $poinnovation, $pojustice, $powar, $potimea, $nadox, $hatesfury, $kodtaz, $ferubi, $qvic, $tipt, $uqua, $vxed, $yxtta, $inktuta, $barindu, $ikkinz, $natimbi, $qinimi, $riwwi, $sncrematory, $snlair, $snplant, $snpool, $abysmal, $fhalls.");
	}
	
	if ($text =~/abysmal/i) {quest::zone(abysmal);}
	if ($text =~/acrylia/i) {quest::zone(acrylia);}
	if ($text =~/airplane/i) {quest::zone(airplane);}
	if ($text =~/akheva/i) {quest::zone(akheva);}
	if ($text =~/beholder/i) {quest::zone(beholder);}
	if ($text =~/bothunder/i) {quest::zone(bothunder);}
	if ($text =~/burningwood/i) {quest::zone(burningwood);}
	if ($text =~/cazicthule/i) {quest::zone(cazicthule);}
	if ($text =~/charasis/i) {quest::zone(charasis);}
	if ($text =~/chardok/i) {quest::zone(chardok);}
	if ($text =~/chardokb/i) {quest::zone(chardokb);}
	if ($text =~/citymist/i) {quest::zone(citymist);}
	if ($text =~/codecay/i) {quest::zone(codecay);}
	if ($text =~/crystal/i) {quest::zone(crystal);}
	if ($text =~/droga/i) {quest::zone(droga);}
	if ($text =~/dulak/i) {quest::zone(dulak);}
	if ($text =~/eastwastes/i) {quest::zone(eastwastes);}
	if ($text =~/echo/i) {quest::zone(echo);}
	if ($text =~/erudsxing/i) {quest::zone(erudsxing);}
	if ($text =~/fearplane/i) {quest::zone(fearplane);}
	if ($text =~/felwitheb/i) {quest::zone(felwitheb);}
	if ($text =~/ferubi/i) {quest::zone(ferubi);}
	if ($text =~/firiona/i) {quest::zone(firiona);}
	if ($text =~/freportn/i) {quest::zone(freportn);}
	if ($text =~/frontiermtns/i) {quest::zone(frontiermtns);}
	if ($text =~/frozenshadow/i) {quest::zone(frozenshadow);}
	if ($text =~/fungusgrove/i) {quest::zone(fungusgrove);}
	if ($text =~/griegsend/i) {quest::zone(griegsend);}
	if ($text =~/growthplane/i) {quest::zone(growthplane);}
	if ($text =~/gukbottom/i) {quest::zone(gukbottom);}
	if ($text =~/guktop/i) {quest::zone(guktop);}
	if ($text =~/halas/i) {quest::zone(halas);}
	if ($text =~/hateplane/i) {quest::zone(hateplane);}
	if ($text =~/hateplaneb/i) {quest::zone(hateplaneb);}
	if ($text =~/hatesfury/i) {quest::zone(hatesfury);}
	if ($text =~/highkeep/i) {quest::zone(highkeep);}
	if ($text =~/highpass/i) {quest::zone(highpass);}
	if ($text =~/hohonora/i) {quest::zone(hohonora);}
	if ($text =~/hohonorb/i) {quest::zone(hohonorb);}
	if ($text =~/hole/i) {quest::zone(hole);}
	if ($text =~/hollowshade/i) {quest::zone(hollowshade);}
	if ($text =~/ikkinz/i) {quest::zone(ikkinz);}
	if ($text =~/inktuta/i) {quest::zone(inktuta);}
	if ($text =~/jaggedpine/i) {quest::zone(jaggedpine);}
	if ($text =~/kael/i) {quest::zone(kael);}
	if ($text =~/kaladimb/i) {quest::zone(kaladimb);}
	if ($text =~/karnor/i) {quest::zone(karnor);}
	if ($text =~/katta/i) {quest::zone(katta);}
	if ($text =~/kodtaz/i) {quest::zone(kodtaz);}
	if ($text =~/kurn/i) {quest::zone(kurn);}
	if ($text =~/lakeofillomen/i) {quest::zone(lakeofillomen);}
	if ($text =~/lakerathe/i) {quest::zone(lakerathe);}
	if ($text =~/letalis/i) {quest::zone(letalis);}
	if ($text =~/lfaydark/i) {quest::zone(lfaydark);}
	if ($text =~/maiden/i) {quest::zone(maiden);}
	if ($text =~/mischiefplane/i) {quest::zone(mischiefplane);}
	if ($text =~/mistmoore/i) {quest::zone(mistmoore);}
	if ($text =~/mseru/i) {quest::zone(mseru);}
	if ($text =~/nadox/i) {quest::zone(nadox);}
	if ($text =~/necropolis/i) {quest::zone(necropolis);}
	if ($text =~/nedaria/i) {quest::zone(nedaria);}
	if ($text =~/neriakc/i) {quest::zone(neriakc);}
	if ($text =~/netherbian/i) {quest::zone(netherbian);}
	if ($text =~/nightmareb/i) {quest::zone(nightmareb);}
	if ($text =~/nro/i) {quest::zone(nro);}
	if ($text =~/nurga/i) {quest::zone(nurga);}
	if ($text =~/oasis/i) {quest::zone(oasis);}
	if ($text =~/oot/i) {quest::zone(oot);}
	if ($text =~/paludal/i) {quest::zone(paludal);}
	if ($text =~/paw/i) {quest::zone(paw);}
	if ($text =~/permafrost/i) {quest::zone(permafrost);}
	if ($text =~/poair/i) {quest::zone(poair);}
	if ($text =~/podisease/i) {quest::zone(podisease);}
	if ($text =~/poeartha/i) {quest::zone(poeartha);}
	if ($text =~/poearthb/i) {quest::zone(poearthb);}
	if ($text =~/pofire/i) {quest::zone(pofire);}
	if ($text =~/poinnovation/i) {quest::zone(poinnovation);}
	if ($text =~/pojustice/i) {quest::zone(pojustice);}
	if ($text =~/ponightmare/i) {quest::zone(ponightmare);}
	if ($text =~/postorms/i) {quest::zone(postorms);}
	if ($text =~/potactics/i) {quest::zone(potactics);}
	if ($text =~/potimea/i) {quest::zone(potimea);}
	if ($text =~/potimeb/i) {quest::zone(potimeb);}
	if ($text =~/potorment/i) {quest::zone(potorment);}
	if ($text =~/povalor/i) {quest::zone(povalor);}
	if ($text =~/powater/i) {quest::zone(powater);}
	if ($text =~/qey2hh1/i) {quest::zone(qey2hh1);}
	if ($text =~/qinimi/i) {quest::zone(qinimi);}
	if ($text =~/qvic/i) {quest::zone(qvic);}
	if ($text =~/rathemtn/i) {quest::zone(rathemtn);}
	if ($text =~/riwwi/i) {quest::zone(riwwi);}
	if ($text =~/runnyeye/i) {quest::zone(runnyeye);}
	if ($text =~/scarlet/i) {quest::zone(scarlet);}
	if ($text =~/sebilis/i) {quest::zone(sebilis);}
	if ($text =~/shadowhaven/i) {quest::zone(shadowhaven);}
	if ($text =~/skyshrine/i) {quest::zone(skyshrine);}
	if ($text =~/sleeper/i) {quest::zone(sleeper);}
	if ($text =~/sncrematory/i) {quest::zone(sncrematory);}
	if ($text =~/snlair/i) {quest::zone(snlair);}
	if ($text =~/snplant/i) {quest::zone(snplant);}
	if ($text =~/snpool/i) {quest::zone(snpool);}
	if ($text =~/soldunga/i) {quest::zone(soldunga);}
	if ($text =~/soldungb/i) {quest::zone(soldungb);}
	if ($text =~/soldungc/i) {quest::zone(soldungc);}
	if ($text =~/solrotower/i) {quest::zone(solrotower);}
	if ($text =~/southkarana/i) {quest::zone(southkarana);}
	if ($text =~/sseru/i) {quest::zone(sseru);}
	if ($text =~/ssratemple/i) {quest::zone(ssratemple);}
	if ($text =~/swampofnohope/i) {quest::zone(swampofnohope);}
	if ($text =~/tenebrous/i) {quest::zone(tenebrous);}
	if ($text =~/thedeep/i) {quest::zone(thedeep);}
	if ($text =~/thegrey/i) {quest::zone(thegrey);}
	if ($text =~/thurgadinb/i) {quest::zone(thurgadinb);}
	if ($text =~/timorous/i) {quest::zone(timorous);}
	if ($text =~/tipt/i) {quest::zone(tipt);}
	if ($text =~/torgiran/i) {quest::zone(torgiran);}
	if ($text =~/trakanon/i) {quest::zone(trakanon);}
	if ($text =~/umbral/i) {quest::zone(umbral);}
	if ($text =~/unrest/i) {quest::zone(unrest);}
	if ($text =~/uqua/i) {quest::zone(uqua);}
	if ($text =~/veksar/i) {quest::zone(veksar);}
	if ($text =~/velketor/i) {quest::zone(velketor);}
	if ($text =~/vxed/i) {quest::zone(vxed);}
	if ($text =~/warslikswood/i) {quest::zone(warslikswood);}
	if ($text =~/westwastes/i) {quest::zone(westwastes);}
	if ($text =~/yxtta/i) {quest::zone(yxtta);}

	$client->Message(7, " "); #Spacer between Text messages to make them easier to read
}  

return 1;	#This line is required at the end of every plugin file in order to use it