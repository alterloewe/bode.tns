platform.apilevel = '2.0'     
function on.paint(gc)
    gc:setFont("sansserif", "r", 6)
    local h = platform.window:height()
    local w = platform.window:width()
    local offsetleft = 25
    local offsetbottom = 15
    
    --CHECK INPUT VARIABLES
    if(var.recall("xend")<=var.recall("xstart")) then
         gc:drawString("ERROR: xend has to be larger than xstart", 10, 20)
         return
    end
    
    if(var.recall("yend")<var.recall("ystart")) then
         gc:drawString("ERROR: ystart has to be smaller than yend", 10, 30)
         return
    end
    
    
    if(not(var.recall("xstart")>0)) then
         gc:drawString("ERROR: xstart has to be positive (greater than 0)", 10, 40)
         return
    end
    
    --CALC CURVE VALUES----------------------------------
    local plotstart = math.eval("approx(log(xstart,10))")
    local plotend = math.eval("approx(log(xend,10))")
    local step = var.recall("step")
    local stepquant = math.ceil((plotend-plotstart)/step)
    
    local curve = {}
	local i_min=0
	local i_max=0
	local r_min=0
	local r_max=0
    for i=0, stepquant, 1 do
       local i_value = math.eval("imag(h(10^("..plotstart+step*i..")))")
       local r_value = math.eval("real(h(10^("..plotstart+step*i..")))")
       if(i_value < i_min) then i_min=i_value end
       if(r_value < r_min) then r_min=r_value end
       if(i_value > i_max) then i_max=i_value end
       if(r_value > r_max) then r_max=r_value end
       curve[2*i+1] = r_value;
       curve[2*i+2] = i_value;
    end
    i_min=math.floor(i_min);
    i_max=math.ceil(i_max);
    i_max=math.max(i_max, math.abs(i_min*0.1));
    i_min = i_min*1.1;
    r_min=math.floor(r_min);
    r_max=math.ceil(r_max);
    r_min=math.min(r_min, -math.abs(r_max*0.1));
    r_max = r_max*1.1;

    local x_perstep = (w-offsetleft)/(r_max-r_min)
    local y_perstep = (h-offsetbottom)/(i_max-i_min)
    local pixelperstep = math.min(x_perstep, y_perstep);
    --i_min=math.floor(i_min*y_perstep/pixelperstep);
    --i_max=math.ceil(i_max*y_perstep/pixelperstep);

    gc:setColorRGB(0x808080);
    --VERTICAL LINES PROCESSING--------------------------
    local x_zerooffset = 0
    x_zerooffset = math.abs(r_min) * pixelperstep;
   
    --local nodes = math.ceil(r_max-r_min);
    local nodes = math.floor(r_max-r_min);
    local i_nodes = 0;
    if(nodes < 5) then i_nodes = 1; end
    if(nodes < 3) then i_nodes = 4; end
    if(nodes < 2) then i_nodes = 9; end
    for i = math.ceil(r_min), math.floor(r_max), 1 do
        gc:setPen("thin", "dashed")
        gc:drawLine((offsetleft+x_zerooffset+i*pixelperstep), 0, (offsetleft+x_zerooffset+i*pixelperstep), h-offsetbottom)
        gc:drawString(i, (offsetleft+x_zerooffset+i*pixelperstep)-3, h-2, "bottom")
        gc:setPen("thin", "dotted")
        for j = 1, i_nodes, 1 do
            gc:drawLine((offsetleft+x_zerooffset+i*pixelperstep+j*pixelperstep/(i_nodes+1)), 0, (offsetleft+x_zerooffset+i*pixelperstep+j*pixelperstep/(i_nodes+1)), h-offsetbottom)
        end
    end

    --HORIZONTAL GAIN LINES PROCESSING---------------------
    local y_zerooffset = 0
    y_zerooffset = i_max * pixelperstep;

    local nodes2 = math.ceil(i_max-i_min)
    local a = math.ceil(i_min);
    local b = math.floor(i_max);
    for i = a, b, 1 do --draw horizintal lines
        gc:setPen("thin", "dashed")
        gc:drawLine(offsetleft, (y_zerooffset-i*pixelperstep), w, (y_zerooffset-i*pixelperstep)) 
        gc:drawString(i, 2, (y_zerooffset-i*pixelperstep)+2)
        gc:setPen("thin", "dotted")
        for j = 1, i_nodes, 1 do
            gc:drawLine(offsetleft, (y_zerooffset-i*pixelperstep-j*pixelperstep/(i_nodes+1)), w, (y_zerooffset-i*pixelperstep-j*pixelperstep/(i_nodes+1))) 
        end
    end
       
    --PLOT GAIN--------------------------------------------
    
    gc:setColorRGB(0x404040);
    gc:setPen("thin", "smooth")
    local linepoints = {}
    for i=0, stepquant, 1 do
    local x = curve[2*i+1];
    local x1 = ((curve[2*i+1]*pixelperstep)+x_zerooffset)+offsetleft;
    local y = curve[2*i+2];
    local y1 = (y_zerooffset-(curve[2*i+2]*pixelperstep));
       linepoints[2*i+1] = ((curve[2*i+1]*pixelperstep)+x_zerooffset)+offsetleft;
       linepoints[2*i+2] = (y_zerooffset-(curve[2*i+2]*pixelperstep));
    end
    gc:drawPolyLine(linepoints)
end

--------------------------------------------------------------------------------------------------------
function on.activate()
    platform.window:invalidate()
end

---------------------------------------------------------------------------------------------------------

function on.arrowLeft()
   var.store("xstart", var.recall("xstart")/10)
   var.store("xend", var.recall("xend")/10)
   platform.window:invalidate()
end

function on.arrowRight()
   var.store("xstart", var.recall("xstart")*10)
   var.store("xend", var.recall("xend")*10)
   platform.window:invalidate()
end


function on.charIn(ch)
    if(ch == "*") then
       var.store("xend", var.recall("xend")/10)
       platform.window:invalidate()
    end
    
    if(ch == "/") then
       var.store("xend", var.recall("xend")*10)
       platform.window:invalidate()
    end
end 

