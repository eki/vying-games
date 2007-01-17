#include "ruby.h"
#include "board.h"

/* OthelloBoard method definitions */

VALUE othello_board_initialize( VALUE self ) {
  VALUE args[] = {INT2NUM(8),INT2NUM(8)};

  rb_call_super( 2, (VALUE *)&args );
  board_set( self, INT2NUM(3), INT2NUM(3), sym_white );
  board_set( self, INT2NUM(4), INT2NUM(4), sym_white );
  board_set( self, INT2NUM(3), INT2NUM(4), sym_black );
  board_set( self, INT2NUM(4), INT2NUM(3), sym_black );

  rb_iv_set( self, "@occupied", 
    rb_ary_new3( 4,
      rb_funcall( Coord, id_new, 2, INT2NUM(3), INT2NUM(3) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(4), INT2NUM(4) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(3), INT2NUM(4) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(4), INT2NUM(3) ) ) );

  rb_iv_set( self, "@frontier",
    rb_ary_new3( 12,
      rb_funcall( Coord, id_new, 2, INT2NUM(2), INT2NUM(2) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(3), INT2NUM(2) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(4), INT2NUM(2) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(5), INT2NUM(2) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(5), INT2NUM(3) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(5), INT2NUM(4) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(5), INT2NUM(5) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(4), INT2NUM(5) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(3), INT2NUM(5) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(2), INT2NUM(5) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(2), INT2NUM(4) ),
      rb_funcall( Coord, id_new, 2, INT2NUM(2), INT2NUM(3) ) ) );
}

VALUE othello_board_initialize_copy( VALUE self, VALUE obj ) {
  VALUE args[] = {obj};
  rb_call_super( 1, (VALUE *)&args );
  rb_iv_set( self, "@occupied",
    rb_funcall( rb_iv_get( obj, "@occupied" ), id_dup, 0 ) );
  rb_iv_set( self, "@frontier",
    rb_funcall( rb_iv_get( obj, "@frontier" ), id_dup, 0 ) );
}

VALUE othello_board_valid( int argc, VALUE *argv, VALUE self ) {
  int x = NUM2INT(rb_funcall( argv[0], id_x, 0 ));
  int y = NUM2INT(rb_funcall( argv[0], id_y, 0 ));
  VALUE p = argv[1];
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE dir;

  if( argc == 2 ) {
    dir = rb_ary_new3( 8, sym_n,
                          sym_s,
                          sym_w,
                          sym_e,
                          sym_ne,
                          sym_nw,
                          sym_se,
                          sym_sw );
  }
  else {
    dir = argv[2];
  }

  if( board_get( self, INT2NUM(x), INT2NUM(y) ) != Qnil ) {
    return Qfalse;
  }

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

VALUE othello_board_place( VALUE self, VALUE c, VALUE p ) {
  int x = NUM2INT(rb_funcall( c, id_x, 0 ));
  int y = NUM2INT(rb_funcall( c, id_y, 0 ));
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE dir = rb_ary_new3( 8, sym_n,
                              sym_s,
                              sym_w,
                              sym_e,
                              sym_ne,
                              sym_nw,
                              sym_se,
                              sym_sw );

  VALUE bt = rb_ary_new2(10);

  int i;
  for( i = 0; i < RARRAY(dir)->len; i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx, dy, nx, ny;
    VALUE np;

    rb_ary_clear( bt );

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

    rb_ary_push( bt, board_ci( self, INT2NUM(nx), INT2NUM(ny) ) );

    nx += dx;
    ny += dy;
    np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    while( np != Qnil ) {
      if( np == p ) {
        VALUE ci;
        while( (ci = rb_ary_pop( bt )) != Qnil ) {
          rb_funcall( cells, id_subscript_assign, 2, ci, p );
        }

        break;
      }

      rb_ary_push( bt, board_ci( self, INT2NUM(nx), INT2NUM(ny) ) );

      nx += dx;
      ny += dy;
      np = board_get( self, INT2NUM(nx), INT2NUM(ny) );
    }
  }

  return othello_board_set( self, INT2NUM(x), INT2NUM(y), p );
}

VALUE othello_board_update_occupied( VALUE self, VALUE x, VALUE y ) {
  VALUE occupied = rb_iv_get( self, "@occupied" );
  VALUE c = rb_funcall( Coord, id_new, 2, x, y );
  rb_ary_push( occupied, c );
  return occupied;
}

VALUE othello_board_update_frontier( VALUE self, VALUE x, VALUE y ) {
  VALUE frontier = rb_iv_get( self, "@frontier" );
  VALUE cells = rb_iv_get( self, "@cells" );
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));
  int x1 = NUM2INT(x);
  int y1 = NUM2INT(y);

  int n_x = x1 + 0;
  int n_y = y1 - 1;

  int s_x = x1 + 0;
  int s_y = y1 + 1;

  int e_x = x1 + 1;
  int e_y = y1 + 0;

  int w_x = x1 - 1;
  int w_y = y1 + 0;

  int ne_x = x1 + 1;
  int ne_y = y1 - 1;

  int nw_x = x1 - 1;
  int nw_y = y1 - 1;

  int se_x = x1 + 1;
  int se_y = y1 + 1;

  int sw_x = x1 - 1;
  int sw_y = y1 + 1;

  if( 0 <= n_x && n_x < w && 0 <= n_y && n_y < h &&
      rb_ary_entry( cells, n_x+n_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(n_x), INT2NUM(n_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= s_x && s_x < w && 0 <= s_y && s_y < h &&
      rb_ary_entry( cells, s_x+s_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(s_x), INT2NUM(s_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= e_x && e_x < w && 0 <= e_y && e_y < h &&
      rb_ary_entry( cells, e_x+e_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(e_x), INT2NUM(e_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= w_x && w_x < w && 0 <= w_y && w_y < h &&
      rb_ary_entry( cells, w_x+w_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(w_x), INT2NUM(w_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= ne_x && ne_x < w && 0 <= ne_y && ne_y < h &&
      rb_ary_entry( cells, ne_x+ne_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(ne_x), INT2NUM(ne_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= nw_x && nw_x < w && 0 <= nw_y && nw_y < h &&
      rb_ary_entry( cells, nw_x+nw_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(nw_x), INT2NUM(nw_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= se_x && se_x < w && 0 <= se_y && se_y < h &&
      rb_ary_entry( cells, se_x+se_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(se_x), INT2NUM(se_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= sw_x && sw_x < w && 0 <= sw_y && sw_y < h &&
      rb_ary_entry( cells, sw_x+sw_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, id_new, 2, INT2NUM(sw_x), INT2NUM(sw_y) );
    rb_ary_push( frontier, c );
  }

  rb_funcall( frontier, id_delete, 1,
    rb_funcall( Coord, id_new, 2, x, y ) );
  rb_funcall( frontier, id_uniq_ex, 0 );
  return frontier;
}

VALUE othello_board_set( VALUE self, VALUE x, VALUE y, VALUE p ) {
  othello_board_update_occupied( self, x, y );
  othello_board_update_frontier( self, x, y );

  board_set( self, x, y, p );
}

