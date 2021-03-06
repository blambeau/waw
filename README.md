# Waw, making web applications simple

Waw is a web framework written in Ruby. It provides an alternative to Rails and other frameworks
written in Ruby as well. It is designed to be somewhere in the middle between Rails (sometimes a 
bit too heavy) and Rack/Sinatra (not really a framework, sometimes too low-level).

Waw has been originally designed in the ReQuest research project of the University of Louvain, has
been entirely rewritten in ruby, and is still actively developped to reach its first real stable 
version ;-)

## Links

http://github.com/blambeau/waw

## Main features

Waw basically provides an overall architecture for web sites and/or applications. Its main 
features are

- It proposes the development of secure web applications, avoiding code injection as much 
  as possible and enforcing validation of both input data (coming from formularies, for example) 
  and application state (user authentification or administration level for invoking specific 
  services or to access specific pages)
  
- A simple but powerful templating engine, not restricted to HTML... Creating XML files for AJAX
  services, creating text reports and so on are all as easy as generating html.
  
- Invoking webservices through AJAX is made declarative. The javascript code is automatically
  generated!
  
- When things become too restrictive for you (you don't fit the architecture exactly) you can 
  access lower stages ... edit the underlying Rack configuration and install your own services
  in a few minutes, bypassing waw when needed!

