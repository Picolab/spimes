ruleset b506607x16 {
  meta {
    name "SDS"
    description <<
      Spime Data Services
    >>
    author "Phil Windley & Ed Orcutt & PicoLabs"
    logging off

    sharing on
    provides items, get_keys, profile,
             list_settings, get_setting_data_value,
             get_setting, get_setting_value, get_setting_all, get_setting_data, get_setting_schema,
             get_config_value, get_all_items

    // --------------------------------------------
    // ent:profile
    // ent:general
    // 
    // ent:settings 
    //     "a169x222" : {
    //       "setName"   : "",
    //       "setRID"    : "a169x222",
    //       "setData"   : {},
    //       "setSchema" : []
    //     }
    //
    // --------------------------------------------
    // ent:profile{"myProfileSchemaName"}

  }

  global {
    thisRID = meta:rid();


   /* // -fordebugging???-------------------------------------------
    get_all_items = function() {
      ent:general;
    };
  */
    items = function (namespace, key){
      item = function(namespace, keyvalue) {
        ent:general{[namespace, keyvalue]}
      };

      multipleItems = function(namespace) {
        ent:general{namespace}
      };
      return = (keyvalue.isnull()) => item(namespace, key) | multipleItems( namespace);
      {
       'status'   : ("succes"),
        'general'     : return
      };
    }
    // set up pagination. look at fuse_fuel.krl allfillup 
    get_keys = function(namespace, sort_opt, num_to_return) {
        the_keys = this2that:transform(ent:general{[namespace]}, sort_opt); // get all the keys sorted by the key value provided in sort_opt
        the_keys.isnull()          => [] |
        not num_to_return.isnull() => the_keys.slice(0,num_to_return-1) // only return how much we want
                                    | the_keys
    };

    profile = function(key){
        get_profile = function(k) {
          ent:profile{k};
        };
        get_all_profile = function() {
          ent:profile;
        };
        return = (key.isnull()) => get_all_profile() | get_profile(key);
        {
       'status'   : ("succes"),
        'profiles'     : return
        };
    };


    // --------------------------------------------
    list_settings = function() {
      foo = ent:settings.keys().map(function(setRID) {
        setName = ent:settings{[setRID,"setName"]};
        {
          "setRID": setRID,
          "setName": setName
        }
      });
      foo
    };

    settings = function(Rid,Key){
      get_setting_all = function() {
        ent:settings
      };
      get_setting = function(setRID) {
        ent:settings{setRID}
      };
      get_setting_value = function(setRID, setKey) {
        ent:settings{[setRID, setKey]}
      };
      return = (Key.isnull()) => ((Rid.isnull()) => get_setting_all() | get_setting(Rid) ) | (
                              Rid.isnull() => "error" | get_setting_value(Rid,Key));
      {
       'status'   : "succes",
        'settings' : return
      };
    }

    // I dont Think we need this function. --------------------------------------------
    //get_setting_data = function(setRID) {
   //  ent:settings{[setRID, "setData"]}
  //  };

    // --------------------------------------------
 //   get_setting_schema = function(setRID) {
 //    ent:settings{[setRID, "setSchema"]}
 //   };

    // --------------------------------------------
    get_setting_data_value = function(setRID, setKey) {
      ent:settings{[setRID, "setData", setKey]}
    };

    get_config_value = function(setKey) {
      setRID = meta:callingRID();
      ent:settings{[setRID, "setData", setKey]}
    };

    defaultProfile = {
      "Name": "",
      "Notes": "",
      "location": "",
      "model": "",
      "Description": "",
      "Photo": "https://s3.amazonaws.com/k-mycloud/a169x672/unknown.png"
    };

    defaultCloud = {
      "mySchemaName" : "Person",
      "myDoorbell" : "none"
    };
  }
// Rules
// ent: general
  rule SDS_add_item {
    select when sds new_data_available
    pre {
      namespace = event:attr("namespace").defaultsTo("", "no namespace");
      keyvalue = event:attr("key").defaultsTo("", "no key");
      hash_path = [namespace, keyvalue]; //array of keys
      value =  event:attr("value").defaultsTo("", "no value");
    }
    always {
      set ent:general{hash_path} value;
      raise sds event new_data_added with 
         namespace = namespace and
         keyvalue = keyvalue;
    }
  }

  rule SDS_update_item { 
    select when sds updated_data_available
    	foreach(event:attr("value") || {}) setting(akey, avalue)
    pre {
      namespace = event:attr("namespace").defaultsTo("", "no namespace");
      keyvalue = event:attr("key").defaultsTo("", "no key");
      hash_path = [namespace, keyvalue, akey];
    }
    always {
      set ent:general{ hash_path } avalue;
      raise sds event data_updated with 
        namespace = namespace and
        keyvalue = keyvalue if last;
    }
  }

  rule SDS_remove_item {
    select when sds remove_old_data
    pre{
      namespace = event:attr("namespace").defaultsTo("", "no namespace");
      keyvalue = event:attr("key").defaultsTo("", "no key");
      hash_path = [namespace, keyvalue];
    }
    always {
      clear ent:general{hash_path};
      raise sds event data_deleted with 
        namespace = namespace and
        keyvalue = keyvalue;
    }
  }

  rule SDS_remove_namespace {
    select when sds remove_namespace
    pre{
      namespace = event:attr("namespace").defaultsTo("", "no namespace");
    }
    always {
      clear ent:general{namespace};
      raise sds event namespace_deleted with 
        namespace = namespace;
    }
  }

  rule SDS_map_item {
    select when sds new_map_available
    pre{
      namespace = event:attr("namespace").defaultsTo("", "no namespace");
      mapvalues = event:attr("mapvalues").defaultsTo("", "no mapvalues");
    }
    always {
      set ent:general{namespace} mapvalues;
      raise sds event new_map_added  with 
           namespace = namespace and
           mapvalues = mapvalues;
    }
  }

  rule SDS_add2_item { // uses different hash_path to add a varible
    select when sds new_data2_available
    pre {
      namespace = event:attr("namespace").defaultsTo("", "no namespace");
      section = event:attr("section").defaultsTo("", "no section");
      keyvalue = event:attr("keyvalue").defaultsTo("", "no keyvalue");
      hash_path = [namespace, section, keyvalue];
      value =  event:attr("value").defaultsTo("", "no value");
    }
    always {
      set ent:general{hash_path} value;
    }
  }
  // I dont think we need myCloud any more.
  /*
  rule SDS_init_mycloud {
    select when web sessionReady
    if (ent:general{"myCloud"} == 0) then { noop(); }
    fired {
      set ent:general{"myCloud"} defaultCloud;
    }
  }

  // ------------------------------------------------------------------------
  rule SDS_legacy_person {
    select when web sessionReady
    pre {
      schema = ent:general{["myCloud", "mySchemaName"]};
    }
    if (schema eq "person") then { noop(); }
    fired {
      set ent:general{["myCloud", "mySchemaName"]} "Person";
    }
  }
*/


  // profile
  rule SDS_init_profile {
    select when web sessionReady // web session ??????????
    pre {
      profile = ent:profile;
    }
    if (profile == 0) then { 
      noop(); 
    }
    fired {
      set ent:profile defaultProfile;
    }
  }

  rule SDS_update_profile {
    select when sds new_profile_item_available
    pre {
      // get when sds was created.
      created = profile("_created") || time:strftime(time:now(), "%Y%m%dT%H%M%S%z", {"tz":"UTC"});
      newProfile = event:attrs();
      newProfileWithImage = newProfile
                .put(["myProfilePhoto"], (newProfile{"Photo"} || defaultProfile{"Photo"})) 
                .put(["_created"], created)
                .put(["_modified"], time:strftime(time:now(), "%Y%m%dT%H%M%S%z", {"tz":"UTC"}))
                ;
    }
    always {
      set ent:profile newProfileWithImage;
      raise sds event "profile_updated" attributes newProfileWithImage;
    }
  }

  rule SDS_update_profile_partial {
    select when sds updated_profile_item_available
    foreach event:attrs() setting(profile_key, profile_value)

    {
      noop();
    }

    fired {
      set ent:profile {} if not ent:profile; // creates a profile ent if not aready there
      set ent:profile{profile_key} profile_value;
      raise sds event "profile_updated" on last;
    }

  }

  rule SDS_new_profile_schema {
    select when sds new_profile_schema
    pre{
      hash_path = ["myCloud", "mySchemaName"]; // whats my cloud for ???
      mySchemaName = event:attr("mySchemaName").defaultsTo("", "no mySchemaName");

    }
    always {
      set ent:general{hash_path} mySchemaName; // why is this stored in general and not profile?
    }
  }

  rule SDS_update_doorbell {
    select when sds new_doorbell_available
    pre{
      doorbell = event:attr("doorbell").defaultsTo("", "no doorbell");
      hash_path = ["myCloud", "myDoorbell"];
    }
    always {// why do we put this in both profile and general ??? 
      set ent:profile{"myDoorbell"} doorbell;
      set ent:general{hash_path} doorbell;
    }
  }
// settings
  rule SDS_add_settings_schema {
    select when sds new_settings_schema
    pre {
      setName   = event:attr("Name").defaultsTo("unknown","no Name");
      setRID    = event:attr("RID").defaultsTo("unknown","no RID");
      setSchema = event:attr("Schema").defaultsTo([],"no Schema");
      setData   = event:attr("Data").defaultsTo({},"no Data");

      gotData = ent:settings{[setRID, "setData"]};

    }
    always {
      set ent:settings{[setRID, "Name"]}   setName;
      set ent:settings{[setRID, "RID"]}    setRID;
      set ent:settings{[setRID, "Schema"]} setSchema;
      set ent:settings{[setRID, "Data"]}   setData if not gotData;
    }
  }

  rule SDS_add_settings_data {
    select when sds new_settings_data
    pre {
      setRID    = event:attr("RID").defaultsTo("unknown","no RID");
      setData   = event:attr("Data").defaultsTo({},"no Data");
      hash_path = [setRID, "setData"];
    }
    always {
      set ent:settings{hash_path} setData;
    }
  }

  rule SDS_add_settings {
    select when sds new_settings_available
    pre {
      setRID    = event:attr("RID").defaultsTo("unknown","no RID");
      setData   = event:attr("Data").defaultsTo({},"no Data");
      hash_path     = [setRID, "setData"];
    }
    always {
      set ent:settings{hash_path} setData.delete(["setRID"]); // why not use clear????
    }
  }

  rule SDS_add_settings_attribute {
    select when sds new_settings_attribute
    pre {
      setRID    = event:attr("RID").defaultsTo("unknown","no RID");
      setAttr   = event:attr("setAttr").defaultsTo("unknown","no setAttr");
      setValue  = event:attr("Value").defaultsTo("unknown","no Value");
      hash_path = [setRID, "setData", setAttr];
    }
    always {
      set ent:settings{hash_path} setValue;
    }
  }

  rule SDS_application_uninstalled {
    select when explicit application_uninstalled
    pre{
      appid = event:attr("appid").defaultsTo("","no appid");
    }
    always {
      clear ent:settings{appid};
    }
  }

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
