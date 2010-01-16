#
# This file is extracted from the CRUC library (http://code.chefbe.net)
# which is distributed under the licence below. Please keep this header
# when using this class. Send an email to blambeau at gmail dot com if
# you need special usage rights.
#
# The MIT License
# Copyright (c) 2009 Bernard Lambeau and the University of Louvain 
# (Universite Catholique de Louvain, Louvain-la-Neuve, Belgium)
# 

#
# Provides a simple but powerful way to create non intrusive DSLs.
# Typical use cases are described below.
#
# === Punctual DSL usage
# A given user block uses your DSL punctually. As the later installs 
# potentially intrusive methods in some Ruby core classes, you would
# like your DSL to be installed, user block executed and Ruby methods
# restored immediately after.
#
#    DSLHelper.new(String => [:upcase], Symbol => [:/, :&, :|]) do
#      load 'mydsl.rb'           # install your DSL first 
#      yield if block_given?     # yield user block
#    end
#
# After the DSLHelper new invocation, all Ruby methods are correctly 
# restored. 
#
# === Middle-case DSL usage
# Your DSL must be installed punctually but you cannot encapsulate its
# usage in a single DSLHelper.new invocation. Calling save and restore 
# methods is the alternative. However, their invocation MUST respect 
# (save restore)* invocation regexp otherwise a RuntimeError is raised.
#
#   helper = DSLHelper.new(String => [:upcase], Symbol => [:/, :&, :|])
#   helper.save      # save Ruby methods that you plan to override
#   load 'mydsl.rb'  # install your DSL 
#   [...]            # do anything you want, here of somewhere
#   helper.restore   # restore Ruby methods when finished
#
# === Long-term DSL usage
# Your DSL (or more generically, ruby extensions you've written) is used during 
# the whole execution of the program. You hope that it is not intrusive (you only 
# add methods that doesn't already exist to some Ruby classes). You would like to 
# check this hypothesis (because Ruby evolves, your code may be used in conjunction 
# with third party libraries that install their own methods, etc.)
#
#   if DSLHelper.is_intrusive?(String => [:upcase], Symbol => [:/, :&, :|])
#     STDERR << "WARNING: this library seems to override Ruby existing methods"
#   end
#   load 'ruby_extensions.rb'
#
class DSLHelper
  
  # Creates a DSLHelper instance. _hash_ must be a Hash instance
  # mapping modules to array of symbols. If a block is given, the
  # Ruby state is immediately saved, block is yield and state is
  # restored after that.
  def initialize(hash)
    @definition = hash
    @saved = nil
    if block_given?
      save
      yield
      restore
    end
  end

  # Checks if a set of methods that your DSL is planning to install
  # makes it an intrusive DSL (overriding existing Ruby or third
  # party methods)
  def self.is_intrusive?(hash)
    hash.each_pair do |mod, methods|
      methods.each do |method|
        return true if mod.method_defined?(method)
      end
    end
    false
  end
  
  # Finds a method inside a Module, or returns nil.
  def self.find_instance_method(mod, method)
    mod.instance_method(method)
  rescue NameError
    nil
  end

  # Saves all methods of the definition hash in an internal data
  # structure. This method raises an error is a save is already
  # pending.
  def save
    raise "save already pending" unless @saved.nil?
    @saved = {}
    @definition.each_pair do |mod, methods|
      @saved[mod] = methods.collect {|m| DSLHelper.find_instance_method(mod,m)}
    end
  end
  
  # Restores all methods previously saved. This method raises an
  # error if no save call has been made before.
  def restore
    raise "save has not been called previously." if @saved.nil?
    @definition.each_pair do |mod, methods|
      methods.zip(@saved[mod]).each do |name, saved|
        if saved.nil?
          mod.send(:remove_method, name) if mod.method_defined?(name)
        elsif
          mod.send(:define_method, name, saved)
        end
      end
    end
    @saved = nil
  end

end
