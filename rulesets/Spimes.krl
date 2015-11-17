
ruleset  {
  meta {
    name "nano_manager"
    description <<
     spimes. space and time 
    >>
    author "BYUPICOLab"
    
    logging off

    //use module b16x24 alias system_credentials
    use module a169x676 alias pds
    use module b507199x5 alias nano_manager

    provides create, edit, remove , spimes
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
 	spimes = function (key){
          pds:profile(k);
      {
       'status'   : (rids neq "error"),
        'rids'     : rids
      };
 	}
  }


  //------------------------------------------------------------------------------------Rules
  //-------------------- Rulesets --------------------
  rule createSpime{
  	select when spime create_spime
  	pre{
  		name = event:attr("name");
  		discription = event:attr("discription");
  	}
  	{
  		noop();
  	}
  	fired{
	// took from fuse_fleet.. whats api for?
		raise pds init; 
		raise pds event new_map_available 
            attributes 
      		{	
      			"namespace": "spime",
           		"mapvalues": { "name": name,
		     					"discription": discription 
		     				 }
          	};

  }
  
  rule installRulesets {
    select when nano_manager install_rulesets_requested
    pre { 
      eci = meta:eci();
      rids = event:attr("rids").defaultsTo("",standardError(" "));
      // this will never get an array from a url/event ?
      rid_list = rids.typeof() eq "array" => rids | rids.split(re/;/); 
    }
    if(rids neq "") then { // should we be valid checking?
      installRulesets(eci, rid_list);
    }
    fired {
      log (standardOut("success installed rids #{rids}"));
      log(">> successfully  >>");
          } 
    else {
      log(">> could not install rids #{rids} >>");
    }
  }

}