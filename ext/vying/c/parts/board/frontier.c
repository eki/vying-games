/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Updates #frontier for the Frontier plugin.
 */

VALUE frontier_update( VALUE self, VALUE x, VALUE y ) {
  VALUE frontier = rb_iv_get( self, "@frontier" );
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE coords = rb_iv_get( self, "@coords" );
  VALUE dir = rb_iv_get( self, "@directions" );
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));

  int i;
  for( i = 0; i < RARRAY(dir)->len; i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx, dy, nx, ny;
    VALUE np;

    if( d == sym_n ) {
      dx = 0;
      dy = -1;
    }
    else if( d == sym_s ) {
      dx = 0;
      dy = 1;
    }
    else if( d == sym_w ) {
      dx = -1;
      dy = 0;
    }
    else if( d == sym_e ) {
      dx = 1;
      dy = 0;
    }
    else if( d == sym_ne ) {
      dx = 1;
      dy = -1;
    }
    else if( d == sym_nw ) {
      dx = -1;
      dy = -1;
    }
    else if( d == sym_se ) {
      dx = 1;
      dy = 1;
    }
    else if( d == sym_sw ) {
      dx = -1;
      dy = 1;
    }

    nx = NUM2INT(x)+dx;
    ny = NUM2INT(y)+dy;

    if( 0 <= nx && nx < w && 0 <= ny && ny < h &&
        rb_ary_entry( cells, nx+ny*w ) == Qnil ) {

      VALUE c = rb_funcall( Coord, id_new, 2, INT2NUM(nx), INT2NUM(ny) );

      if( rb_funcall( coords, id_include, 1, c ) == Qtrue ) {
        rb_ary_push( frontier, c );
      }
    }
  }


  rb_funcall( frontier, id_delete, 1,
    rb_funcall( Coord, id_new, 2, x, y ) );
  rb_funcall( frontier, id_uniq_ex, 0 );
  return frontier;
}

