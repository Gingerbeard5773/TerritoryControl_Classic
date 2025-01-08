
string[] w_wtf = {"gosh", "omg", "geez", "jesus", "woot", "wut", "wat", "oo", "xd", "huhuhu", "blurgle"};
string[] w_filler = {"like", "just", "maybe", "basically", "well", "*burp*", "pbfpsfst", "pffffoo", "buhuhu", "huhu", "harhar"};
string[] w_friends = {"darlings", "loves", "children", "friends", "comrades", "players", "beings", "bwoosh", "geti"};
string[] w_smileys = {":)", ":(", ":D", "XD", "xd", ":)))", ":o", ";(", ";_;", "<3", ":3"};

string GetWTF() { return w_wtf[XORRandom(w_wtf.length)]; }
string GetFiller() { return w_filler[XORRandom(w_filler.length)]; }
string GetFriends() { return w_friends[XORRandom(w_friends.length)]; }
string GetSmileys() { return w_smileys[XORRandom(w_smileys.length)]; }

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null) return true;

	CBlob@ blob = player.getBlob();
	if (blob is null) return true;

	///////////Lol, well you found it, feel free to look around.
	///////////If the lines here really annoy you, just send me a message.
	///////////If you're bunnie, then: AHAHAHAH :P
	
	if (player.getUsername() == "kreblthis" || player.getCharacterName() == "Hans Smooth")
	{
		if (XORRandom(100) < 20)
		{
			switch(XORRandom(16))
			{
				case 0:  text_out = "\"" + text_out + "\", said the badger";     break;
				case 1:  text_out += " seriously we need to stop the hatred";    break;
				case 2:  text_out += " and kick me if you dare yo";              break;
				case 3:  text_out += " or not???";                               break;
				case 4:  text_out += ", my comrades";                            break;
				case 5:  text_out += " save the refugees";                       break;
				case 6:  text_out += ", marx will rise again";                   break;
				case 7:  text_out += "... im sorry :(";                          break;
				case 8:  text_out += " and praise jesus";                        break;
				case 9:  text_out += " hail mary";                               break;
				case 10: text_out += " we're all equal";                         break;
				case 11: text_out += " ok?";                                     break;
				case 12: text_out += " no offense " + GetSmileys();              break;
				case 13: text_out += " woof woof " + GetSmileys();               break;
				case 14: text_out = GetFriends() + ", boing!!!!!! " + GetSmileys(); break;
				case 15: text_out = GetFriends() + ", together, we will " + text_out + " and everyone will be happy! " + GetSmileys(); break;
			}
		
			text_out = text_out.toLower();
		}
	}
	
	if (player.getUsername() == "olimarrex" || player.getCharacterName() == "Olimarrex")
	{
		if (XORRandom(100) < 15)
		{
			switch(XORRandom(13))
			{
				case 0:  text_out += "... right?";                                                               break;
				case 1:  text_out += ". jk " + GetSmileys();                                                     break;
				case 2:  text_out = "my " + GetFriends() + ", " + text_out + "!";                                break;
				case 3:  text_out += " yesterday";                                                               break;
				case 4:  text_out = GetFiller() + " " + text_out + " " + GetSmileys();                           break;
				case 5:  text_out = GetWTF() + ", like just " + text_out;                                        break;
				case 6:  text_out = "shouldn't we " + GetFiller() + " " + text_out + "? " + GetSmileys();        break;
				case 7:  text_out += " just " + GetFiller() + " gregor_builder";                                 break;
				case 8:  text_out += " it makes me sad " + GetSmileys();                                         break;
				case 9:  text_out += " rofl";                                                                    break;
				case 10: text_out += " " + GetSmileys();                                                         break;
				case 11: text_out += " understood?";                                                             break;
				case 12: text_out = GetFiller() + " if we " + text_out + ", nobody can stop us " + GetSmileys(); break;	
			}
			
			text_out = text_out.toLower();
		}
	}
	
	if (player.getUsername() == "Vamist" || player.getCharacterName() == "Vamist")
	{
		if (XORRandom(10) == 0)
			text_out += " Rawr~! <3";
	}
	
	if (player.getUsername() == "BarsukEughen555" || player.getCharacterName() == "BarsukEughen")
	{
		if (XORRandom(100) == 0)
		{
			if (XORRandom(2) == 0) text_out = "As we russians tend to say, " + text_out + "!";
			else text_out = "[Russians have been muted on this server]";
		}
	}
	
	if (player.getUsername() == "TFlippy" || player.getCharacterName() == "TFlippy")
	{
		if (XORRandom(100) == 0)
			text_out = "[If you have any problems using your TFlipppy9000, please consult your local Pirate-Rob.]";
	}
	
	if (XORRandom(100) < 20 && player.getUsername() == "bunnie" || player.getUsername() == "Bunnie" || player.getUsername() == "wormy" || player.getUsername() == "Wormy" || player.getCharacterName() == "Duncan")
	{
		switch (XORRandom(10))
		{
			case 0: text_out = "I hope everyone is doing well.";                        break;
			case 1: text_out = "You guys are all awesome.";                             break;
			case 2: text_out = "Thanks!";                                               break;
			case 3: text_out = "You guys are great.";                                   break;
			case 4: text_out = "Hope you are all having a good day.";                   break;
			case 5: text_out = "Remember to be nice to eachother!";                     break;
			case 6: text_out = "Hugs to anyone who gets me some gold please.";          break;
			case 7: text_out = "Can someone kindly explain how this mod works please?"; break;
			case 8: text_out = ":D";                                                    break;
			case 9: text_out = "You're all special to me <3";                           break;
		}
	}
	
	if (player.getUsername() == "TheClev" || player.getCharacterName() == "Clev")
	{
		if (XORRandom(100) == 0) text_out = "HONESTLY, THE NEXT PERSON TO SPEAK GETS BANNED";
	}
	
	//i bet u didnt see this coming.
	if (player.getUsername() == "blackguy123" ||  player.getCharacterName() == "DarkSlayer")
	{
		if (XORRandom(9) == 0)
		{
			switch (XORRandom(8))
			{
				case 0: text_out += ". Where is my daddy mithrios?? "+GetSmileys();     break;
				case 1: text_out += ". NEVER TRUST A NEUTERAL";                         break;
				case 2: text_out += ", this nigga";                                     break;
				case 3: text_out += " piece of shit lag fucking glithc";                break;
				case 4: text_out = "DARK WILL RISE AGAIN!";                             break;
				case 5: text_out = "Let me tell you a glorious story. "+text_out;       break;
				case 6: text_out = "just reminiscing about DARK right now...";          break;
				case 7: text_out = "let me tell you my son, "+text_out;                 break;
			}
		}
		
		if (getPlayerByUsername("MrHobo") !is null && XORRandom(8) == 0)
		{
			if (XORRandom(2) == 0)
			{
				if (XORRandom(2) == 0) text_out = "gingerbreadman ussr is dead stop trying to revive";
				else                   text_out = "gingerbeard, big fan of yours";
			}
			else text_out += ", GINGERBEARD";
		}

		if (XORRandom(20) == 0) text_out += " ;-;";
		if (XORRandom(40) == 0) text_out += " rip";
		if (XORRandom(40) == 0) text_out += " LMAO";
		if (XORRandom(40) == 0) text_out += " xD";
		if (XORRandom(40) == 0) text_out += " LAG";
		if (XORRandom(40) == 0) text_out = "kag";
	}
	
	if (blob.exists("drunk") && blob.get_u16("drunk") > 0)
	{
		if (XORRandom(100) < blob.get_u16("drunk") * 10)
		{
			switch(XORRandom(13))
			{
				case 0:  text_out += "... hic!";                                                                  break;
				case 1:  text_out += ". jk " + GetSmileys();                                                      break;
				case 2:  text_out = "my " + GetFriends() + ", " + text_out + "!";                                 break;
				case 3:  text_out += " yesterday";                                                                break;
				case 4:  text_out = GetFiller() + " " + text_out + " " + GetSmileys();                            break;
				case 5:  text_out = GetWTF() + ", like just " + text_out;                                         break;
				case 6:  text_out = "shouldn't we " + GetFiller() + " " + text_out + "? " + GetSmileys();         break;
				case 7:  text_out += " just " + GetFiller() + " like gregor_builder";                             break;
				case 8:  text_out += " pffffut " + GetSmileys();                                                  break;
				case 9:  text_out += " rofl";                                                                     break;
				case 10: text_out += " " + GetSmileys();                                                          break;
				case 11: text_out += " belugh?";                                                                  break;	
				case 12: text_out = GetFiller() + " if we " + text_out + ", nobodsy can stop us " + GetSmileys(); break;	
			}
			text_out = text_out.toLower().replace("c", "sh").replace("o", "hoh").replace("ing", "h...");
		}
	}

	return true;
}
