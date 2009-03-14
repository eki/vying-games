
class Vying::YamlFormat < Vying::Format

  def self.type
    :yaml
  end

  def load( string )
    Vying.load( YAML.load( string ), :hash )
  end

  def dump( game )
    game.to_format( :hash ).to_yaml
  end

end

