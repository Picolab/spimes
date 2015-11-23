
ruleset b506607x17 {
  meta {
    name "Spime_manager"
    description <<
     spimes. space and time 
    >>
    author "BYUPICOLab"
    
    logging off

    //use module b16x24 alias system_credentials
    use module b506607x16 alias sds
    //use module b507199x5 alias nano_manager

    provides  spime
    sharing on

  }

  //dispatch {
    //domain "ktest.heroku.com"
  //}
  /*

	spime = {
		// pr
		discription :
		name :
		policies

		loction : 
		eventChain :
		model (stl) :
		model instruction :

	}




  */
  global { 
 	spime = function (profilekey,settingskey,generalkey){
       spime_profile = sds:profile(profilekey);
       profile = spime_profile{"profile"};
       spime_settings = sds:settings(settingskey);
       settings = spime_settings{"settings"};
       spime_general = sds:items(generalkey);
       general = spime_general{"general"};

      {
       'status'   : ("coool beans!"),
        'profile'     : profile,
        'settings'     : settings,
        'general'     : general
      };
 	}
  }

  //------------------------------------------------------------------------------------Rules
  //-------------------- Rulesets --------------------
  //create, 
  rule createSpime{
  	select when spime create_spime
  	pre{
  		name = event:attr("owner");
  		discription = event:attr("discription");
  	}
  	{
  		noop();
  	}
  	always{
		raise sds event init_profile 
		    attributes 
           	{ 
           		"Name": name,
		    	"Discription": discription 
		    };
		//raise sds init_settings; 
		raise sds event new_map_available // init general  
            attributes 
      		{	
      			"namespace": "spime",
           		"mapvalues": { "name": name,
		     					"discription": discription 
		     				 }
         	};
  	}
  }
 rule editSpimeProfile{
  	select when spime edit_spime_profile
  	pre{
  		name = event:attr("owner");
  		discription = event:attr("discription");
  	}
  	{
  		noop();
  	}
  	always{
		raise sds event init_profile 
		    attributes 
           	{ 
           		"Name": name,
		    	"Discription": discription 
		    };
		//raise sds init_settings; 
		raise sds event new_map_available // init general  
            attributes 
      		{	
      			"namespace": "spime",
           		"mapvalues": { "name": name,
		     					"discription": discription 
		     				 }
         	};
  	}
  }
  
}