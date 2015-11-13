ruleset a169x676 {
  meta {
    name "PDS"
    description <<
      Pico Data Services
    >>
    author "Phil Windley & Ed Orcutt"
    logging off
    // errors to a169x705

    sharing on
    provides items, get_keys, profile,
             list_settings, get_setting_data_value,
             get_setting, get_setting_value, get_setting_all, get_setting_data, get_setting_schema,
             get_config_value, get_all_items
  
/*    provides get_item, get_items, get_keys, get_me, get_all_me,
             list_settings, get_setting_data_value,
             get_setting, get_setting_value, get_setting_all, get_setting_data, get_setting_schema,
             get_config_value, get_all_items
*/
    // --------------------------------------------
    // ent:me
    // ent:elements
    // ent:settings
    //
    //   "a169x222" : {
    //     "setName"   : "",
    //     "setRID"    : "a169x222",
    //     "setData"   : {},
    //     "setSchema" : []
    //   }
    //
    // --------------------------------------------
    // ent:me{"myProfileSchemaName"}

  }

  global {
    thisRID = meta:rid();


   /* // -fordebugging???-------------------------------------------
    get_all_items = function() {
      ent:elements;
    };
  */
    items = function (namespace, key){
          // --------------------------------------------
      item = function(namespace, keyvalue) {
        ent:elements{[namespace, keyvalue]}
      };

      // --------------------------------------------
      multipleItems = function(namespace) {
        ent:elements{namespace}
      };
      return = (keyvalue.isnull()) => item(namespace, key) | multipleItems( namespace);
      return; 
    }
    // set up pagination. look at fuse_fuel.krl allfillup 
    get_keys = function(namespace, sort_opt, num_to_return) {
        the_keys = this2that:transform(ent:elements{[namespace]}, sort_opt);
        the_keys.isnull()          => [] |
        not num_to_return.isnull() => the_keys.slice(0,num_to_return-1)
                                    | the_keys
    };

    profile = function(key){
        get_me = function(k) {
          ent:me{k};
        };
        get_all_me = function() {
          ent:me;
        };
        return = (key.isnull()) => get_all_me() | get_me(key);
        return; 
    }


    // --------------------------------------------
    list_settings = function() {
      foo = ent:settings.keys().map(function(setRID) {
        setName = ent:settings{[setRID,"setName"]};
        {"setRID": setRID, "setName": setName}
      });
      foo
    };

    // --------------------------------------------
    get_setting_all = function() {
      ent:settings
    };

    // --------------------------------------------
    get_setting = function(setRID) {
      ent:settings{setRID}
    };

    // --------------------------------------------
    get_setting_value = function(setRID, setKey) {
      ent:settings{[setRID, setKey]}
    };

    // --------------------------------------------
    get_setting_data = function(setRID) {
     ent:settings{[setRID, "setData"]}
    };

    // --------------------------------------------
    get_setting_schema = function(setRID) {
     ent:settings{[setRID, "setSchema"]}
    };

    // --------------------------------------------
    get_setting_data_value = function(setRID, setKey) {
      ent:settings{[setRID, "setData", setKey]}
    };

    get_config_value = function(setKey) {
      setRID = meta:callingRID();
      ent:settings{[setRID, "setData", setKey]}
    };

    // --------------------------------------------
    defaultProfile = {
      "myProfileName": "",
      "myProfileEmail": "",
      "myProfilePhone": "",
      "myProfileNotes": "",
      "myProfileDescription": "",
      "myProfilePhoto": "https://s3.amazonaws.com/k-mycloud/a169x672/unknown.png"
    };

    defaultCloud = {
      "mySchemaName" : "Person",
      "myDoorbell" : "none"
    };
  }

  // ========================================================================
  // PDS Rules
  // ========================================================================

  // ------------------------------------------------------------------------
  rule PDS_add_item {
    select when pds new_data_available
    pre {
    }
    always {
      log "PDS ADD ITEM:";
      log event:attrs();
      set ent:elements{[event:attr("namespace"), event:attr("keyvalue")]} event:attr("value");
      raise pds event new_data_added with 
         namespace = event:attr("namespace") and
         keyvalue = event:attr("keyvalue");
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_update_item {
    select when pds updated_data_available
    	foreach(event:attr("value") || {}) setting(akey, avalue)
    pre {
		  namespace = event:attr("namespace");
			keyvalue  = event:attr("keyvalue");
    }
    always {
      set ent:elements{[namespace, keyvalue, akey]} avalue;
      raise pds event data_updated with 
        namespace = event:attr("namespace") and
        keyvalue = event:attr("keyvalue") if last;
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_remove_item {
    select when pds remove_old_data
    always {
      clear ent:elements{[event:attr("namespace"), event:attr("keyvalue")]};
      raise pds event data_deleted with 
        namespace = event:attr("namespace") and
        keyvalue = event:attr("keyvalue");
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_remove_namespace {
    select when pds remove_namespace
    always {
      clear ent:elements{event:attr("namespace")};
      raise pds event namespace_deleted with 
        namespace = event:attr("namespace") and
        keyvalue = event:attr("keyvalue");
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_map_item {
    select when pds new_map_available
    pre {
    }
    always {
      set ent:elements{event:attr("namespace")} event:attr("mapvalues");
      raise pds event new_map_added  with 
           namespace = event:attr("namespace");
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_add2_item {
    select when pds new_data2_available
    pre {
    }
    always {
      set ent:elements{[event:attr("namespace"), event:attr("section"), event:attr("keyvalue")]} event:attr("value");
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_init_me {
    select when web sessionReady
    pre {
      me = ent:me;
    }
    if (ent:me == 0) then { noop(); }
    fired {
      set ent:me defaultProfile;
    }
  }

  // ------------------------------------------------------------------------
  // Settings
  // ------------------------------------------------------------------------

  // ------------------------------------------------------------------------
  rule PDS_init_mycloud {
    select when web sessionReady
    if (ent:elements{"myCloud"} == 0) then { noop(); }
    fired {
      set ent:elements{"myCloud"} defaultCloud;
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_legacy_person {
    select when web sessionReady
    pre {
      schema = ent:elements{["myCloud", "mySchemaName"]};
    }
    if (schema eq "person") then { noop(); }
    fired {
      set ent:elements{["myCloud", "mySchemaName"]} "Person";
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_update_profile {
    select when pds new_profile_item_available
    pre {
      created = get_me("_created") || time:strftime(time:now(), "%Y%m%dT%H%M%S%z", {"tz":"UTC"});
      newProfile = event:attrs();
      newProfileWithImage = newProfile
                .put(["myProfilePhoto"], (newProfile{"myProfilePhoto"} || defaultProfile{"myProfilePhoto"}))
                .put(["_created"], created)
                .put(["_modified"], time:strftime(time:now(), "%Y%m%dT%H%M%S%z", {"tz":"UTC"}))
                ;
    }
    always {
      set ent:me newProfileWithImage;
      raise pds event "profile_updated" attributes newProfileWithImage;
    }
  }

  rule PDS_update_profile_partial {
    select when pds updated_profile_item_available
    foreach event:attrs() setting(profile_key, profile_value)

    {
      noop();
    }

    fired {
      set ent:me {} if not ent:me;
      set ent:me{profile_key} profile_value;
      raise pds event "profile_updated" on last;
    }

  }

  // ------------------------------------------------------------------------
  rule PDS_new_profile_schema {
    select when pds new_profile_schema
    always {
      set ent:elements{["myCloud", "mySchemaName"]} event:attr("mySchemaName")
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_update_doorbell {
    select when pds new_doorbell_available
    always {
      set ent:me{"myDoorbell"} event:attr("doorbell");
      set ent:elements{["myCloud", "myDoorbell"]} event:attr("doorbell");
    }
  }


  // ------------------------------------------------------------------------
  rule PDS_add_settings_schema {
    select when pds new_settings_schema
    pre {
      setName   = event:attr("setName") || "unknown";
      setRID    = event:attr("setRID") || "unknown";
      setSchema = event:attr("setSchema") || [];
      setData   = event:attr("setData") || {};

      gotData = ent:settings{[setRID, "setData"]};
    }
    always {
      set ent:settings{[setRID, "setName"]}   setName;
      set ent:settings{[setRID, "setRID"]}    setRID;
      set ent:settings{[setRID, "setSchema"]} setSchema;
      set ent:settings{[setRID, "setData"]}   setData if not gotData;
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_add_settings_data {
    select when pds new_settings_data
    pre {
      setRID    = event:attr("setRID") || "unknown";
      setData   = event:attr("setData") || {};
    }
    always {
      set ent:settings{[setRID, "setData"]} setData;
    }
  }

  // ------------------------------------------------------------------------
  // [PJW] new, mirrors other rules (like profile)
  rule PDS_add_settings {
    select when pds new_settings_available
    pre {
      setRID    = event:attr("setRID") || "unknown";
      setData   = event:attrs() || {};
    }
    always {
      set ent:settings{[setRID, "setData"]} setData.delete(["setRID"]);
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_add_settings_attribute {
    select when pds new_settings_attribute
    pre {
      setRID    = event:attr("setRID")   || "unknown";
      setAttr   = event:attr("setAttr")  || "unknown";
      setValue  = event:attr("setValue") || "unknown";
    }
    always {
      set ent:settings{[setRID, "setData", setAttr]} setValue;
    }
  }

  // ------------------------------------------------------------------------
  rule PDS_application_uninstalled {
    select when explicit application_uninstalled
    always {
      clear ent:settings{event:attr("appid")};
    }
  }

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
