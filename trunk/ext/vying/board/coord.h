#include "ruby.h"


/* Coord prototypes */

VALUE Coord;

VALUE coord_initialize( VALUE self, VALUE x, VALUE y );
VALUE coord_x( VALUE self );
VALUE coord_y( VALUE self );
VALUE coord_class_subscript( int argc, VALUE *argv, VALUE self );
VALUE coord_hash( VALUE self );
VALUE coord_equals( VALUE self, VALUE obj );
VALUE coord_addition( VALUE self, VALUE obj );
VALUE coord_direction_to( VALUE self, VALUE obj );

