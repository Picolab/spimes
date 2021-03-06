
ruleset b507199x7 {
  meta {
    name "Spime_manager"
    description <<
     spimes. space and time 
    >>
    author "burdettadam & BYUPICOLab"
    
    logging on

    //use module b16x24 alias system_credentials
    use module b506607x16 alias pds
    //use module b507199x5 alias wrangler

    provides spime
    sharing on

  }


  global { 




    spimes = function (){
      spimes = wrangler:children();
      spms = spimes{"children"};
      pdsSpimes = spimes.map( function(array) { 
        array.append([{
          'status'   : ("coool beans!"),
          'profile'     : wrangler:skyQuery(array[0],pds,profile, "").klog("profile"),
          'settings'     : wrangler:skyQuery(array[0],pds,settings,"").klog("settings"),
          'general'     : wrangler:skyQuery(array[0],pds,items,"").klog("general")
        }]);
      });
      pdsSpimes;
    }

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
      eventattrs = event:attrs();
      attributes = eventattrs.put(["Prototype_init_event_domain"],"wrangler")
                              .put(["Prototype_init_event_type"],"init_spime_events")
                              .put(["Prototype_rids"],"b507199x7.dev;b507199x12.dev")
                              ;
  	}
  	{
  		event:send({"cid":meta:eci()}, "wrangler", "child_creation")  
      with attrs = attributes;
  	}
  	always{
      log("create spime");
   // raise wrangler event 'child_creation'
   //   attributes attributes;
    }
  }

  
}