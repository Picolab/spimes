
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
       spime_settings = sds:settings(settingskey);
       spime_general = sds:general(generalkey);

      {
       'status'   : ("coool beans!"),
        'profile'     : spime_profile,
        'settings'     : spime_settings,
        'general'     : spime_general
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
		raise sds event init_provile 
		    attributes 
           	{ 
           		"name": name,
		    	"discription": discription 
		    };
		//raise sds init_settings; 
		raise sds event init_general  
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