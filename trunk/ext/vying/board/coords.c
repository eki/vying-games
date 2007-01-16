#include "ruby.h"
#include "coord.h"
#include "coords.h"

/* Coords method definitions */

VALUE coords_include( VALUE self, VALUE c ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));
  int x = NUM2INT(rb_funcall( c, rb_intern("x"), 0 ));
  int y = NUM2INT(rb_funcall( c, rb_intern("y"), 0 ));

  if( x < 0 || x >= w || y < 0 || y >= h ) {
    return Qnil;
  }

  return Qtrue;
}

VALUE coords_next( VALUE self, VALUE c, VALUE d ) {
  VALUE dir = rb_hash_aref( 
    rb_const_get( Coords, rb_intern("DIRECTIONS") ), d );
  VALUE n = coord_addition( c, dir );
  return RTEST(coords_include( self, n )) ? n : Qnil;
}

