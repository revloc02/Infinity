REM This file transfers Perl files in development to the DEV box directory so they can be used and tested.

REM Before we do that I need to create copies of some files to other zones. Typically the master file will be in the guildlobby and I will duplicate it out to whatever other zones need it. (This way I just edit the master file and all of the others will be the same.)
REM copy Aediles_Thrall
COPY .\EQEmu\quests\guildlobby\Aediles_Thrall.pl .\EQEmu\quests\bazaar\Aediles_Thrall.pl /V /Y

REM copy Goldgreat
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\blackburrow\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\butcher\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\crushbone\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\everfrost\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\feerrott\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\fieldofbone\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\freportw\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\misty\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\poknowledge\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\qeytoqrg\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\shadeweaver\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\steamfont\Goldgreat.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Goldgreat.pl .\EQEmu\quests\tox\Goldgreat.pl /V /Y

REM copy Armorer_Koolag, Barbarian_Lenelila, Daizy_Duke, Karie_Emberwood, Tayksie to pok
COPY .\EQEmu\quests\guildlobby\Armorer_Koolag.pl .\EQEmu\quests\poknowledge\Armorer_Koolag.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Daizy_Duke.pl .\EQEmu\quests\poknowledge\Daizy_Duke.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Barbarian_Lenelila.pl .\EQEmu\quests\poknowledge\Barbarian_Lenelila.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Karie_Emberwood.pl .\EQEmu\quests\poknowledge\Karie_Emberwood.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Tayksie.pl .\EQEmu\quests\poknowledge\Tayksie.pl /V /Y
COPY .\EQEmu\quests\guildlobby\Xana.pl .\EQEmu\quests\poknowledge\Xana.pl /V /Y

REM potentially create folders that need to be there: mmca, illsalina
IF NOT EXIST C:\EQEmu\EQEmuInfinity\quests\mmca MKDIR C:\EQEmu\EQEmuInfinity\quests\mmca
IF NOT EXIST C:\EQEmu\EQEmuInfinity\quests\illsalina MKDIR C:\EQEmu\EQEmuInfinity\quests\illsalina


REM Deploy all to DEV
XCOPY .\EQEmu  C:\EQEmu\EQEmuInfinity /E /V /Y

EXIT