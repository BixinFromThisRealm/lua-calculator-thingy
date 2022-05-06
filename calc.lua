--[[

TODO:

+ Refactor a bit of the C.L. argument code.
  (Actually, the C.L. argument code is alright, for now at least)
  (No wait it's terrible, but at least now i fixed it.)

- Implement unary operations.

- Implement functions with varying and optional parameters,
  the goal being to make an alias for every function in the lua math library.

- Maybe after implementing functions make a .help-about meta-command.
]]

io.output():setvbuf 'no'


meta_commands = {}

function meta_commands.help()
    print([[

    Description:

    A simple text calculator with a full parser using 
    the Shunting-Yard Algorithm and RPN. It supports simple
    binary operations (-, +, *, /, %), full precedence, the
    constant pi (as PI, or pi) and parentheses. This calculator
    does not support functions of any kind or unary operators.
    
    When executed with an argument (such as "lua calc.lua '70 - 5'"),
    it will try to compute it as a mathematical expression and
    then terminate.

    operators:

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


--> Creates a parse tree (in this case, a table) from a mathematical expression.
--> Based on https://en.wikipedia.org/wiki/Shunting_yard_algorithm
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


--> Semantic parsing of the table genereated by parseIt(),
--> this is where the actual interpretation and calculation happens.
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
        end
        -- print(table.concat(stack, ', '))
    end

    if not (#stack <= 1) then
        print('too few operators')
        return
    end

    return stack[1]
end



if (arg[1] ~= nil) then
    print(analyzeIt(parseIt(arg[1])))
    os.exit()
end


print('Lua Calculator Thingy\ntype ".help" for more info:\n')

--> Main loop
while true do
    io.write('>> ')
    local input = io.read()

    local cmd = input:match('%.[%a%-]+')

    if cmd then
        cmd = cmd:sub(2)
        meta_commands[ cmd ]()
    else
        print(analyzeIt(parseIt(input)))
    end
end

