#include "ruby.h"
#include "board.h"

/* Board method definitions */

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

VALUE board_subscript_assign( int argc, VALUE *argv, VALUE self ) {
  if( argc == 3 && FIXNUM_P(argv[0]) && FIXNUM_P(argv[1]) ) {
    return board_set( self, argv[0], argv[1], argv[2] );
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

VALUE board_get_coord( VALUE self, VALUE c ) {
  if( c == Qnil ) {
    return Qnil;
  }
  
  return board_get( self, rb_funcall( c, id_x, 0 ),
                          rb_funcall( c, id_y, 0 ) );
}

VALUE board_get( VALUE self, VALUE x, VALUE y ) {
  if( RTEST(board_in_bounds( self, x, y )) ) {
    VALUE cells = rb_iv_get( self, "@cells" );
    return rb_funcall( cells, id_subscript, 1, board_ci( self, x, y ) );
  }
  return Qnil;
}

VALUE board_set( VALUE self, VALUE x, VALUE y, VALUE p ) {
  if( RTEST(board_in_bounds( self, x, y )) ) {
    VALUE cells = rb_iv_get( self, "@cells" );
    VALUE old = rb_funcall( cells, id_subscript, 1, board_ci( self, x, y ) );
    if( old != Qnil ) {
      board_unoccupy( self, x, y, old );
    }
    board_occupy( self, x, y, p );
    rb_funcall( cells, id_subscript_assign, 2, board_ci( self, x, y ), p );
  }
  return p;
}

VALUE board_set_coord( VALUE self, VALUE c, VALUE p ) {
  if( c == Qnil ) {
    return Qnil;
  }
  
  return board_set( self, rb_funcall( c, id_x, 0 ),
                          rb_funcall( c, id_y, 0 ), 
                          p );
}

VALUE board_in_bounds( VALUE self, VALUE x, VALUE y ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  int h = NUM2INT(rb_iv_get( self, "@height" ));
  int xi = NUM2INT(x);
  int yi = NUM2INT(y);

  if( xi < 0 || xi >= w || yi < 0 || yi >= h ) {
    return Qnil;
  } 
  
  return Qtrue;
}

VALUE board_ci( VALUE self, VALUE x, VALUE y ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  return INT2NUM( NUM2INT(x) + NUM2INT(y) * w );
}

VALUE board_occupy( VALUE self, VALUE x, VALUE y, VALUE p ) {
  VALUE occupied = rb_iv_get( self, "@occupied" );
  VALUE c = rb_funcall( Coord, id_new, 2, x, y );
  VALUE ary = rb_hash_aref( occupied, p );
  if( ary == Qnil ) {
    ary = rb_ary_new();
    rb_ary_push( ary, c );
    rb_hash_aset( occupied, p, ary );
  }
  else {
    rb_ary_push( ary, c );
  }

  return occupied;
}

VALUE board_unoccupy( VALUE self, VALUE x, VALUE y, VALUE p ) {
  VALUE occupied = rb_iv_get( self, "@occupied" );
  VALUE c = rb_funcall( Coord, id_new, 2, x, y );
  VALUE ary = rb_hash_aref( occupied, p );
  rb_funcall( ary, id_delete, 1, c );
  return occupied;
}

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
