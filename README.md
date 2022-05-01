# Lua Calculator Thingy

A (definitely very original) CLI text calculator written entirely in Lua, complete with binary operations ➗, parenthesis (), the constant pi ⭕, and meta-commands 😱❗❗💯


## Getting Started

It's really simple actually, just download the repo and execute it with Lua (`lua calc.lua`), it's not that hard... unless you don't have Lua on your computer 🤔.

## Usage

The calculator works in a REPL sort of fashion, where you type an expression and it returns a result, something like this:

```
$ lua calc.lua
Lua Calculator Thingy
type ".help" for more info:

>> 50 - 8
42
>> (20-5) * 4
60
>> .exit
```

but if you just wanna use it in a execute-command-line-argument-and-then-terminate type of way, you can definitely do it with something like this `lua calc.lua "50-8"`.

### Meta-Commands

Since the calculator works in this REPL way, we obviously need a way of exiting it, as well as providing ways to clear the terminal and other stuff. So, to fix this, i put in the calculator something i like to call **meta-commands**, it has nothing to do with that database stuff, i just find the name fitting and kinda cool.

To use a meta-command you first type the `.` escape character, and then type the command you wish. Right now there are only three available meta-commands:

`.help`, which prints a help message with details about the calculator.

`.cls`, which clears the terminal.

`.exit`, which exits the program.
