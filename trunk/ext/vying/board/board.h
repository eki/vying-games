#include "ruby.h"


/* Board prototypes */

VALUE Board;

VALUE board_initialize( int argc, VALUE *argv, VALUE self );

VALUE board_subscript( int argc, VALUE *argv, VALUE self );
VALUE board_subscript_assign( int argc, VALUE *argv, VALUE self );

VALUE board_initialize_copy( VALUE self, VALUE obj );
VALUE board_cells( VALUE self );
VALUE board_width( VALUE self );
VALUE board_height( VALUE self );

VALUE board_in_bounds( VALUE self, VALUE x, VALUE y );

VALUE board_get( VALUE self, VALUE x, VALUE y );
VALUE board_set( VALUE self, VALUE x, VALUE y, VALUE p );

VALUE board_get_coord( VALUE self, VALUE c );
VALUE board_set_coord( VALUE self, VALUE c, VALUE p );

VALUE board_ci( VALUE self, VALUE x, VALUE y );
VALUE board_ic( VALUE self, int i );

int board_ix( VALUE self, int i );
int board_iy( VALUE self, int i );

VALUE board_neighbors( VALUE self, int x, int y );

