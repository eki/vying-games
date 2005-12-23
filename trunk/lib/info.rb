
require 'game'

module RulesInfo

  RULESPATH='.'

  def RulesInfo.list
    RULESPATH.split(':').each do |directory|
      Dir.glob( "#{directory}/rules/**/*.rb" ) { |f| require "#{f}" }
    end
    a = []
    ObjectSpace.each_object( Class ) do |rules|
      a << rules if rules.ancestors.include?( Rules ) && rules != Rules
    end
    a
  end

end

if __FILE__ == $0
  puts "Self test..."
  RulesInfo.list.each do |rules| 
    puts "#{rules}"
    rules::INFO.info.each_pair { |k,v| puts "  #{k.capitalize}: #{v}" }
    puts
  end
end

