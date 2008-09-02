
module Kernel
  def nested_const_get( s )
    s.split( /::/ ).inject( Kernel ) { |m,s| m.const_get( s ) }
  end
end

