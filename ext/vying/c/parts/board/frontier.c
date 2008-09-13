/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Updates #frontier for the Frontier plugin.
 */

VALUE frontier_update( VALUE self, VALUE c ) {
  VALUE frontier = rb_iv_get( self, "@frontier" );
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE coords = rb_iv_get( self, "@coords" );
  VALUE dir = rb_funcall( self, id_directions, 1, c );
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));
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

    nx = x + dx;
    ny = y + dy;

    if( 0 <= nx && nx < w && 0 <= ny && ny < h &&
        rb_ary_entry( cells, nx+ny*w ) == Qnil ) {

      VALUE fc = rb_funcall( Coord, id_new, 2, INT2NUM(nx), INT2NUM(ny) );

      if( rb_funcall( coords, id_include, 1, fc ) == Qtrue ) {
        rb_ary_push( frontier, fc );
      }
    }
  }

  rb_funcall( frontier, id_delete, 1, c );
  rb_funcall( frontier, id_uniq_ex, 0 );
  return frontier;

}

