#include "ruby.h"
#include "coord.h"
#include "coords.h"
#include "board.h"
#include "othello.h"

/* OthelloBoard method definitions */

VALUE othello_board_initialize( VALUE self ) {
  VALUE args[] = {INT2NUM(8),INT2NUM(8)};

  board_initialize( 2, (VALUE *)&args, self );
  board_set( self, INT2NUM(3), INT2NUM(3), ID2SYM(rb_intern("white")) );
  board_set( self, INT2NUM(4), INT2NUM(4), ID2SYM(rb_intern("white")) );
  board_set( self, INT2NUM(3), INT2NUM(4), ID2SYM(rb_intern("black")) );
  board_set( self, INT2NUM(4), INT2NUM(3), ID2SYM(rb_intern("black")) );

  rb_iv_set( self, "@occupied", 
    rb_ary_new3( 4,
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(3), INT2NUM(3) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(4), INT2NUM(4) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(3), INT2NUM(4) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(4), INT2NUM(3) ) ) );

  rb_iv_set( self, "@frontier",
    rb_ary_new3( 12,
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(2), INT2NUM(2) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(3), INT2NUM(2) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(4), INT2NUM(2) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(5), INT2NUM(2) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(5), INT2NUM(3) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(5), INT2NUM(4) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(5), INT2NUM(5) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(4), INT2NUM(5) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(3), INT2NUM(5) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(2), INT2NUM(5) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(2), INT2NUM(4) ),
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(2), INT2NUM(3) ) ) );
}

VALUE othello_board_initialize_copy( VALUE self, VALUE obj ) {
  board_initialize_copy( self, obj );
  rb_iv_set( self, "@occupied",
    rb_funcall( rb_iv_get( obj, "@occupied" ), rb_intern( "dup" ), 0 ) );
  rb_iv_set( self, "@frontier",
    rb_funcall( rb_iv_get( obj, "@frontier" ), rb_intern( "dup" ), 0 ) );
}

VALUE othello_board_valid( int argc, VALUE *argv, VALUE self ) {
  int x = NUM2INT(rb_funcall( argv[0], rb_intern("x"), 0 ));
  int y = NUM2INT(rb_funcall( argv[0], rb_intern("y"), 0 ));
  VALUE p = argv[1];
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE dir;

  if( argc == 2 ) {
    dir = rb_ary_new3( 8, ID2SYM(rb_intern("n")),
                          ID2SYM(rb_intern("s")),
                          ID2SYM(rb_intern("w")),
                          ID2SYM(rb_intern("e")),
                          ID2SYM(rb_intern("ne")),
                          ID2SYM(rb_intern("nw")),
                          ID2SYM(rb_intern("se")),
                          ID2SYM(rb_intern("sw")) );
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

    if( SYM2ID(d) == rb_intern("n" ) ) {
      dx = 0;
      dy = -1;
    }
    else if( SYM2ID(d) == rb_intern( "s" ) ) {
      dx = 0;
      dy = 1;
    }
    else if( SYM2ID(d) == rb_intern( "w" ) ) {
      dx = -1;
      dy = 0;
    }
    else if( SYM2ID(d) == rb_intern( "e" ) ) {
      dx = 1;
      dy = 0;
    }
    else if( SYM2ID(d) == rb_intern( "ne" ) ) {
      dx = 1;
      dy = -1;
    }
    else if( SYM2ID(d) == rb_intern( "nw" ) ) {
      dx = -1;
      dy = -1;
    }
    else if( SYM2ID(d) == rb_intern( "se" ) ) {
      dx = 1;
      dy = 1;
    }
    else if( SYM2ID(d) == rb_intern( "sw" ) ) {
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
  int x = NUM2INT(rb_funcall( c, rb_intern("x"), 0 ));
  int y = NUM2INT(rb_funcall( c, rb_intern("y"), 0 ));
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE dir = rb_ary_new3( 8, ID2SYM(rb_intern("n")),
                              ID2SYM(rb_intern("s")),
                              ID2SYM(rb_intern("w")),
                              ID2SYM(rb_intern("e")),
                              ID2SYM(rb_intern("ne")),
                              ID2SYM(rb_intern("nw")),
                              ID2SYM(rb_intern("se")),
                              ID2SYM(rb_intern("sw")) );

  VALUE bt = rb_ary_new2(10);

  int i;
  for( i = 0; i < RARRAY(dir)->len; i++ ) {
    VALUE d = rb_ary_entry( dir, i );
    int dx, dy, nx, ny;
    VALUE np;

    rb_ary_clear( bt );

    if( SYM2ID(d) == rb_intern("n" ) ) {
      dx = 0;
      dy = -1;
    }
    else if( SYM2ID(d) == rb_intern( "s" ) ) {
      dx = 0;
      dy = 1;
    }
    else if( SYM2ID(d) == rb_intern( "w" ) ) {
      dx = -1;
      dy = 0;
    }
    else if( SYM2ID(d) == rb_intern( "e" ) ) {
      dx = 1;
      dy = 0;
    }
    else if( SYM2ID(d) == rb_intern( "ne" ) ) {
      dx = 1;
      dy = -1;
    }
    else if( SYM2ID(d) == rb_intern( "nw" ) ) {
      dx = -1;
      dy = -1;
    }
    else if( SYM2ID(d) == rb_intern( "se" ) ) {
      dx = 1;
      dy = 1;
    }
    else if( SYM2ID(d) == rb_intern( "sw" ) ) {
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
          rb_funcall( cells, rb_intern("[]="), 2, ci, p );
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
/*
VALUE othello_board_occupied( VALUE self ) {
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE occupied = rb_ary_new();
  int i;
 
  for( i = 0; i < RARRAY(cells)->len; i++ ) {
    if( rb_ary_entry( cells, i ) != Qnil ) {
      rb_ary_push( occupied, board_ic( self, i ) );
    }
  }

  return occupied;
}
*/
VALUE othello_board_update_occupied( VALUE self, VALUE x, VALUE y ) {
  VALUE occupied = rb_iv_get( self, "@occupied" );
  VALUE c = rb_funcall( Coord, rb_intern("new"), 2, x, y );
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
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(n_x), INT2NUM(n_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= s_x && s_x < w && 0 <= s_y && s_y < h &&
      rb_ary_entry( cells, s_x+s_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(s_x), INT2NUM(s_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= e_x && e_x < w && 0 <= e_y && e_y < h &&
      rb_ary_entry( cells, e_x+e_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(e_x), INT2NUM(e_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= w_x && w_x < w && 0 <= w_y && w_y < h &&
      rb_ary_entry( cells, w_x+w_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(w_x), INT2NUM(w_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= ne_x && ne_x < w && 0 <= ne_y && ne_y < h &&
      rb_ary_entry( cells, ne_x+ne_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(ne_x), INT2NUM(ne_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= nw_x && nw_x < w && 0 <= nw_y && nw_y < h &&
      rb_ary_entry( cells, nw_x+nw_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(nw_x), INT2NUM(nw_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= se_x && se_x < w && 0 <= se_y && se_y < h &&
      rb_ary_entry( cells, se_x+se_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(se_x), INT2NUM(se_y) );
    rb_ary_push( frontier, c );
  }

  if( 0 <= sw_x && sw_x < w && 0 <= sw_y && sw_y < h &&
      rb_ary_entry( cells, sw_x+sw_y*w ) == Qnil ) {
    VALUE c = 
      rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(sw_x), INT2NUM(sw_y) );
    rb_ary_push( frontier, c );
  }

  rb_funcall( frontier, rb_intern("delete"), 1,
    rb_funcall( Coord, rb_intern("new"), 2, x, y ) );
  rb_funcall( frontier, rb_intern("uniq!"), 0 );
  return frontier;
}

VALUE othello_board_set( VALUE self, VALUE x, VALUE y, VALUE p ) {
  othello_board_update_occupied( self, x, y );
  othello_board_update_frontier( self, x, y );

  board_set( self, x, y, p );
}

/*
VALUE othello_board_frontier( VALUE self ) {
  VALUE cells = rb_iv_get( self, "@cells" );
  VALUE frontier = rb_ary_new();
  int i;
 
  for( i = 0; i < RARRAY(cells)->len; i++ ) {
    if( rb_ary_entry( cells, i ) != Qnil ) {
      continue;
    }

    int x = board_ix( self, i );
    int y = board_iy( self, i );

    if( board_get( self, INT2NUM(x+0), INT2NUM(y+1) ) != Qnil ||
        board_get( self, INT2NUM(x+0), INT2NUM(y-1) ) != Qnil ||
        board_get( self, INT2NUM(x+1), INT2NUM(y+0) ) != Qnil ||
        board_get( self, INT2NUM(x+1), INT2NUM(y+1) ) != Qnil ||
        board_get( self, INT2NUM(x+1), INT2NUM(y-1) ) != Qnil ||
        board_get( self, INT2NUM(x-1), INT2NUM(y+0) ) != Qnil ||
        board_get( self, INT2NUM(x-1), INT2NUM(y+1) ) != Qnil ||
        board_get( self, INT2NUM(x-1), INT2NUM(y-1) ) != Qnil ) {
      rb_ary_push( frontier, board_ic( self, i ) );
      continue;
    }
  }
  return frontier;
}
*/
