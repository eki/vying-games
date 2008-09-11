
import org.jruby.*;
import org.jruby.runtime.load.BasicLibraryService;

/*  Load the board extension.  
 *
 *  NOTE: The resulting jar must be named 'vying_board_ext.jar' and must be
 *  located directly in one of the paths in the RUBYLIB environment variable.
 *  This means the extension can be loaded with:
 *
 *    require 'vying_board_ext'
 *
 *  Which is why the 'vying_' prefix is there.
 *
 *  TODO:  When it becomes possible in JRuby, change the location of the jar
 *         and require statement.  Ideally, we could have something that
 *         parallels the location of the C extension.
 *
 */

public class VyingBoardExtService implements BasicLibraryService {

  /* Define Ruby that classes and methods that make up this extension. */

  public boolean basicLoad( Ruby runtime ) { 

    RubyClass cCoord = runtime.defineClass( "Coord", runtime.getObject(),
      runtime.getObject().getAllocator() );
    cCoord.defineAnnotatedMethods( Coord.class );

    return true;
  }

}

