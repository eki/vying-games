#include "ruby.h"


/* OthelloBoard prototypes */

VALUE OthelloBoard;

VALUE othello_board_initialize( VALUE self );
VALUE othello_board_initialize_copy( VALUE self, VALUE obj );
VALUE othello_board_valid( int argc, VALUE *argv, VALUE self );
VALUE othello_board_place( VALUE self, VALUE c, VALUE p );
VALUE othello_board_update_occupied( VALUE self, VALUE x, VALUE y );
VALUE othello_board_update_frontier( VALUE self, VALUE x, VALUE y );
VALUE othello_board_set( VALUE self, VALUE x, VALUE y, VALUE p );

