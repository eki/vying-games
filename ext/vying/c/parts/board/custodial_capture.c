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
 *    custodial_capture?( coord, piece, range=nil ) -> boolean
 *
 */

VALUE custodial_capture_valid( int argc, VALUE *argv, VALUE self ) {
  int x = NUM2INT(rb_funcall( argv[0], id_x, 0 ));
  int y = NUM2INT(rb_funcall( argv[0], id_y, 0 ));

  VALUE p = argv[1];

  VALUE range = Qnil;
  int first = 0;
  int last = 0;

  VALUE dir = rb_iv_get( self, "@directions" );

  int i, blen;

  if( argc > 2 && RTEST(argv[2]) ) {
    range = argv[2];
    first = NUM2INT(rb_funcall( range, id_first, 0 ));
    last  = NUM2INT(rb_funcall( range, id_last,  0 ));
  }

  for( i = 0; i < RARRAY_LEN(dir); i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx = 0, dy = 0, nx, ny;
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

    blen++;

    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    if( NIL_P(np) || np == p ) {
      continue;
    }

    nx += dx;
    ny += dy;
    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    while( np != Qnil ) {
      if( range != Qnil && blen > last ) {
        break;
      }
      if( range != Qnil && blen < first && np == p ) {
        break;
      }
      if( np == p && ! (range != Qnil && blen < first) ) {
        return Qtrue;
      }

      nx += dx;
      ny += dy;

      blen++;

      np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    }
  }

  return Qfalse;
}

/*
 *  Place the given piece at the given coord.  Replace any pieces that would
 *  be victims of custodial capture in one of Board#directions.
 *
 *  call-seq:
 *    custodial( coord, piece, replacement=nil, range=nil ) -> [captured coords]
 *
 */

VALUE custodial( int argc, VALUE *argv, VALUE self ) {
  int x = NUM2INT(rb_funcall( argv[0], id_x, 0 ));
  int y = NUM2INT(rb_funcall( argv[0], id_y, 0 ));

  VALUE p = argv[1];

  VALUE replacement = Qnil;

  VALUE range = Qnil;
  int first = 0;
  int last = 0;

  VALUE dir = rb_iv_get( self, "@directions" );

  VALUE cap = rb_ary_new();

  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));

  int bt[(w > h) ? w : h][2];
  int blen = 0;

  int i;

  if( argc > 2 ) {
    replacement = argv[2];
  }

  if( argc > 3 && RTEST(argv[3]) ) {
    range = argv[3];
    first = NUM2INT(rb_funcall( range, id_first, 0 ));
    last  = NUM2INT(rb_funcall( range, id_last,  0 ));
  }

  for( i = 0; i < RARRAY_LEN(dir); i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx = 0, dy = 0, nx, ny;
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
    if( NIL_P(np) || np == p ) {
      continue;
    }

    bt[blen][0] = nx;
    bt[blen][1] = ny;
    blen++;    

    nx += dx;
    ny += dy;
    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    while( np != Qnil ) {
      if( range != Qnil && blen > last ) {
        break;
      }
      if( range != Qnil && blen < first && np == p ) {
        break;
      }
      if( np == p && ! (range != Qnil && blen < first ) ) {
        int j;
        for( j = 0; j < blen; j++ ) {
          VALUE cx = INT2NUM(bt[j][0]);
          VALUE cy = INT2NUM(bt[j][1]);

          rb_funcall( self, id_set, 3, cx, cy, replacement );
          rb_ary_push( cap, rb_funcall( Coord, id_new, 2, cx, cy ) );
        }

        break;
      }

      bt[blen][0] = nx;
      bt[blen][1] = ny;
      blen++;    

      nx += dx;
      ny += dy;
      np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    }
  }

  board_set( self, INT2NUM(x), INT2NUM(y), p );

  return cap;
}

