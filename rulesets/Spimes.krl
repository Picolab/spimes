
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

  }

  rule initPdsGeneral{
    select when wrangler child_created where prototype eq "spime"//  we should select only on a certin attribute
    pre{}
    {
      noop();
    }
    always{
    raise pds event new_sds_map_available // init general  
            attributes 
          { 
            "namespace": "spime",
              "mapvalues": { "name": "tedrub",
                  "discription": "ted rub was a time wizard!" 
                 }
          }
    }
  }

  rule initPdsPrototype{
    select when wrangler child_created where prototype eq "spime"
    pre{}
    {
      noop();
    }
    always{
    raise pds event new_sds_prototype_available // init prototype  
            attributes 
          { 
            "prototype": "hashPath", // this is for front end, so a website can build and display your prototype
             "structure": { "time": "Mastering"
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