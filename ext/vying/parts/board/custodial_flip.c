/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Tests whether placing the given piece at the given coord would result
 *  in pieces being flipped any of the Board#directions.
 *
 *  call-seq:
 *    will_flip?( coord, piece ) -> boolean
 *
 */

VALUE custodial_flip_valid( VALUE self, VALUE c, VALUE p ) {
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE dir = rb_iv_get( self, "@directions" );

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

    nx = x+dx;
    ny = y+dy;

    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    if( np == Qnil || np == p ) {
      continue;
    }

    nx += dx;
    ny += dy;
    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    while( np != Qnil ) {
      if( np == p ) {
        return Qtrue;
      }

      nx += dx;
      ny += dy;
      np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    }
  }

  return Qfalse;
}

/*
 *  Place the given piece at the given coord.  Flip any pieces that would
 *  be victims of custodial capture in one of Board#directions.  This is
 *  essentially the behavior of placing a piece in Othello.
 *
 *  call-seq:
 *    place( coord, piece ) -> piece
 *
 */

VALUE custodial_flip( VALUE self, VALUE c, VALUE p ) {
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE dir = rb_iv_get( self, "@directions" );

  int bt[w];
  int blen = 0;

  int i;
  for( i = 0; i < RARRAY(dir)->len; i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx, dy, nx, ny;
    VALUE np;

    blen = 0;

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

    nx = x+dx;
    ny = y+dy;

    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    if( np == Qnil || np == p ) {
      continue;
    }

    bt[blen++] = nx + ny * w;

    nx += dx;
    ny += dy;
    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    while( np != Qnil ) {
      if( np == p ) {
        int j;
        for( j = 0; j < blen; j++ ) {
          board_set( self, INT2NUM(bt[j]%w), INT2NUM(bt[j]/w), p );
        }

        break;
      }

      bt[blen++] = nx + ny * w;

      nx += dx;
      ny += dy;
      np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    }
  }

  return board_set( self, INT2NUM(x), INT2NUM(y), p );
}

