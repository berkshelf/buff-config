# Buff::Config
[![Gem Version](https://badge.fury.io/rb/buff-config.png)](http://badge.fury.io/rb/buff-config)
[![Build Status](https://travis-ci.org/RiotGames/buff-config.png?branch=master)](https://travis-ci.org/RiotGames/buff-config)

A simple configuration class

## Installation

Add this line to your application's Gemfile:

    gem 'buff-config'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install buff-config

## Usage

    require 'buff/config/json'

    class MyConfig < Buff::Config::JSON
      attribute 'chef.chef_server_url'
    end

    my_config = MyConfig.new
    my_config.chef.chef_server_url #=> nil

# Authors and Contributors

* Jamie Winsor (<jamie@vialstudios.com>)
* Kyle Allan (<kallan@riotgames.com>)

Thank you to all of our [Contributors](https://github.com/RiotGames/buff-config/graphs/contributors), testers, and users.
