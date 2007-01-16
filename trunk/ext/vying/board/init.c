#include "ruby.h"
#include "coord.h"
#include "coords.h"
#include "board.h"
#include "othello.h"

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

  Coords = rb_define_class( "Coords", rb_cObject );
  rb_define_method( Coords, "include?", coords_include, 1 );
  rb_define_method( Coords, "next", coords_next, 2 );

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

  OthelloBoard = rb_define_class( "OthelloBoard", Board );
  rb_define_method( OthelloBoard, "initialize", othello_board_initialize, 0 );
  rb_define_method( OthelloBoard, "initialize_copy", 
    othello_board_initialize_copy, 1 );
  rb_define_method( OthelloBoard, "valid?", othello_board_valid, -1 );
  rb_define_method( OthelloBoard, "place", othello_board_place, 2 );
  rb_define_method( OthelloBoard, "set", othello_board_set, 3 );
}

