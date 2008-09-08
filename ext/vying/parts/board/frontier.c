/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

/*
 *  Updates #frontier for the Frontier plugin.
 */

VALUE frontier_update( VALUE self, VALUE x, VALUE y ) {
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

