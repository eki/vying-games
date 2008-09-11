
import org.jruby.*;
import org.jruby.javasupport.JavaEmbedUtils;
import org.jruby.runtime.builtin.IRubyObject;

/* This is a wrapper / helper class meant to provide static methods to assist 
 * in writing this Java extension.  The goal is to be more terse, Ruby-like,
 * and consistent than the JRuby APIs.  It's not yet clear whether introducing
 * this helper is really an improvement or worthwhile.
 */

public class R {

  private static RubyObjectAdapter roa = JavaEmbedUtils.newObjectAdapter();

  public static int num2int( IRubyObject n ) {
    return RubyNumeric.num2int( n );
  }

  public static RubyNumeric int2num( IRubyObject self, int n ) {
    return RubyNumeric.int2fix( self.getRuntime(), n );
  }

  public static 
  IRubyObject instance_variable_get( IRubyObject self, String iv ) {
    return roa.getInstanceVariable( self, iv );
  }

  public static 
  IRubyObject 
  instance_variable_set( IRubyObject self, String iv, IRubyObject v ) {
    return roa.setInstanceVariable( self, iv, v );
  }

  public static
  IRubyObject funcall( IRubyObject self, String m ) {
    return roa.callMethod( self, m );
  }

  public static
  IRubyObject funcall( IRubyObject self, String m, IRubyObject[] args ) {
    return roa.callMethod( self, m, args );
  }

  public static IRubyObject nil( IRubyObject self ) {
    return self.getRuntime().getNil();
  }

  public static IRubyObject klass( IRubyObject self, String s ) {
    return self.getRuntime().getClass( s );
  }

  public static IRubyObject symbol( IRubyObject self, String s ) {
    return RubySymbol.newSymbol( self.getRuntime(), s );
  }

}

