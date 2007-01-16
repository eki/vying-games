#include "ruby.h"
#include "board.h"

/* Board method definitions */

VALUE board_initialize( int argc, VALUE *argv, VALUE self ) {
  int w, h, i;
  VALUE ary;

  if( argc == 0 ) {
    w = 8;
    h = 8;
  }
  else if( argc == 1 ) {
    w = NUM2INT(argv[0]);
    h = 8;
  }
  else if( argc >= 2 ) {
    w = NUM2INT(argv[0]);
    h = NUM2INT(argv[1]);
  }

  ary = rb_ary_new2( w*h );

  for( i = 0; i < w*h; i++ ) {
    rb_ary_push( ary, Qnil );
  }

  rb_iv_set( self, "@width", INT2NUM(w) );
  rb_iv_set( self, "@height", INT2NUM(h) );
  rb_iv_set( self, "@cells", ary );
}

VALUE board_initialize_copy( VALUE self, VALUE obj ) {
  rb_iv_set( self, "@cells", 
    rb_funcall( rb_iv_get( obj, "@cells" ), rb_intern( "dup" ), 0 ) );
}

VALUE board_cells( VALUE self ) {
  rb_iv_get( self, "@cells" );
}

VALUE board_width( VALUE self ) {
  rb_iv_get( self, "@width" );
}

VALUE board_height( VALUE self ) {
  rb_iv_get( self, "@height" );
}

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
  
  return board_get( self, rb_funcall( c, rb_intern("x"), 0 ),
                          rb_funcall( c, rb_intern("y"), 0 ) );
}

VALUE board_get( VALUE self, VALUE x, VALUE y ) {
  if( RTEST(board_in_bounds( self, x, y )) ) {
    VALUE cells = rb_iv_get( self, "@cells" );
    return rb_funcall( cells, rb_intern("[]"), 1, board_ci( self, x, y ) );
  }
  return Qnil;
}

VALUE board_set( VALUE self, VALUE x, VALUE y, VALUE p ) {
  if( RTEST(board_in_bounds( self, x, y )) ) {
    VALUE cells = rb_iv_get( self, "@cells" );
    rb_funcall( cells, rb_intern("[]="), 2, board_ci( self, x, y ), p );
  }
  return p;
}

VALUE board_set_coord( VALUE self, VALUE c, VALUE p ) {
  if( c == Qnil ) {
    return Qnil;
  }
  
  return board_set( self, rb_funcall( c, rb_intern("x"), 0 ),
                          rb_funcall( c, rb_intern("y"), 0 ), 
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

VALUE board_ic( VALUE self, int i ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  rb_funcall( Coord, rb_intern( "new" ), 2, INT2NUM(i%w), INT2NUM(i/w) );
}

int board_ix( VALUE self, int i ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  return i%w;
}

int board_iy( VALUE self, int i ) {
  int w = NUM2INT(rb_iv_get( self, "@width" ));
  return i/w;
}

VALUE board_neighbors( VALUE self, int x, int y ) {
  return rb_ary_new3( 8,
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x+0), INT2NUM(y+1) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x+0), INT2NUM(y-1) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x+1), INT2NUM(y+0) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x+1), INT2NUM(y+1) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x+1), INT2NUM(y-1) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x-1), INT2NUM(y+0) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x-1), INT2NUM(y+1) ),
    rb_funcall( Coord, rb_intern("new"), 2, INT2NUM(x-1), INT2NUM(y-1) ) );
}
