#!/usr/bin/env rackup
require "rubygems"
gem 'waw', '>= +(Waw::VERSION)'
require "waw"
run Waw.autoload(__FILE__)
