
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
    //use module b507199x5 alias nano_manager

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

  //-------------------- Picos function from wrangler --------------------

  children = function() {
    self = meta:eci();
    children = pci:list_children(self).defaultsTo("error", standardError("pci children list failed"));
    {
      'status' : (children neq "error"),
      'children' : children
    }
  }
  parent = function() {
    self = meta:eci();
    parent = pci:list_parent(self).defaultsTo("error", standardError("pci parent retrieval failed"));
    {
      'status' : (parent neq "error"),
      'parent' : parent
    }
  }
  name = function() {
    {
      'status' : true,
      'picoName' : ent:name
    }
  }
  attributes = function() {
    {
      'status' : true,
      'attributes' : ent:attributes
    }
  }
  prototypes = function() {
    {
      'status' : true,
      'prototypes' : ent:prototypes
    }
  }
  
  
  deletePico = defaction(eci) {
    noret = pci:delete_pico(eci, {"cascade":1});
    send_directive("deleted pico #{eci}");
  }
  
  
  prototypeDefinitions = {
    "core": [
        "b507199x5.dev"
      //"a169x625"
    ]
  }
  picoFactory = defaction(myEci, name, protos) {
    newPicoInfo = pci:new_pico(myEci);
    newPico = newPicoInfo{"cid"};
    a = pci:new_ruleset(newPico, prototypeDefinitions{"core"}); 
    b = protos.map(function(x) {pci:new_ruleset(newPico, prototypeDefinitions{x});});
    
    event:send({"eci":newPico}, "wrangler", "child_created")
      with attrs = {
        "name" : name
      }
  }


  //-------------------- Picos function from wrangler --------------------









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
  rule createSpime{




//-------------------- Picos rules from wrangler  ----------------------
  rule createChild {
    select when wrangler child_creation
    
    pre {
      myEci = meta:eci();
      
      name = event:attr("name").defaultsTo("", standardError("no name passed"));
    }

    if (name neq "") then
    {
      picoFactory(myEci, name, []);
    }
    
    fired {
      log(standardOut("pico created with name #{name}"));
    }
    else
    {
      log "no name passed for new child";
    }
  }
   
  rule initializeChild {
    select when wrangler child_created
    
    pre {
      name = event:attr("name");
      //attrs = event:attr("attributes").decode();
      //protos = event:attr("prototypes").decode();
    }
    
    {
      noop();
    }
    
    fired {
      set ent:name name;
      //set ent:attributes attrs;
      //set ent:prototypes protos;
    }
  }

  rule setPicoAttributes {
    select when wrangler set_attributes_requested
    pre {
      newAttrs = event:attr("attributes").decode().defaultsTo("", standardError("no attributes passed"));
    }
    if(newAttrs neq "") then
    {
      noop();
    }
    fired {
      set ent:attributes newAttrs;
    }
    else {
      log "no attributes passed to set pico rule";
    }
  }
  
  rule clearPicoAttributes {
    select when wrangler clear_attributes_requested
    pre {
    }
    {
      noop();
    }
    fired {
      clear ent:attributes;
    }
  }
  
  rule deleteChild {
    select when wrangler child_deletion
    pre {
      eciDeleted = event:attr("deletionTarget").defaultsTo("", standardError("missing pico for deletion"));
    }
    if(eciDeleted neq "") then
    {
      deletePico(eciDeleted);
    }
    notfired {
      log "deletion failed because no child was specified";
    }
  }

//-------------------- Picos rules from wrangler  ----------------------
  

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