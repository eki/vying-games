/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  call-seq:
 *    board[x,y]
 *    board[:symbol]
 *    board["string"]
 *    board[coord]
 *    board[coord1,coord2,...,coordn]
 *
 *  Boards can be indexed by an (x,y) pair, or any number of Coord-like
 *  objects (ie, objects with #x and #y methods).  These Coord-like objects
 *  include Symbol, String, Array, and, obviously, Coord.
 */

VALUE board_subscript( int argc, VALUE *argv, VALUE self ) {
  if( argc == 2 && FIXNUM_P(argv[0]) && FIXNUM_P(argv[1]) ) {
    return board_get( self, argv[0], argv[1] );
  }
  else if( argc == 1 ) {
    return board_get_coord( self, argv[0] );
  }
  else {
    VALUE ary = rb_ary_new2( argc );
    int i;
    for( i = 0; i < argc; i++ ) {
      rb_ary_push( ary, board_get_coord( self, argv[i] ) );
    }
    return ary;
  }

  return Qnil;
}

/*
 *  call-seq:
 *    board[x,y] = :whatever
 *    board[coord] = :whatever
 *    board[coord1,coord2,...,coordn] = :whatever
 *
 *  Assign to a cell on a board.  Takes an (x,y) pair, or any number of
 *  Coord-like objects.  If multiple coords are passed, they will all be
 *  set to the same value.
 */

VALUE board_subscript_assign( int argc, VALUE *argv, VALUE self ) {
  if( argc == 3 && FIXNUM_P(argv[0]) && FIXNUM_P(argv[1]) ) {
    return rb_funcall( self, id_set, 3, argv[0], argv[1], argv[2] );
  }
  else if( argc == 2 ) {
    return board_set_coord( self, argv[0], argv[1] );
  }
  else {
    VALUE ary = rb_ary_new2( argc );
    int i;
    for( i = 0; i < argc-1; i++ ) {
      rb_ary_push( ary, 
        board_set_coord( self, argv[i], argv[argc-1] ) );
    }
    return argv[argc-1];
  }

  return Qnil;
}

/*
 *  Returns the value at the given Coord.
 */

VALUE board_get_coord( VALUE self, VALUE c ) {
  if( c == Qnil ) {
    return Qnil;
  }
  
  return board_get( self, rb_funcall( c, id_x, 0 ),
                          rb_funcall( c, id_y, 0 ) );
}

/*
 *  Returns the value at the given (x,y).
 *
 *  call-seq:
 *    get( x, y ) -> p
 *
 */

VALUE board_get( VALUE self, VALUE x, VALUE y ) {
  if( RTEST(board_in_bounds( self, x, y )) ) {
    VALUE cells = rb_iv_get( self, "@cells" );
    return rb_funcall( cells, id_subscript, 1, board_ci( self, x, y ) );
  }
  return Qnil;
}

/*
 *  Assigns to the given (x,y).
 *
 *  call-seq:
 *    set( x, y, p )
 *
 */

VALUE board_set( VALUE self, VALUE x, VALUE y, VALUE p ) {
  if( RTEST(rb_funcall( self, id_resize_q, 2, x, y )) ) {
    rb_funcall( self, id_resize, 2, x, y );
  }

  if( RTEST(board_in_bounds( self, x, y )) ) {
    VALUE cells = rb_iv_get( self, "@cells" );
    VALUE old = rb_funcall( cells, id_subscript, 1, board_ci( self, x, y ) );

    rb_funcall( self, id_before_set, 3, x, y, old );

    board_unoccupy( self, x, y, old );
    board_occupy( self, x, y, p );
    rb_funcall( cells, id_subscript_assign, 2, board_ci( self, x, y ), p );

    rb_funcall( self, id_after_set, 3, x, y, p );
  }
  return p;
}

/*
 *  Assigns to the given Coord.
 */

VALUE board_set_coord( VALUE self, VALUE c, VALUE p ) {
  if( c == Qnil ) {
    return Qnil;
  }

  return rb_funcall( self, id_set, 3, rb_funcall( c, id_x, 0 ),
                                      rb_funcall( c, id_y, 0 ), p );
}

/*
 *  Returns true if the given (x,y) is in bounds.
 *
 *  call-seq:
 *    in_bounds?( x, y ) -> boolean
 *
 */

VALUE board_in_bounds( VALUE self, VALUE x, VALUE y ) {
  VALUE origin = rb_iv_get( self, "@origin" );
  int ox = NUM2INT(rb_funcall( origin, id_x, 0 ));
  int oy = NUM2INT(rb_funcall( origin, id_y, 0 ));
  
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));
  int xi = NUM2INT(x);
  int yi = NUM2INT(y);

  if( xi < ox || xi >= (ox + w) || yi < oy || yi >= (oy + h) ) {
    return Qnil;
  } 
  
  return Qtrue;
}

/*
 *  Translates (x,y) into i.
 *
 *  call-seq:
 *    ci( x, y ) -> i
 *
 */

VALUE board_ci( VALUE self, VALUE x, VALUE y ) {
  VALUE origin = rb_iv_get( self, "@origin" );
  int ox = NUM2INT(rb_funcall( origin, id_x, 0 ));
  int oy = NUM2INT(rb_funcall( origin, id_y, 0 ));
  int w = NUM2INT(rb_iv_get( self, "@width" ));

  return INT2NUM( (NUM2INT(x) - ox) + (NUM2INT(y) - oy) * w );
}

/*
 *  Updates #occupied.
 */

VALUE board_occupy( VALUE self, VALUE x, VALUE y, VALUE p ) {
  VALUE occupied = rb_iv_get( self, "@occupied" );
  VALUE c = rb_funcall( Coord, id_new, 2, x, y );
  VALUE ary = rb_hash_aref( occupied, p );
  if( ary == Qnil || RARRAY_LEN(ary) == 0 ) {
    ary = rb_ary_new();
    rb_ary_push( ary, c );
    rb_hash_aset( occupied, p, ary );
  }
  else {
    rb_ary_push( ary, c );
  }

  return occupied;
}

/*
 *  Updates #occupied.
 */

VALUE board_unoccupy( VALUE self, VALUE x, VALUE y, VALUE p ) {
  VALUE occupied = rb_iv_get( self, "@occupied" );
  VALUE c = rb_funcall( Coord, id_new, 2, x, y );
  VALUE ary = rb_hash_aref( occupied, p );
  if( ary != Qnil ) {
    rb_funcall( ary, id_delete, 1, c );
  }
  return occupied;
}

/*
 *  Returns the an array of neighboring Coord's.
 */

VALUE board_neighbors( VALUE self, int x, int y ) {
  return rb_ary_new3( 8,
    rb_funcall( Coord, id_new, 2, INT2NUM(x+0), INT2NUM(y+1) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x+0), INT2NUM(y-1) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x+1), INT2NUM(y+0) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x+1), INT2NUM(y+1) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x+1), INT2NUM(y-1) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x-1), INT2NUM(y+0) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x-1), INT2NUM(y+1) ),
    rb_funcall( Coord, id_new, 2, INT2NUM(x-1), INT2NUM(y-1) ) );
}
