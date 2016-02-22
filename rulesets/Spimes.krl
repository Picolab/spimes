
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

  global { 
    // prototypes 
    Prototype_rids = "b507199x7.dev";//"asdf;asdf;asdf"
    Prototype_events = [["spime","init_general"],["spime","init_profile"],["spime","init_settings"]]; // array of arrays [[domain,type],....], used to create data structure in pds.
  }
  rule initializeEvents {// this rule should raise events to self that then raise events to pds
    select when wrangler init_spime_events 
      foreach Prototype_events setting (PT_event)
    pre {
      PTE_domain = PT_event[0];
      PTE_type = PT_event[1];
    }
    {
      noop();
    }
    always {
      raise PTE_domain event PTE_type 
            attributes event:attrs()
    }
  }
  rule initializeGeneral{
    select when spime init_general 
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
    select when spime init_profile 
    pre{}
    {
      noop();
    }
    always{
    raise pds event updated_profile // init prototype  
            attributes 
          { 
            "Name": "spime_profile", 
             "location": "byu-oit"
          }
    }
  }
  rule initializeSettings{
    select when spime init_settings
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