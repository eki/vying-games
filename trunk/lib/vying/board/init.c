#include "ruby.h"
#include "board.h"
#include "coord.h"

void Init_boardext() {
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

  Board = rb_define_class( "Board", rb_cObject );

  rb_define_method( Board, "initialize", board_initialize, -1 );
  rb_define_method( Board, "initialize_copy", board_initialize_copy, 1 );

  rb_define_method( Board, "cells", board_cells, 0 );
  rb_define_method( Board, "width", board_width, 0 );
  rb_define_method( Board, "height", board_height, 0 );

  rb_define_method( Board, "in_bounds?", board_in_bounds, 2 );

  rb_define_method( Board, "[]", board_subscript, -1 );
  rb_define_method( Board, "[]=", board_subscript_assign, -1 );

  rb_define_method( Board, "get", board_get, 2 );
  rb_define_method( Board, "set", board_set, 3 );

  rb_define_method( Board, "ci", board_ci, 2 );

  rb_define_method( Board, "area", board_area, 0 );
}

