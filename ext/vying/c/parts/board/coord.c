/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Create a new Coord from the given argument.  
 *
 *  call-seq:
 *    Coord[x,y]
 *    Coord[symbol]
 *    Coord[string] 
 *
 *  If given +x+ and +y+, it is the equivalent to calling new.  If given a
 *  +symbol+ the Symbol will be converted to a String and parsed.  If given
 *  a +string+ the first value is expected to be a letter and the second a
 *  number.  For example, Coord[:a1] would be the equivalent of 
 *  Coord[0,0].
 */

VALUE coord_class_subscript( int argc, VALUE *argv, VALUE self ) {
  VALUE cache, coord, x, y;

  if( argc == 2 && FIXNUM_P(argv[0]) && FIXNUM_P(argv[1]) ) {
    return rb_funcall( Coord, id_new, 2, argv[0], argv[1] );
  }
  else if( argc == 1 ) {
    if( rb_obj_class( argv[0] ) == Coord ) {
      return argv[0];
    }

    cache = rb_cv_get( self, "@@coords_cache" );
    coord = rb_hash_aref( cache, argv[0] );

    if( coord == Qnil ) {
      x = rb_funcall( argv[0], id_x, 0 );
      y = rb_funcall( argv[0], id_y, 0 );

      if( x == Qnil || y == Qnil ) {
        return Qnil;
      }

      coord = rb_funcall( Coord, id_new, 2, x, y );

      rb_hash_aset( cache, argv[0], coord );
    }

    return coord;
  }
  else {
    VALUE cache = rb_cv_get( self, "@@coords_cache" );
    VALUE ary = rb_ary_new2( argc );
    int i;
    for( i = 0; i < argc; i++ ) {
      if( rb_obj_class( argv[i] ) == Coord ) {
        rb_ary_push( ary, argv[i] );
      }
      else {
        VALUE coord = rb_hash_aref( cache, argv[i] );

        if( coord == Qnil ) {
          VALUE x = rb_funcall( argv[i], id_x, 0 );
          VALUE y = rb_funcall( argv[i], id_y, 0 );

          if( x == Qnil || y == Qnil ) {
            coord = Qnil;
          }
          else {
            coord = rb_funcall( Coord, id_new, 2, x, y );
          }

          rb_hash_aset( cache, argv[i], coord );
        }

        rb_ary_push( ary, coord );
      }
    }
    return ary;
  }

  return Qnil;
}

/*
 *  Add coord1 to coord2 to create a new Coord.
 *
 *  call-seq:
 *    coord1 + coord2 -> Coord
 *
 */

VALUE coord_addition( VALUE self, VALUE obj ) {
  return rb_funcall( Coord, id_new, 2,
    INT2NUM(NUM2INT(rb_iv_get(self, "@x"))+NUM2INT(rb_funcall(obj,id_x,0))),
    INT2NUM(NUM2INT(rb_iv_get(self, "@y"))+NUM2INT(rb_funcall(obj,id_y,0))));
}

/*
 *  Calculates and returns the direction from coord1 to coord2.
 *  Directions are only found if there is a straight line between the two
 *  Coord's.
 *
 *  call-seq:
 *    coord1.direction_to( coord2 )  -> direction
 *
 *  The returned +direction+ could be one of keys from Coords::DIRECTIONS
 *  (ie [:n,:s,:e,:w,:nw,:sw,:ne,:se]).
 */

VALUE coord_direction_to( VALUE self, VALUE obj ) {
  int dx = NUM2INT(rb_iv_get(self, "@x"))-NUM2INT(rb_funcall( obj, id_x, 0 ));
  int dy = NUM2INT(rb_iv_get(self, "@y"))-NUM2INT(rb_funcall( obj, id_y, 0 ));

  if( dx == 0 ) {
    if( dy > 0 ) {
      return sym_n;
    }
    else if( dy < 0 ) {
      return sym_s;
    }
  }
  else if( dy == 0 ) {
    if( dx > 0 ) {
      return sym_w;
    }
    else if( dx < 0 ) {
      return sym_e;
    }
  }
  else if( dx == dy ) {
    if( dx < 0 && dy < 0 ) {
      return sym_se;
    }
    else if( dx > 0 && dy > 0 ) {
      return sym_nw;
    }
  }
  else if( -dx == dy ) {
    if( dx > 0 && dy < 0 ) {
      return sym_sw;
    }
    else if( dx < 0 && dy > 0 ) {
      return sym_ne;
    }
  }

  return Qnil;
}

