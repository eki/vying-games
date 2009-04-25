/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Are the given coords all connected?  This checks that the list of coords
 *  are connected (in terms of Board#directions and Coords#include?).
 *  
 *  call-seq:
 *    connected?( coords ) -> boolean
 *
 */

VALUE coords_proxy_connected( VALUE self, VALUE cs ) {
  VALUE c = rb_ary_entry( cs, 0 );
  VALUE check = rb_ary_new();
  VALUE coords = rb_ary_dup( cs );
  VALUE ns;
  int i;

  while( RTEST(c) ) {
    rb_ary_delete( coords, c );

    ns = rb_funcall( self, id_neighbors, 1, c );

    for( i = 0; i < RARRAY_LEN(ns); i++ ) {
      VALUE nc = rb_ary_entry( ns, i );

      if( RTEST(rb_ary_includes( coords, nc )) ) {
        rb_ary_push( check, nc );
      }
    }

    c = rb_ary_pop( check );
  }

  return RARRAY_LEN(coords) == 0 ? Qtrue : Qfalse;
}

