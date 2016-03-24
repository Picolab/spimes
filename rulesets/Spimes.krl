
ruleset b507199x12 {
  meta {
    name "Spime"
    description <<
     spimes. space and time 
    >>
    author "burdettadam & BYUPICOLab"
    
    logging on

    //use module b16x24 alias system_credentials
    use module b506607x16 alias pds
    use module b507199x5 alias wrangler

    provides spime
    sharing on

  }

  global { 
    // prototypes 
    Prototype_rids = "b507199x7.dev";//"asdf;asdf;asdf"
    Prototype_events = [["spime","spime_init_general"],["spime","spime_init_profile"],["spime","spime_init_settings"]]; // array of arrays [[domain,type],....], used to create data structure in pds.
  }
  rule initializeEvents {// this rule should raise events to self that then raise events to pds
    select when wrangler init_spime_events 
      foreach Prototype_events setting (PT_event)
    pre {
      PTE_domain = "explicit";//PT_event[0];
      PTE_type = PT_event[1];
    }
    {
      event:send({"cid":meta:eci()}, PTE_domain, PTE_type)  
      with attrs = event:attrs();
    }
    always {
      log("init spime");
    }
  }
  rule initializeGeneral{
    select when explicit spime_init_general 
    pre{}
    {
      noop();
    }
    always{
    raise pds event map_item // init general  
            attributes 
          { 
            "namespace": "spime",
              "mapvalues": { "name": "tedrub",
                  "discription": "ted rub was a time wizard!" 
                 }
          }
    }
  }

  rule initializeProfile{
    select when explicit spime_init_profile 
    pre{
      attrs = event:attrs();
    }
    {
      noop();
    }
    always{
      raise pds event updated_profile // init prototype  
            attributes attrs
         // { 
         //   "Name": "spime_profile", 
         //    "location": "byu-oit"
         // }
    }
  }
  rule initializeSettings{
    select when explicit spime_init_settings
    pre{}
    {
      noop();
    }
    always{
    raise pds event add_settings // init prototype  
            attributes 
          { 
            "Name": "spimes_settings", // this is for front end, so a website can build and display your prototype
             "setAttr": "time",
             "setValue": "Mastering"
          }
    }
  }
  

 rule editSpimeProfile{
  	select when explicit edited_spime_profile
  	pre{
  	}
  	{
  		noop();
  	}
  	always{
		raise pds event edit_profile 
		    attributes event:attrs();
  	}
  }
  
}