# bignum-lua
Large number library that trades precision for simplicity. Number range is ±10^(2^53).

## Features
- Arithmetic operations: addition, subtraction, multiplication, division, exponentiation
- Additional operations: to-string, cloning, comparison, negation, inversion, absolute value
- Small (< 200 sloc)
- Portable (works in Lua 5.1+)

## How to use
First, `require` the library to load it, preferably into a local variable named `bignum`.

    local bignum = require "bignum"

To create a `bignum`, supply zero, one, or two numbers to `bignum.new`. The first number represents the significand, while the second represents the power of 10. Both default to 0 if absent.

    local x = bignum.new()     --> 0
    local y = bignum.new(123)  --> 123
    local z = bignum.new(4, 5) --> 400000

It is also possible to call `bignum` directly:

    local x = bignum()     --> 0
    local y = bignum(123)  --> 123
    local z = bignum(4, 5) --> 400000

For operations on `bignum`s, there are a few choices of syntax:

    local w = bignum.add(y, z)
    local w = y:add(z)
    local w = y + z

All of these will result in variable `w` having the value `400123`.

Please see the source code for other method names.

## Warnings
The following will result in the library having undefined behavior:

- Supplying invalid arguments to `bignum.new`
- Manually changing the value of items within a `bignum`
- Exceeding the number range

It is up to you to make sure that your code avoids these things.
