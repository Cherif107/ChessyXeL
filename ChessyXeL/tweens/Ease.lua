---@class tweens.Ease Contains a list of Eases
local Eases = {}
Eases = {
    PI2 = math.pi / 2,
    EL = 2 * math.pi / 0.45,
	B1 = 1 / 2.75,
	B2 = 2 / 2.75,
	B3 = 1.5 / 2.75,
	B4 = 2.5 / 2.75,
	B5 = 2.25 / 2.75,
	B6 = 2.625 / 2.75,
    E_A = 1,
    E_P = 0.4,

    linear = function(v) return v end,
    
    backIn = function(v) return v^2*(2.70158*v-1.70158) end,
    backOut = function(v) return 1-(v-1)*v*(-2.70158*v-1.70158) end,
    backInOut = function(v)
        v = v*2;
		if (v < 1) then
			return v^2*(2.70158*v-1.70158)/2;
        end
		v = v-1
		return (1-(v-1)*(v)*(-2.70158*v-1.70158))/2+0.5;
    end,

    bounceIn = function(v)
        v = 1 - v
		if (v < Eases.B1) then
			return 1 - 7.5625 * v * v
        end
		if (v < Eases.B2) then
			return 1 - (7.5625 * (v - Eases.B3) * (v - Eases.B3) + 0.75);
        end
		if (v < Eases.B4) then
			return 1 - (7.5625 * (v - Eases.B5) * (v - Eases.B5) + 0.9375);
        end
		return 1 - (7.5625 * (v - Eases.B6) * (v - Eases.B6) + 0.984375);
    end,
    bounceOut = function(v) return 1-Eases.bounceIn(1-v) end,
    bounceInOut = function(v)
        if v < 0.5 then
            return Eases.bounceIn(v*2)/2
        end
        return Eases.bounceOut(v*2-1)/2+0.5
    end,

    circIn = function(v) return -((1-v^2)^0.5-1) end,
    circOut = function(v) return (1-(v-1)^2)^0.5 end,
    circInOut = function(v) return v <= 0.5 and ((1-v* v* 4)^0.5 - 1) / -2 or ((1-(v * 2 - 2)^2)^0.5+1) / 2 end,

    elasticIn = function(v)
        v = v-1
        return -(Eases.E_A * math.pow(2, 10 * v) * math.sin((v - (Eases.E_P / (2 * math.pi) * math.asin(1 / Eases.E_A))) * (2 * math.pi) / Eases.E_P));
    end,
    elasticOut = function(v) return (Eases.E_A * math.pow(2, -10 * v) * math.sin((v - (Eases.E_P / (2 * math.pi) * math.asin(1 / Eases.E_A))) * (2 * math.pi) / Eases.E_P) + 1); end,
    elasticInOut = function(v)
        if (v < 0.5) then
            v = v-0.5
			return -0.5 * (math.pow(2, 10 * v) * math.sin((v - (Eases.E_P / 4)) * (2 * math.pi) / Eases.E_P));
		end
        v = v-0.5
		return math.pow(2, -10 * v) * math.sin((v - (Eases.E_P / 4)) * (2 * math.pi) / Eases.E_P) * 0.5 + 1;
    end,

    expoIn = function(v) return 2^(10*(v-1)) end,
    expoOut = function(v) return -(2^(-10*v))+1 end,
    expoInOut = function(v) return v < 0.5 and math.pow(2, 10 * (v* 2 - 1)) / 2 or (-math.pow(2, -10 * (v * 2 - 1)) + 2) / 2 end,

    smoothStepIn = function(v) return 2 * Eases.smoothStepInOut(v/2) end,
    smoothStepOut = function(v) return 2 * Eases.smoothStepInOut(v/2+0.5)-1 end,
    smoothStepInOut = function(v) return (v^2)*(v*-2+3) end,

    smootherStepIn = function(v) return 2 * Eases.smootherStepInOut(v/2) end,
    smootherStepOut = function(v) return 2 * Eases.smootherStepInOut(v/2+0.5)-1 end,
    smootherStepInOut = function(v) return (v^3)*(v*(v*6-15)+10) end,

    sineIn = function(v) return -math.cos(Eases.PI2 * v)+1 end,
    sineOut = function(v) return math.sin(Eases.PI2 * v) end,
    sineInOut = function(v) return -math.cos(math.pi*v)/2+0.5 end,

    quadIn = function(v) return v^2 end,
    quadOut = function(v) return -v * (v - 2) end,
    quadInOut = function(v) return v <= 0.5 and (v^2) * 2 or (v-1)*v*2 end,

    quartIn = function(v) return v^4 end,
    quartOut = function(v) v = v-1 return 1 - v*(v^3) end,
    quartInOut = function(v) return v <= 0.5 and (v^4) * 8 or (1-(v*2-2)*(v^3))/2 + 0.5 end,

    quintIn = function(v) return v^5 end,
    quintOut = function(v) return (v-1)*(v^4)+1 end,
    quintInOut = function(v) return v < 0.5 and 16*v^5 or 1-(-2 * v + 2)^5/2 end,

    cubeIn = function(v) return v^3 end,
    cubeOut = function(v) return 1+(v-1)*(v^2) end,
    cubeInOut = function(v) return v <= 0.5 and (v^3)*4 or 1+(v-1)*(v^2)*4 end,

    testIn = function(v)
        v = v-1
        return -(Eases.E_A * math.pow(2, 10 * v) * math.cos(Eases.E_P * v));
    end,
}

return Eases