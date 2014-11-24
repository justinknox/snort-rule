require "snort/rule/version"
require "open-uri"

# Generates and parses snort rules
#
# Authors::   Chris Lee  (mailto:rubygems@chrislee.dhs.org),
#             Will Green (will[ at ]hotgazpacho[ dot ]org),
#             Justin Knox (jknox[ at ]indexzero[ dot ]org)
#             Ryan Barnett (rbarnett[ at ]modsecurity[ dot ]org)
# Copyright:: Copyright (c) 2011 Chris Lee
# License::   Distributes under the same terms as Ruby
module Snort
  # This class stores a set of rules and allows actions against them
  class RuleSet
    
    def RuleSet::from_file(file)
      if file.class == File
        fh = file
      else
        fh = open(file.to_s, 'r')
      end
      RuleSet::from_filehandle(fh)
    end
    
    def RuleSet::from_url(url)
      RuleSet::from_file(url)
    end
    
    def RuleSet::from_filehandle(fh)
      rules = RuleSet.new
      fh.each_line do |line|
        next unless line =~ /(alert|drop|pass|reject|activate|dynamic|activate)/
        begin
          rule = Snort::Rule.parse(line)
          if rule
            rules << rule
          end
        rescue ArgumentError => e
        rescue NoMethodError => e
        end
      end
      rules
    end
    
    def initialize(ruleset=[])
      @ruleset = ruleset
    end
    
    def <<(rule)
      @ruleset << rule
    end
    
    def -(rule)
      @ruleset -= rule
    end
    
    def length
      @ruleset.length
    end
    
    def count(&block)
      @ruleset.count(&block)
    end
    
    def enable(&block)
      count = 0
      @ruleset.each do |rule|
        if block.call(rule)
          rule.enable
          count += 1
        end
      end
      count
    end
    
    def disable(&block)
      count = 0
      @ruleset.each do |rule|
        if block.call(rule)
          rule.disable
          count += 1
        end
      end
      count
    end
    
    def delete(&block)
      len = @ruleset.length
      @ruleset.delete_if(&block)
      len - @ruleset.length
    end
    
    def enable_all
      enable do |r|
        true
      end
    end
    
    def disable_all
      disable do |r|
        true
      end
    end
    
    def delete_all
      delete do |r|
        true
      end
    end

    def enable_by_name(name)
      enable do |r|
        if r.name =~ name
          true
        end
      end
    end
    
    def disable_by_name(name)
      disable do |r|
        if r.name =~ name
          true
        end
      end
    end
    
    def delete_by_name(name)
      delete do |r|
        if r.name =~ name
          true
        end
      end
    end
  end
end