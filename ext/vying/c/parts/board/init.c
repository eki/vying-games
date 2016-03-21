/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"
#include "board.h"

VALUE Board;
VALUE Coord;
VALUE Coords;
VALUE CoordsProxy;
VALUE Plugins;
VALUE Frontier;
VALUE CustodialCapture;

ID id_dup, id_x, id_y, id_subscript, id_subscript_assign, id_new,
   id_hash, id_include, id_n, id_s, id_w, id_e, id_se, id_nw, id_sw, id_ne,
   id_DIRECTIONS, id_directions, id_white, id_black, id_delete, id_uniq_ex,
   id_to_s, id_set, id_before_set, id_after_set, id_first, id_last,
   id_resize_q, id_resize, id_neighbors;


VALUE sym_black, sym_white, 
      sym_n, sym_s, sym_w, sym_e, sym_se, sym_nw, sym_sw, sym_ne;

void Init_boardext() {

  /* Map Coord */

  Coord = rb_define_class( "Coord", rb_cObject );
  
  rb_define_singleton_method( Coord, "[]", coord_class_subscript, -1 );
                                                              /* in coord.c */
  rb_define_method( Coord, "+", coord_addition, 1 );          /* in coord.c */
  rb_define_method( Coord, "direction_to", coord_direction_to, 1 ); 
                                                              /* in coord.c */

  /* Map Coords */

  Coords = rb_define_class( "Coords", rb_cObject );

  rb_define_method( Coords, "include?", coords_include, 1 ); /* in coords.c */
  rb_define_method( Coords, "next", coords_next, 2 );        /* in coords.c */


  /* Map Board */

  Board = rb_define_class( "Board", rb_cObject );

  rb_define_method( Board, "in_bounds?", board_in_bounds, 2 );
                                                              /* in board.c */
  rb_define_method( Board, "[]", board_subscript, -1 );       /* in board.c */
  rb_define_method( Board, "[]=", board_subscript_assign, -1 );
                                                              /* in board.c */
  rb_define_method( Board, "get", board_get, 2 );             /* in board.c */
  rb_define_method( Board, "set", board_set, 3 );             /* in board.c */

  rb_define_private_method( Board, "ci", board_ci, 2 );       /* in board.c */


  /* Map CoordsProxy */

  CoordsProxy = rb_define_class_under( Board, "CoordsProxy", rb_cObject );

  rb_define_method( CoordsProxy, "connected?", coords_proxy_connected, 1 ); 
                                                       /* in coords_proxy.c */


  /* Plugins namespace. */

  Plugins  = rb_define_module_under( Board, "Plugins" );


  /* Map Board::Plugins::Frontier */

  Frontier = rb_define_module_under( Plugins, "Frontier" );

  rb_define_method( Frontier, "update_frontier", frontier_update, 1 );
                                                           /* in frontier.c */

  /* Map Board::Plugins::CustodialCapture */

  CustodialCapture = rb_define_module_under( Plugins, "CustodialCapture" );

  rb_define_method( CustodialCapture, "custodial_capture?", 
                                       custodial_capture_valid, -1 );
                                                  /* in custodial_capture.c */
  rb_define_method( CustodialCapture, "custodial", custodial, -1 );
                                                  /* in custodial_capture.c */

  /* Look up all our ids */

  id_dup = rb_intern("dup");
  id_x = rb_intern("x");
  id_y = rb_intern("y");
  id_subscript = rb_intern("[]");
  id_subscript_assign = rb_intern("[]=");
  id_new = rb_intern("new");
  id_hash = rb_intern("hash");
  id_include = rb_intern("include?");
  id_n = rb_intern("n");
  id_s = rb_intern("s");
  id_w = rb_intern("w");
  id_e = rb_intern("e");
  id_se = rb_intern("se");
  id_nw = rb_intern("nw");
  id_sw = rb_intern("sw");
  id_ne = rb_intern("ne");
  id_DIRECTIONS = rb_intern("DIRECTIONS");
  id_directions = rb_intern("directions");
  id_white = rb_intern("white");
  id_black = rb_intern("black");
  id_delete = rb_intern("delete");
  id_uniq_ex = rb_intern("uniq!");
  id_to_s = rb_intern( "to_s" );
  id_set = rb_intern( "set" );
  id_before_set = rb_intern( "before_set" );
  id_after_set = rb_intern( "after_set" );
  id_first = rb_intern( "first" );
  id_last = rb_intern( "last" );
  id_resize_q = rb_intern( "resize?" );
  id_resize = rb_intern( "resize" );
  id_neighbors = rb_intern( "neighbors" );

  /* Look up all our symbols */

  sym_white = ID2SYM(id_white);
  sym_black = ID2SYM(id_black);
  sym_n = ID2SYM(id_n);
  sym_s = ID2SYM(id_s);
  sym_w = ID2SYM(id_w);
  sym_e = ID2SYM(id_e);
  sym_se = ID2SYM(id_se);
  sym_nw = ID2SYM(id_nw);
  sym_sw = ID2SYM(id_sw);
  sym_ne = ID2SYM(id_ne);

}

