# Version 0.3.1

* Major enhancements

  * Added &, | and negate on wawaccess's Matchers
  * Fixed #447: user-friendly message when params is forgotten in action method signature
  * Cleaned the gemspec to include official dependencies

* On the devel side

  * Bumped to ruby.noe 1.3.0
  * Spec tests moved under spec/ instead of test/spec
  * Removed the vendor library, as all dependencies are official gems

# Version 0.3.0

* Added a Matcher class in StaticController, and matcher dsl rule in .wawaccess
* Modified some WawAccess API (env is passed instead of path at different places)
* Kernel application has been extended to support internal requests
* A DateTimeValidator has been added to the validation framework
* Waw::ActionController::JSGeneration becomes a controller. This allows setting
  configuration variable 'code_at_startup' to false (no code generated as a file
  at all) and including generated javascript as follows:

    waw.routing
        map '/webservices.js' do
          run ::Waw::ActionController::JSGeneration.new
        end
      
    layout.wtpl
  		  <script type="text/javascript" src="/webservices.js"></script>
  		  
* Set Rack version to 1.2.1
* Fixed a bug with waw-profile when encountering relative links.
* Moved to rspec 2.4.0

# Version 0.2.1

* Layouts have been cleaned. The empty layout is less complete than before
* Layouts force the waw version that is loaded by config.ru to a version greater
  than the one that created the layout. 
* Bug/Feature #260 related to inclusion of ::Waw::Validation has been implemented
* Bug/Feature #261 related to self referencing resource files has been implemented.
* Features #305 and #306 related to default validators and validators taking blocks
  have been implemented.

# Version 0.2.0

## Broken features and APIs (by order of importance)

* Major changes due to wlang version 0.9.0 (see Changelog there). Waw 0.2.0 verifies
  that a wlang gem >= 0.9.0 is installed in rubygems.
* The 'using self' syntax is deprecated in .wtpl files. Equivalence can be obtained 
  trough 'share all' (see also auto-waw-scoping later)

## New features

* All methods in Waw::ScopeUtils are automatically present in all wlang scopes as 
  low priority variables (aka auto-waw-scoping)
* wlang executable ensures that it executes the current version
* 'waw create' applies WLang::encode(upper_name, 'ruby/method-case') for computing 
  the lower project name.

## Bugfixes

* bug #290: Rack >= 1.1.0 is verified through rubygems
* feature #259: CSS and JS files are sorted by names when put in css_files and js_files wlang 
  variables

# Version 0.1.3

## Broken features and APIs (by order of importance)

* wawspec become wspec, all old invocations and assertions have been removed
* 'scenario' and 'because' in wspec are considered deprecated (but can still be used).
  They are replaced by 'requirement' and 'therefore'

## New features

* A mail agent has been added in tools. It expects a smtp_config variable in Waw.config.
  This agent really send mails in 'production' and 'acceptation' deployment modes. In
  'devel' and 'test' modes, it simply put mails in internal mailboxes accessible through
  accessors (see ::Waw::Tools::MailAgent)
* validation architecture has been consolidated and is well tested
* wawaccess files refactored and consolidated.
