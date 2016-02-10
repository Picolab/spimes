
ruleset b506607x17 {
  meta {
    name "Spime_manager"
    description <<
     spimes. space and time 
    >>
    author "burdettadam & BYUPICOLab"
    
    logging on

    //use module b16x24 alias system_credentials
    use module b506607x16 alias sds
    use module b507199x5 alias wrangler

    provides spime
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
		policies:

		loction : 
		eventChain :
		model (stl) :
		model instruction :

	}




  */
  global { 
      cloud_url = "https://#{meta:host()}/sky/cloud/";
      cloud = function(eci, mod, func, params) {
              response = http:get("#{cloud_url}#{mod}/#{func}", (params || {}).put(["_eci"], eci));
   
   
              status = response{"status_code"};
   
   
              error_info = {
                  "error": "sky cloud request was unsuccesful.",
                  "httpStatus": {
                      "code": status,
                      "message": response{"status_line"}
                  }
              };
   
   
              response_content = response{"content"}.decode();
              response_error = (response_content.typeof() eq "hash" && response_content{"error"}) => response_content{"error"} | 0;
              response_error_str = (response_content.typeof() eq "hash" && response_content{"error_str"}) => response_content{"error_str"} | 0;
              error = error_info.put({"skyCloudError": response_error, "skyCloudErrorMsg": response_error_str, "skyCloudReturnValue": response_content});
              is_bad_response = (response_content.isnull() || response_content eq "null" || response_error || response_error_str);
   
   
              // if HTTP status was OK & the response was not null and there were no errors...
              (status eq "200" && not is_bad_response) => response_content | error
          };

    spimes = function (){
      spimes = wrangler:children();
      pdsSpimes = spimes.map( function(array) { 
        array.append([{
          'status'   : ("coool beans!"),
          'profile'     : cloud(array[0],sds,profile, "").klog("profile"),
          'settings'     : cloud(array[0],sds,settings,"").klog("settings"),
          'general'     : cloud(array[0],sds,items,"").klog("general")
        }]);
      });
      pdsSpimes;
    };

  /* ---------------- the pico that represents the spime may not have this ruleset, so this function is dead code. 
  // we will have to call sds functions on the child pico.
 	spime = function (profilekey,settingskey,generalkey){
       spime_profile = sds:profile(profilekey).klog("profile");
       profile = spime_profile{"profile"};
       spime_settings = sds:settings(settingskey).klog("settings");
       settings = spime_settings{"settings"};
       spime_general = sds:items(generalkey).klog("general");
       general = spime_general{"general"};

      {
       'status'   : ("coool beans!"),
        'profile'     : profile,
        'settings'     : settings,
        'general'     : general
      };
 	}*/
  }

  //------------------------------------------------------------------------------------Rules
  //-------------------- Rulesets --------------------
  //create, 



//-------------------- Picos rules from wrangler  ----------------------
  rule createSpime{
  	select when spime create_spime
  	pre{
  	}
  	{
  		noop();
  	}
  	always{
    raise wrangler event 'child_creation'
      attributes event:attrs();
    }
  }

  rule init_PDS{
    select when wrangler child_created
    // init pds profile trigers on this same event.
		//raise sds init_settings; 
    pre{}
    {
      noop();
    }
    always{
		raise sds event new_map_available // init general  
            attributes 
      		{	
      			"namespace": "spime",
           		"mapvalues": { "name": name,
		     					"discription": discription 
		     				 }
         	}
  	}
  }

 rule editSpimeProfile{
  	select when spime edited_spime_profile
  	pre{
  	}
  	{
  		noop();
  	}
  	always{
		raise sds event edit_profile 
		    attributes event:attrs();
  	}
  }
  
}