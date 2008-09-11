

import org.jruby.*;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.builtin.IRubyObject;

/*  Extend the Coord ruby class.  Benchmarking shows that these are not 
 *  particularly worthwhile.  This code should just be considered a nice
 *  guideline on how to do some simple overrides.
 *
 */

public class Coord {

  /*  Add two Coords together.
   *  
   */

  @JRubyMethod( name="+" )
  public static IRubyObject coord_addition( IRubyObject self, IRubyObject c ) {
    int x1 = R.num2int( R.instance_variable_get( self, "@x" ) );
    int y1 = R.num2int( R.instance_variable_get( self, "@y" ) );
    int x2 = R.num2int( R.instance_variable_get( c, "@x" ) );
    int y2 = R.num2int( R.instance_variable_get( c, "@y" ) );

    IRubyObject nx = R.int2num( self, x1 + x2 );
    IRubyObject ny = R.int2num( self, y1 + y2 );

    IRubyObject[] args = {nx, ny};

    return R.funcall( R.klass( self, "Coord" ), "new", args );
  }

  /*  In which direction would we have to travel to get from this Coord to
   *  the given Coord.  Returns one of [:n, :e, :w, :s, :ne, :nw, :se, :sw] or
   *  nil if the given Coord cannot be reached by traveling in a straight line.
   *
   */

  @JRubyMethod( name="direction_to" )
  public static 
  IRubyObject coord_direction_to( IRubyObject self, IRubyObject c ) {
    int x1 = R.num2int( R.instance_variable_get( self, "@x" ) );
    int y1 = R.num2int( R.instance_variable_get( self, "@y" ) );

    int x2 = R.num2int( R.funcall( c, "x" ) );
    int y2 = R.num2int( R.funcall( c, "y" ) );

    int dx = x1 - x2;
    int dy = y1 - y2;

    if( dx == 0 ) {
      if( dy > 0 ) {
        return R.symbol( self, "n" );
      }
      else if( dy < 0 ) {
        return R.symbol( self, "s" );
      }
    }
    else if( dy == 0 ) {
      if( dx > 0 ) {
        return R.symbol( self, "w" );
      }
      else if( dx < 0 ) {
        return R.symbol( self, "e" );
      }
    }
    else if( dx == dy ) {
      if( dx < 0 && dy < 0 ) {
        return R.symbol( self, "se" );
      }
      else if( dx > 0 && dy > 0 ) {
        return R.symbol( self, "nw" );
      }
    }
    else if( -dx == dy ) {
      if( dx > 0 && dy < 0 ) {
        return R.symbol( self, "sw" );
      }
      else if( dx < 0 && dy > 0 ) {
        return R.symbol( self, "ne" );
      }
    }

    return R.nil( self );
  }

  /*
   * TODO:  Try to make this code work.
   *

  @JRubyMethod( name="[]", meta=true )
  public static 
  IRubyObject coord_class_subscript( IRubyObject self, IRubyObject[] args ) {
    return self;  // Not overriding Coord.[] as expected!
  }

  *
  */
}

