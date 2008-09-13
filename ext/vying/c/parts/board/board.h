/* Copyright 2007, Eric Idema except where otherwise noted.
 * You may redistribute / modify this file under the same terms as Ruby.
 */

#include "ruby.h"

/* Classes and Modules */

VALUE Board;
VALUE Coord;
VALUE Coords;
VALUE Plugins;
VALUE Frontier;
VALUE CustodialFlip;


/* Board prototypes */

VALUE board_subscript( int argc, VALUE *argv, VALUE self );
VALUE board_subscript_assign( int argc, VALUE *argv, VALUE self );

VALUE board_in_bounds( VALUE self, VALUE x, VALUE y );

VALUE board_get( VALUE self, VALUE x, VALUE y );
VALUE board_set( VALUE self, VALUE x, VALUE y, VALUE p );

VALUE board_get_coord( VALUE self, VALUE c );
VALUE board_set_coord( VALUE self, VALUE c, VALUE p );

VALUE board_occupy( VALUE self, VALUE x, VALUE y, VALUE p );
VALUE board_unoccupy( VALUE self, VALUE x, VALUE y, VALUE p );

VALUE board_ci( VALUE self, VALUE x, VALUE y );

VALUE board_neighbors( VALUE self, int x, int y );


/* Coord prototypes */

VALUE coord_class_subscript( int argc, VALUE *argv, VALUE self );
VALUE coord_addition( VALUE self, VALUE obj );
VALUE coord_direction_to( VALUE self, VALUE obj );

/* Coords prototypes */

VALUE coords_include( VALUE self, VALUE c );
VALUE coords_next( VALUE self, VALUE c, VALUE d );


/* Frontier prototypes */

VALUE frontier_update( VALUE self, VALUE c );


/* CustodialFlip prototypes */

VALUE custodial_flip_valid( VALUE self, VALUE c, VALUE p );
VALUE custodial_flip( VALUE self, VALUE c, VALUE p );


/* IDs */

ID id_dup, id_x, id_y, id_subscript, id_subscript_assign, id_new,
   id_hash, id_include, id_n, id_s, id_w, id_e, id_se, id_nw, id_sw, id_ne,
   id_DIRECTIONS, id_directions, id_white, id_black, id_delete, id_uniq_ex,
   id_to_s, id_before_set, id_after_set;


/* SYMs */

VALUE sym_black, sym_white, 
      sym_n, sym_s, sym_w, sym_e, sym_se, sym_nw, sym_sw, sym_ne;

