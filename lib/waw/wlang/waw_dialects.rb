require 'waw/wlang/actions_ruleset'
# wlang/ruby dialect
WLang::dialect("xhtml", ".wtpl", ".wbrick") do
  ruby_require "cgi", "wlang/dialects/xhtml_dialect" do
    encoders WLang::EncoderSet::XHtml
    rules WLang::RuleSet::Basic
    rules WLang::RuleSet::Encoding
    rules WLang::RuleSet::Imperative
    rules WLang::RuleSet::Buffering
    rules WLang::RuleSet::Context
    rules WLang::RuleSet::XHtml
    rules WLang::RuleSet::WawActionsRuleSet
  end
end