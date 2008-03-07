/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Returns true if this set of Coords contains the given Coord.
 *  
 *  call-seq:
 *    include?( coord ) -> boolean
 *
 */

VALUE coords_include( VALUE self, VALUE c ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));

  if( x < 0 || x >= w || y < 0 || y >= h ) {
    return Qnil;
  }

  return Qtrue;
}

/*
 *  Returns the next Coord in a given direction.  If the next Coord is not
 *  included in the Coords, nil is returned.
 *
 *  call-seq:
 *    next( coord, direction ) -> Coord or nil
 *
 *  The direction should be expressed as one of the keys to DIRECTIONS.
 *
 */

VALUE coords_next( VALUE self, VALUE c, VALUE d ) {
  VALUE dir = rb_hash_aref( rb_const_get( Coords, id_DIRECTIONS ), d );
  VALUE n = coord_addition( c, dir );
  return RTEST(coords_include( self, n )) ? n : Qnil;
}

