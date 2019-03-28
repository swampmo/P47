# I believe this script to originally vome from Gerard Robin

var min_carrier_alt = 2;

# Do terrain modelling ourselves.
setprop("sim/fdm/surface/override-level", 1);

terrain_survol = func {

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");
var info = geodinfo(lat, lon);




 if (info != nil) {
    if (info[0] != nil){
       setprop("/environment/terrain-hight",info[0]);
#var terrain_hight = info[0];
#print("TERRAIN ",terrain_hight);
    }
    if (info[1] != nil){
      if (info[1].solid !=nil){
        setprop("/environment/terrain-undefined",0);
        setprop("/environment/terrain-solid",info[1].solid);
#var solid = info[1].solid;
#print("SOLID ",solid);

    }
      if (info[1].light_coverage !=nil)
       setprop("/environment/terrain-light-coverage",info[1].light_coverage);
      if (info[1].load_resistance !=nil)
       setprop("/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
       setprop("/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
       setprop("/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
       setprop("/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
       setprop("/environment/terrain-names",info[1].names[0]);

#unfortunately when on carrier the info[1]  is nil,  only info[0] is valid
#var terrain_name = info[1].names[0];
#print("NAME ",terrain_name);
      #if (terrain_name == "Ocean" and terrain_hight >  min_carrier_alt)
        #setprop("/environment/terrain-oncarrier",1);
    }else{
setprop("/environment/terrain-undefined",1);
}
	      #debug.dump(geodinfo(lat, lon));


  }else {
    setprop("/environment/terrain-hight",0);
    setprop("/environment/terrain-solid",1);
    setprop("/environment/terrain-oncarrier",0);
    setprop("/environment/terrain-light-coverage",1);
    setprop("/environment/terrain-load-resistance",1e+30);
    setprop("/environment/terrain-friction-factor",1);
    setprop("/environment/terrain-bumpiness",0);
    setprop("/environment/terrain-rolling-friction",0.02);
    setprop("/environment/terrain-names","unknown");
    }

settimer (terrain_survol, 0.1);
}

var window_lhb = screen.window.new(nil, -180, 2, 2000);

var fg = getprop("/sim/version/flightgear");    print ("FGVER ",fg);
var model_min = getprop("/sim/model/fg-ver_min");    print ("MODELmin ",model_min);
var model_max = getprop("/sim/model/fg-ver_max");    print ("MODELmax ",model_max);
var fgn1 = substr(fg,0,1);
var fgn3 = substr(fg,3,1);

#print ("FGN1     ",fgn1);
#print ("FGN3     ",fgn3);

if (fgn3  == ".") {
#print ("POINT");
var fgn2 = substr(fg,2,1);
var nfg = (fgn2/100)+fgn1;
#print ("FGVER ",nfg);
}
elsif (fgn3  != ".") {
#print ("NOTPOINT");
var fgn2 = substr(fg,2,2);
var nfg = (fgn2/100)+fgn1;
#print ("FGVER ",nfg);
}


#var diff_min = cmp(fg,model_min);    print ("DIFFSTRINGn ",diff_min);
#var diff_max = cmp(fg,model_max);    print ("DIFFSTRINGx ",diff_max);
#if (diff_min == -1 or diff_max == 1){

setprop("fdm/simulation/wrg-ver",0);
terrain_survol();

#if (nfg < model_min  or  nfg > model_max){
#setprop("fdm/simulation/wrg-ver",1);
#window_lhb.write("WRONG FLIGHTGEAR VERSION");
#window_lhb.write("YOU WANT AT LEAST FG VERSION IN THE RANGE : " "MIN "~ model_min ~" MAX "~model_max);
#}else{
#setprop("fdm/simulation/wrg-ver",0);
#terrain_survol();
#}

