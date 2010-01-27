#!/usr/bin/env rackup
require "rubygems"
gem 'waw', ">= 0.2.0"
require "waw"
run Waw.autoload(__FILE__)
