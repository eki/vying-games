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
  VALUE coords = rb_iv_get( self, "@coords" );
  VALUE dir = rb_funcall( self, id_directions, 1, c );
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));

  int i;
  for( i = 0; i < RARRAY_LEN(dir); i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx = 0, dy = 0;
    VALUE nx, ny;

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

    nx = INT2NUM(x + dx);
    ny = INT2NUM(y + dy);

    if( RTEST(board_in_bounds( self, nx, ny )) ) {
      VALUE fc = rb_funcall( Coord, id_new, 2, nx, ny );

      if( rb_funcall( coords, id_include, 1, fc ) == Qtrue &&
          board_get( self, nx, ny ) == Qnil ) {
        rb_ary_push( frontier, fc );
      }
    }
  }

  rb_funcall( frontier, id_delete, 1, c );
  rb_funcall( frontier, id_uniq_ex, 0 );
  return frontier;

}

