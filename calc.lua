--[[
    Description:
    
    Simple text calculator with a full parser using the
    Shunting-Yard Algorithm and RPN. Supports simple
    binary operations (-, +, *, /, %), full precedence, the
    constant pi (as PI, or pi) and parentheses. This calculator
    does not support functions of any kind or unary operators.
    
    operations:
	
    - --> subtraction operator     ( 10 -  3  =  7   )
    + --> addition operator        ( 10 +  3  = 13   )
    * --> multiplication operator  ( 10 *  3  = 30   )
    / --> division operator        ( 10 /  3  = 3.33 )
    % --> modulo operator          ( 10 %  3  =  1   )
	
    meta-commands:
        
    '.exit'        --> Breaks the main loop, terminating the application.
    '.cls'         --> Clears the terminal.
    '.help', '.h'  --> Prints this message.


    BSD 2-Clause License

    Copyright (c) 2022, BixinFromThisRealm
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS'
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


io.output():setvbuf 'no'


meta_commands = {}

function meta_commands.help()
    print([[

    Description:

    Simple text calculator with a full parser using the
    Shunting-Yard Algorithm and RPN. Supports simple
    binary operations (-, +, *, /, %), full precedence, the
    constant pi (as PI, or pi) and parentheses. This calculator
    does not support functions of any kind or unary operators.

    operations:

    - --> subtraction operator     ( 10 -  3  =  7   )
    + --> addition operator        ( 10 +  3  = 13   )
    * --> multiplication operator  ( 10 *  3  = 30   )
    / --> division operator        ( 10 /  3  = 3.33 )
    % --> modulo operator          ( 10 %  3  =  1   )

    meta-commands:
        
    ".exit"        --> Breaks the main loop, terminating the application.
    ".cls"         --> Clears the terminal.
    ".help", ".h"  --> Prints this message.
]])
end

meta_commands.h = meta_commands.help


function meta_commands.exit() os.exit() end


function meta_commands.cls()
    if package.config:sub(1, 1) == '\\' then --> Windows
        os.execute('cls')
    else --> Unix-like (basically every other OS)
        os.execute('clear')
    end
end


setmetatable(meta_commands, {
    __index = function(table, key)
        return function()
            print('"'..key..'" isn\'t a valid meta-command, try something else.\n')
        end
    end
})


--> { precedence, is left-associate}
OP = {
    ['^'] = {prec = 2, leftAssoc = false},
    ['/'] = {prec = 1, leftAssoc = true},
    ['%'] = {prec = 1, leftAssoc = true},
    ['*'] = {prec = 1, leftAssoc = true},
    ['+'] = {prec = 0, leftAssoc = true},
    ['-'] = {prec = 0, leftAssoc = true}
}



--> Based on the Shunting-yard algorithm
function parseIt(exp)
    exp = string.gsub(exp, '[%(%)%-%+%*/%%]', '  %0  ') --> ensure tokens are separated by spaces

    local tokens = {}

    --> split string by spaces
    for str in exp:gmatch('([^%s]+)') do
        table.insert(tokens, str)
    end

    local output = {}
    local opStack = {}

    for i, v in ipairs(tokens) do
        if v:match('%d+') or v:upper() == 'PI' then
            table.insert(output, tostring(v))
        elseif v:match('[%-%+%*%%/%^]') then
            local o2 = opStack[#opStack]

            while o2 ~= nil and
                (o2 ~= '(' and (OP[o2].prec > OP[v].prec or (OP[o2].prec == OP[v].prec and OP[v].leftAssoc))) do
                table.insert(output, table.remove(opStack))
                o2 = opStack[#opStack]
            end

            table.insert(opStack, v)
        elseif v == '(' then
            table.insert(opStack, v)
        elseif v == ')' then
            while opStack[#opStack] ~= '(' do
                if not (#opStack > 0) then
                    print('mismatched parentheses')
                    return
                end
                table.insert(output, table.remove(opStack))
            end

            if not (opStack[#opStack] == '(') then
                print('right parentheses without corresponding "("')
                return
            end
			
            table.remove(opStack)
        end
    end

    --> After the while loop, pop the remaining items from the operator stack into the output queue.
    while #opStack > 0 do
        if not (opStack[#opStack] ~= '(') then
            print('mismatched parentheses')
            return
        end
        table.insert(output, table.remove(opStack))
    end

    -- print(table.concat(output, ', '))

    return output
end


--> Based on https://rosettacode.org/wiki/Parsing/RPN_calculator_algorithm#JavaScript
function analyzeIt(tokens)
    if tokens == nil then return end

    local stack = {}

    for i, v in ipairs(tokens) do
        if v:match('%d+') then
            table.insert(stack, tonumber(v))
        elseif v:upper() == 'PI' then
            table.insert(stack, math.pi)
        else
            if not (#stack >= 2) then
                print('too few operands')
                return
            end

            local n2 = table.remove(stack)
            local n1 = table.remove(stack)

            if v == '+' then
                table.insert(stack, n1 + n2)
            elseif v == '-' then
                table.insert(stack, n1 - n2)
            elseif v == '*' then
                table.insert(stack, n1 * n2)
            elseif v == '%' then
                table.insert(stack, n1 % n2)
            elseif v == '/' then
                table.insert(stack, n1 / n2)
            elseif v == '^' then
                table.insert(stack, n1 ^ n2)
            else
                print('can\'t understand "' .. v .. '" operator.')
                return
            end
            -- print(table.concat(stack, ', '))
        end
    end

    if not (#stack <= 1) then
        print('too few operators')
        return
    end

    return stack[1]
end



print('Simple Text Calculator\ntype ".help" for more info:\n')

--> Main loop
while true do
    print(analyzeIt(parseIt('(20-5)*4')))
    os.exit()
    io.write('>> ')
    local input = io.read()

    local cmd = input:match('%.%a+')

    if cmd then
        cmd = cmd:sub(2)
        meta_commands[ cmd ]()
    else
        -- print(analyzeIt(parseIt(input)))
    end
end
