local bignum = {}

setmetatable(bignum, {__call = function(_, ...) return bignum.new(...) end})

local mt = {
    __add = function(num1, num2)
        return num1:add(num2)
    end,
    __sub = function(num1, num2)
        return num1:subtract(num2)
    end,
    __mul = function(num1, num2)
        return num1:multiply(num2)
    end,
    __div = function(num1, num2)
        return num1:divide(num2)
    end,
    __pow = function(num, exp)
        return num:pow(exp)
    end,
    __unm = function(num)
        return num:negate()
    end,
    __eq = function(num1, num2)
        return num1:compare(num2) == 0
    end,
    __lt = function(num1, num2)
        return num1:compare(num2) < 0
    end,
    __le = function(num1, num2)
        return num1:compare(num2) <= 0
    end,
    __tostring = function(num)
        return num:tostring()
    end,
    __index = bignum
}

local function normalize(significand, exponent)
    while math.abs(significand) >= 10 do
        significand = significand / 10
        exponent = exponent + 1
    end
    while significand ~= 0 and math.abs(significand) < 1 do
        significand = significand * 10
        exponent = exponent - 1
    end
    return significand, exponent
end

function bignum.new(significand, exponent)
    if not significand then
        significand = 0
    end
    if significand == 0 or not exponent then
        exponent = 0
    end
    significand, exponent = normalize(significand, exponent)
    return setmetatable({
        significand = significand,
        exponent = exponent
    }, mt)
end

function bignum.tostring(num)
    if num.exponent < 14 and num.exponent > -5 then
        return tostring(num.significand * 10 ^ num.exponent)
    end
    return num.significand .. "e" .. ("%d"):format(num.exponent)
end

function bignum.clone(num)
    return bignum.new(num.significand, num.exponent)
end

function bignum.multiply(num1, num2)
    return bignum.new(
        num1.significand * num2.significand,
        num1.exponent + num2.exponent
    )
end

function bignum.divide(num1, num2)
    return bignum.new(
        num1.significand / num2.significand,
        num1.exponent - num2.exponent
    )
end

local function sign(num)
    if num > 0 then
        return 1
    elseif num < 0 then
        return -1
    end
    return 0
end

function bignum.compare(num1, num2)
    if sign(num1.significand) > sign(num2.significand) then
        return 1
    elseif sign(num1.significand) < sign(num2.significand) then
        return -1
    elseif num1.exponent > num2.exponent then
        return 1
    elseif num1.exponent < num2.exponent then
        return -1
    elseif num1.significand > num2.significand then
        return 1
    elseif num1.significand < num2.significand then
        return -1
    end
    return 0
end

function bignum.add(num1, num2)
    if num1 < num2 then
        num1, num2 = num2, num1
    end
    -- if the smaller number is way smaller than the larger number,
    -- do nothing
    if num1.significand - num2.significand >= 20 then
        return bignum.new(num1.significand, num1.exponent)
    end
    
    local significand, exponent = num2.significand, num2.exponent
    while num1.exponent ~= exponent do
        significand = significand / 10
        exponent = exponent + 1
    end
    return bignum.new(num1.significand + significand, exponent)
end

function bignum.subtract(num1, num2)
    return bignum.add(num1, -num2)
end

function bignum.negate(num)
    return bignum.new(-num.significand, num.exponent)
end

function bignum.abs(num)
    return bignum.new(math.abs(num.significand), num.exponent)
end

function bignum.inverse(num)
    return bignum.divide(bignum.new(1), num)
end

function bignum.pow(num, exp)
    if exp == 0 then
        return bignum.new(1)
    elseif bignum.compare(bignum.new(0), num) == 0 then
        return bignum.new(0)
    elseif exp < 0 then
        return bignum.pow(bignum.inverse(num), -exp)
    else
        -- exponent represents num's exponent
        -- exp represents the argument to pow
        local significand = num.significand
        local exponent = num.exponent
        while exp >= 2 do
            significand, exponent = normalize(significand ^ 2, exponent * 2)
            exp = exp / 2
        end
        while exp < 1 do
            significand, exponent = normalize(significand ^ 0.5, exponent * 0.5)
            exp = exp * 2
        end
        significand = significand ^ exp
        exponent = exponent * exp

        -- coerce exponent to an integer
        local decimal_part = exponent - math.floor(exponent)
        significand = significand * 10 ^ decimal_part
        exponent = exponent - decimal_part
        return bignum.new(significand, exponent)
    end
end

return bignum
