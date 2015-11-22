# TTY::Prompt
[![Gem Version](https://badge.fury.io/rb/tty-prompt.svg)][gem]
[![Build Status](https://secure.travis-ci.org/peter-murach/tty-prompt.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/peter-murach/tty-prompt/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/peter-murach/tty-prompt/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/peter-murach/tty-prompt.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/tty-prompt
[travis]: http://travis-ci.org/peter-murach/tty-prompt
[codeclimate]: https://codeclimate.com/github/peter-murach/tty-prompt
[coverage]: https://coveralls.io/r/peter-murach/tty-prompt
[inchpages]: http://inch-ci.org/github/peter-murach/tty-prompt

> A beautiful and powerful interactive command line prompt.

**TTY::Prompt** provides independent prompt component for [TTY](https://github.com/peter-murach/tty) toolkit.

## Features

* A robust API for getting and validating complex inputs
* Number of coercion methods for converting response into Ruby types

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-prompt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-prompt

## Contents

* [1. Usage](#1-usage)
* [2. Interface](#2-interface)
  * [2.1 ask](#21-ask)
  * [2.2 select](#22-select)
  * [2.3 multi_select](#23-multi_select)
  * [2.4 read](#24-read)
  * [2.5 say](#25-say)
  * [2.6 suggest](#26-suggest)

## 1. Usage

In order to start asking questions on the command line, create prompt:

```ruby
prompt = TTY::Prompt.new
```

and then call `ask` with the question message:

```ruby
question = prompt.ask('Do you like Ruby?')
```

Finally, read and convert answer back to Ruby built-in type:

```ruby
answer = question.read_bool
```

## 2. Interface

### 2.1 ask

In order to ask a basic question and parse an answer do:

```ruby
answer = prompt.ask("What is your name?").read_string
```

The **TTY::Prompt** provides small DSL to help with parsing and asking precise questions

```ruby
argument   # :required or :optional
char       # turn character based input, otherwise line (default: false)
clean      # reset question
default    # default value used if none is provided
echo       # turn echo on and off (default: true)
mask       # mask characters i.e '****' (default: false)
modify     # apply answer modification :upcase, :downcase, :trim, :chomp etc..
in         # specify range '0-9', '0..9', '0...9' or negative '-1..-9'
validate   # regex against which stdin input is checked
valid      # a list of expected valid options
```

You can chain question methods or configure them inside a block:

```ruby
prompt.ask("What is your name?").argument(:required).default('Piotr').validate(/\w+\s\w+/).read_string

prompt.ask "What is your name?" do
  argument :required
  default  'Piotr'
  validate /\w+\s\w+/
  valid    ['Piotr', 'Piotrek']
  modify   :capitalize
end.read_string
```

### 2.2 select

For asking questions involving list of options use `select` method by passing the question and possible choices:

```ruby
prompt.select("Choose your destiny?", %w(Scorpion Kano Jax))
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

You can also provide options through DSL using the `choice` method for single entry and/or `choices` call for more than one choice:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.choice 'Scorpion'
  menu.choice 'Kano'
  menu.choice 'Jax'
end
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

By default the choice name is used as return value, but you can provide your custom values:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.choice 'Scorpion', 1
  menu.choice 'Kano', 2
  menu.choice 'Jax', 3
end
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
# ‣ Scorpion
#   Kano
#   Jax
```

If you wish you can also provide a simple hash to denote choice name and its value like so:

```ruby
choices = {'Scorpion' => 1, 'Kano' => 2, 'Jax' => 3}
prompt.select("Choose your destiny?", choices)
```

To mark particular answer as selected use `default` with index of the option starting from `1`:

```ruby
prompt.select("Choose your destiny?") do |menu|
  menu.default 3

  menu.choice 'Scorpion', 1
  menu.choice 'Kano', 2
  menu.choice 'Jax', 3
end
# =>
# Choose your destiny? (Use arrow keys, press Enter to select)
#   Scorpion
#   Kano
# ‣ Jax
```

You can configure help message, marker like so

```ruby
choices = %w(Scorpion Kano Jax)
prompt.select("Choose your destiny?", choices, help: "(Bash keyboard)")
# =>
# Choose your destiny? (Bash keyboard)
# ‣ Scorpion
#   Kano
#   Jax
```

### 2.3 multi_select

For asking questions involving multiple selection list use `multi_select` method by passing the question and possible choices:

```ruby
choices = %w(vodka beer wine whisky bourbon)
prompt.select("Select drinks?", choices)
# =>
#
# Select drinks? (Use arrow keys, press Space to select and Enter to finish)"
# ‣ ⬡ vodka
#   ⬡ beer
#   ⬡ wine
#   ⬡ whisky
#   ⬡ bourbon
```

As a return value, the `multi_select` will always return an array by default populated with the names of the choices. If you wish to return custom values for the available choices do:

```ruby
choices = {vodka: 1, beer: 2, wine: 3, whisky: 4, bourbon: 5}
prompt.select("Select drinks?", choices)

Given selection of vodka and beer the function will return

# => [1, 2]
```

Similar to `select` method, you can also provide options through DSL using the `choice` method for single entry and/or `choices` call for more than one choice:

```ruby
prompt.multi_select("Select drinks?") do |menu|
  menu.choice :vodka, {score: 1}
  menu.choice :beer, 2
  menu.choice :wine, 3
  menu.choices whisky: 4, bourbon: 5
end
```

### 2.4 read

To start reading the input from stdin simply call `read` method:

```ruby
prompt.read
```

However, there will be cases when your codebase expects answer to be of certain type. **TTY::Prompt** allows reading of answers and converting them into required types with custom readers:

```ruby
read_bool       # return true or false for strings such as "Yes", "No"
read_char       # return first character
read_date       # return date type
read_datetime   # return datetime type
read_email      # validate answer against email regex
read_file       # return a File object
read_float      # return decimal or error if cannot convert
read_int        # return integer or error if cannot convert
read_multiple   # return multiple line string
read_password   # return string with echo turned off
read_range      # return range type
read_regex      # return regex expression
read_string     # return string
read_symbol     # return symbol
read_text       # return multiline string
read_keypress   # return the key pressed
```

For example, if we wanted to ask a user for a single digit in given range

```ruby
ask("Provide number in range: 0-9").in('0-9') do
  on_error :retry
end.read_int
```

on the other hand, if we are interested in range answer then

```ruby
ask("Provide range of numbers?").read_range
```

### 2.5 say

To simply print message out to stdout use `say` like so:

```ruby
prompt.say(...)          # print message to stdout
```

**TTY::Prompt** provides more specific versions of `say` method to better express intenation behind the message:

```ruby
prompt.confirm      # print message(s) in green
prompt.warn         # print message(s) in yellow
prompt.error        # print message(s) in red
```

### 2.5 suggest

To suggest possible matches for the user input use `suggest` method like so:

```ruby
prompt.suggest('sta', ['stage', 'stash', 'commit', 'branch'])
# =>
Did you mean one of these?
        stage
        stash
```

To cusomize query text presented pass `:single_text` and `:plural_text` options to respectively change the message when one match is found or many.

```ruby
possible = %w(status stage stash commit branch blame)
prompt.suggest('b', possible, indent: 4, single_text: 'Perhaps you meant?')
# =>
Perhaps you meant?
    blame
```

## Contributing

1. Fork it ( https://github.com/peter-murach/tty-prompt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 Piotr Murach. See LICENSE for further details.
