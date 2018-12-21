/*
Anti-Camp v1.0 developed by Airit3ch, specifically for CoD4x servers. Run in your main_shared and adjust globallogic.gsc
Features adjustable time frames before death, see campTimer variable. 
Also features adjustable ranges for it to be considered camping, see maxDistance variable.
DO NOT USE, SHARE OR MODIFY THIS FILE WITHOUT PERMISSION
Developer Notes:
When I wrote this code, only god and I knew how it worked.
Now its only god. 
*/


/*
Whats new in Version 1.1
Bug fixes:
Fixed a bug that when a player goes into spectator, then joins back in, he no longer will get warned or die from the plugin
he would have immunity. 
Updates:
Adjusted camp time from 30 to 15 seconds, which will cause 20 seconds before actual death, instead of 40. 
*/


/*
Whats new in version 2.0
New Features
Added in a campCounter, which after 4 times of being killed for camping the player will be kicked with warnings!
Added in immunity for specific players, included is players with the name bot. 
Adjusted the camp warning time to 15 seconds, then 10 seconds after that the player will be killed/kicked
Total time before warn or kick is 25 seconds.
Added in a stop script for if the player goes into spectator, then resumes the script if they respawn.
Added a feature that when the player gets kicked the server will broadcast it
*/


main()
{
	level onPlayerConnected();
}

onPlayerConnected()
{
	self endon("intermission");

	while(1)
	{
		self waittill("connected", peep);

		peep thread onSpawnedPlayer();
	}

}

onSpawnedPlayer()
{
	self endon("intermission");

	self endon("disconnect");

	self waittill("spawned_player");

	self thread whenPlayerSpawns();
}

whenPlayerSpawns()
{
	guid = self getGuid();

/*
	Use this to make it so that some players are immune to the script.
	if(guid == "")
	{
		return;
	}
*/

	self thread antiCamp();
}

antiCamp()
{
	self endon("disconnect");

	campTime = 0;
	campCounter = 0;
	beenWarned = false;
	maxDistance = 80;
	campTimer = 15;


	while( 1 )
		{
			old_position = self.origin;
			wait 1;

			new_position = self.origin;
			distance = distance2d( old_position, new_position );


			if(self.sessionstate == "spectator")
			{
				self waittill("spawned_player");
			}

			if( distance < maxDistance )
			{
				campTime++;
			}
			else
			{
				campTime = 0;
				beenWarned = false;
			}

			if( campTime == campTimer && !beenWarned )
			{
				self iPrintLnBold( "Please stop camping, ^110 seconds ^7to move" );
				beenWarned = true;
			}

			if( campTime == ( campTimer + 10 ) && beenWarned )
			{
				campCounter++;

				if(campCounter == 4)
				{
					self iPrintLnBold("^1Moving player to spectator!");

					wait 3;

					//exec("say "+self.name+" has been ^1KICKED! ^7 for excessive ^1camping!");

					//exec("clientkick "+guid + " excessive camping");

					self.sessionstate = "spectator";
					//In theory 133 should put the player to spectator mode. 
					self onSpawnedPlayer();					
				}

				if(campCounter == 5)
				{
					self iPrintLnBold("You will be kicked for camping!");

					wait 3;

					exec("say "+self.name+" has been ^1KICKED! ^7 for excessive ^1camping!");

					exec("clientkick "+guid + " excessive camping");
				}

				self iPrintLnBold( "You will be ^1killed ^7for camping!");

				if(campCounter == 3)
				{
					self iPrintlnBold("^3If you camp one more time you will be ^1moved to spectator!");
				}

				wait 2;
				self suicide();
			}
		}


}


