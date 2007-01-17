#include "ruby.h"


/* Classes */

VALUE Board;
VALUE Coord;
VALUE Coords;
VALUE OthelloBoard;

/* Board prototypes */

VALUE board_subscript( int argc, VALUE *argv, VALUE self );
VALUE board_subscript_assign( int argc, VALUE *argv, VALUE self );

VALUE board_initialize_copy( VALUE self, VALUE obj );

VALUE board_in_bounds( VALUE self, VALUE x, VALUE y );

VALUE board_get( VALUE self, VALUE x, VALUE y );
VALUE board_set( VALUE self, VALUE x, VALUE y, VALUE p );

VALUE board_get_coord( VALUE self, VALUE c );
VALUE board_set_coord( VALUE self, VALUE c, VALUE p );

VALUE board_ci( VALUE self, VALUE x, VALUE y );

VALUE board_neighbors( VALUE self, int x, int y );


/* Coord prototypes */

VALUE coord_initialize( VALUE self, VALUE x, VALUE y );
VALUE coord_x( VALUE self );
VALUE coord_y( VALUE self );
VALUE coord_class_subscript( int argc, VALUE *argv, VALUE self );
VALUE coord_hash( VALUE self );
VALUE coord_equals( VALUE self, VALUE obj );
VALUE coord_addition( VALUE self, VALUE obj );
VALUE coord_direction_to( VALUE self, VALUE obj );


/* Coords prototypes */

VALUE coords_include( VALUE self, VALUE c );
VALUE coords_next( VALUE self, VALUE c, VALUE d );


/* OthelloBoard prototypes */

VALUE othello_board_initialize( VALUE self );
VALUE othello_board_initialize_copy( VALUE self, VALUE obj );
VALUE othello_board_valid( int argc, VALUE *argv, VALUE self );
VALUE othello_board_place( VALUE self, VALUE c, VALUE p );
VALUE othello_board_update_occupied( VALUE self, VALUE x, VALUE y );
VALUE othello_board_update_frontier( VALUE self, VALUE x, VALUE y );
VALUE othello_board_set( VALUE self, VALUE x, VALUE y, VALUE p );

/* IDs */

ID id_dup, id_x, id_y, id_subscript, id_subscript_assign, id_new,
   id_hash, id_n, id_s, id_w, id_e, id_se, id_nw, id_sw, id_ne,
   id_DIRECTIONS, id_white, id_black, id_delete, id_uniq_ex;

/* SYMs */

VALUE sym_black, sym_white, 
      sym_n, sym_s, sym_w, sym_e, sym_se, sym_nw, sym_sw, sym_ne;

