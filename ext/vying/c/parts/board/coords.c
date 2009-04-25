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
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));

  VALUE bounds = rb_iv_get( self, "@bounds" );

  VALUE first = rb_ary_entry( bounds, 0 );
  VALUE last  = rb_ary_entry( bounds, 1 );
  
  int min_x = NUM2INT(rb_funcall( first, id_x, 0 ));
  int max_x = NUM2INT(rb_funcall( last,  id_x, 0 ));

  int min_y = NUM2INT(rb_funcall( first, id_y, 0 ));
  int max_y = NUM2INT(rb_funcall( last,  id_y, 0 ));

  if( x < min_x || x > max_x || y < min_y || y > max_y ) {
    return Qnil;
  }

  VALUE omitted = rb_iv_get( self, "@omitted" );

  if( RARRAY_LEN(omitted) == 0 ) {
    return Qtrue;
  }

  VALUE coords = rb_iv_get( self, "@coords" );

  if( RARRAY_LEN(omitted) < RARRAY_LEN(coords) ) {
    return rb_funcall( omitted, id_include, 1, c ) == Qfalse ? Qtrue : Qfalse;
  }
  else {
    return rb_funcall( coords, id_include, 1, c );
  }
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

