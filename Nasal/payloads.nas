input = {
  replay:           "sim/replay/replay-state",
  elapsed:          "sim/time/elapsed-sec",
  impact:			"/ai/models/model-impact",
};

  # setup property nodes for the loop
  foreach(var name; keys(input)) {
      input[name] = props.globals.getNode(input[name], 1);
  }

load_ammo = func{
    if(getprop("gear/gear/wow")){
        if(getprop("controls/gear/brake-parking")){
            setprop("ai/submodels/submodel[0]/count",425);
            setprop("ai/submodels/submodel[1]/count",425);
            setprop("ai/submodels/submodel[2]/count",425);
            setprop("ai/submodels/submodel[3]/count",425);
            setprop("ai/submodels/submodel[4]/count",425);
            setprop("ai/submodels/submodel[5]/count",425);
            setprop("ai/submodels/submodel[6]/count",425);
            setprop("ai/submodels/submodel[7]/count",425);
            setprop("ai/submodels/submodel[8]/count",1);
            setprop("ai/submodels/submodel[9]/count",1);
            setprop("ai/submodels/submodel[10]/count",1);
            setprop("ai/submodels/submodel[11]/count",1);
            setprop("ai/submodels/submodel[12]/count",1);
            setprop("ai/submodels/submodel[13]/count",1);
        }
    }
}

var hit_count = 0;
var hit_callsign = "";
var hit_timer = 0;
var closest_distance = 50;

setlistener("/ai/models/model-impact", func {
  var ballistic_name = input.impact.getValue();
  var ballistic = props.globals.getNode(ballistic_name, 0);
  var closest_distance = 10000;
  var inside_callsign = "";
  #print("inside listener");
  if (ballistic != nil and ballistic.getNode("name") != nil and ballistic.getNode("impact/type") != nil) {
    var typeNode = ballistic.getNode("impact/type");
    var typeOrd = ballistic.getNode("name").getValue();
    var lat = ballistic.getNode("impact/latitude-deg").getValue();
    var lon = ballistic.getNode("impact/longitude-deg").getValue();
    var impactPos = geo.Coord.new().set_latlon(lat, lon);
    if ((typeOrd == "R1-tracer" or
        typeOrd == "R2-tracer" or
        typeOrd == "R3-tracer" or
        typeOrd == "R4-tracer" or
        typeOrd == "L5-tracer" or
        typeOrd == "L6-tracer" or
        typeOrd == "L7-tracer" or
        typeOrd == "L8-tracer" )
        and typeNode.getValue() != "terrain") {
      closest_distance = 35;
      foreach(var mp; props.globals.getNode("/ai/models").getChildren("multiplayer")){
        #print("Gau impact - hit: " ~ typeNode.getValue());
        var mlat = mp.getNode("position/latitude-deg").getValue();
        var mlon = mp.getNode("position/longitude-deg").getValue();
        var malt = mp.getNode("position/altitude-ft").getValue() * FT2M;
        var selectionPos = geo.Coord.new().set_latlon(mlat, mlon, malt);
        var distance = impactPos.distance_to(selectionPos);
        #print("distance = " ~ distance);
        if (distance < closest_distance) {
          closest_distance = distance;
          inside_callsign = mp.getNode("callsign").getValue();
        }
      }

      if ( inside_callsign != "" ) {
        #we have a successful hit
        if ( inside_callsign == hit_callsign ) {
          hit_count = hit_count + 1;
          #print("hit_count: " ~ hit_count);
        } else {
          hit_callsign = inside_callsign;
          hit_count = 1;
        }
        if ( hit_timer == 0 ) {
          hit_timer = 1;
          settimer(func{hitmessage("50 BMG");},1);
        }
      }
    }elsif ( typeOrd == "Rocket1" or
              typeOrd == "Rocket2" or
              typeOrd == "Rocket3" or
              typeOrd == "Rocket4" or
              typeOrd == "Rocket5" or
              typeOrd == "Rocket6" )  {
      foreach(var mp; props.globals.getNode("/ai/models").getChildren("multiplayer")){
        var mlat = mp.getNode("position/latitude-deg").getValue();
        var mlon = mp.getNode("position/longitude-deg").getValue();
        var malt = mp.getNode("position/altitude-ft").getValue() * FT2M;
        var selectionPos = geo.Coord.new().set_latlon(mlat, mlon, malt);
        var distance = impactPos.distance_to(selectionPos);
        # change the below value to the max hit message distance in meters
        if (distance < 10) {
          defeatSpamFilter(sprintf( typeOrd~" exploded: %01.1f", distance) ~ " meters from: " ~ mp.getNode("callsign").getValue());
        }
      }
    }
  }
});

var hitmessage = func(typeOrd) {
  #print("inside hitmessage");
  message = typeOrd ~ " hit: " ~ hit_callsign ~ ": " ~ hit_count ~ " hits";
  defeatSpamFilter(message);
  hit_callsign = "";
  hit_timer = 0;
  hit_count = 0;
}

var spams = 0;
var spamList = [];

var defeatSpamFilter = func (str) {
  spams += 1;
  if (spams == 15) {
    spams = 1;
  }
  str = str~":";
  for (var i = 1; i <= spams; i+=1) {
    str = str~".";
  }
  var newList = [str];
  for (var i = 0; i < size(spamList); i += 1) {
    append(newList, spamList[i]);
  }
  spamList = newList;  
}

var spamLoop = func {
  var spam = pop(spamList);
  if (spam != nil) {
    setprop("/sim/multiplay/chat", spam);
  }
  settimer(spamLoop, 1.20);
}

spamLoop();
