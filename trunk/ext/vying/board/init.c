#include "ruby.h"
#include "board.h"

void Init_boardext() {

  /* Map Coord */

  Coord = rb_define_class( "Coord", rb_cObject );

  rb_define_method( Coord, "initialize", coord_initialize, 2 );
  rb_define_method( Coord, "x", coord_x, 0 );
  rb_define_method( Coord, "y", coord_x, 0 );
  rb_define_singleton_method( Coord, "[]", coord_class_subscript, -1 );
  rb_define_method( Coord, "hash", coord_hash, 0 );
  rb_define_method( Coord, "==", coord_equals, 1 );
  rb_define_method( Coord, "eql?", coord_equals, 1 );
  rb_define_method( Coord, "+", coord_addition, 1 );
  rb_define_method( Coord, "direction_to", coord_direction_to, 1 );

  /* Map Coords */

  Coords = rb_define_class( "Coords", rb_cObject );

  rb_define_method( Coords, "include?", coords_include, 1 );
  rb_define_method( Coords, "next", coords_next, 2 );

  /* Map Board */

  Board = rb_define_class( "Board", rb_cObject );

  rb_define_method( Board, "in_bounds?", board_in_bounds, 2 );

  rb_define_method( Board, "[]", board_subscript, -1 );
  rb_define_method( Board, "[]=", board_subscript_assign, -1 );

  rb_define_method( Board, "get", board_get, 2 );
  rb_define_method( Board, "set", board_set, 3 );

  rb_define_method( Board, "ci", board_ci, 2 );

  /* Map OthelloBoard */

  OthelloBoard = rb_define_class( "OthelloBoard", Board );

  rb_define_method( OthelloBoard, "valid?", othello_board_valid, -1 );
  rb_define_method( OthelloBoard, "place", othello_board_place, 2 );
  rb_define_method( OthelloBoard, "set", othello_board_set, 3 );

  /* Look up all our ids */

  id_dup = rb_intern("dup");
  id_x = rb_intern("x");
  id_y = rb_intern("y");
  id_subscript = rb_intern("[]");
  id_subscript_assign = rb_intern("[]=");
  id_new = rb_intern("new");
  id_hash = rb_intern("hash");
  id_n = rb_intern("n");
  id_s = rb_intern("s");
  id_w = rb_intern("w");
  id_e = rb_intern("e");
  id_se = rb_intern("se");
  id_nw = rb_intern("nw");
  id_sw = rb_intern("sw");
  id_ne = rb_intern("ne");
  id_DIRECTIONS = rb_intern("DIRECTIONS");
  id_white = rb_intern("white");
  id_black = rb_intern("black");
  id_delete = rb_intern("delete");
  id_uniq_ex = rb_intern("uniq!");

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

