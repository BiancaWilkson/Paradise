//Directions (already defined on BYOND natively, purely here for reference)
/// define purely for readability, cables especially need to use this as `NO_DIRECTION` represents a "node"
#define NO_DIRECTION 0
//#define NORTH		1
//#define SOUTH		2
//#define EAST		4
//#define WEST		8
//#define NORTHEAST	5
//#define SOUTHEAST 6
//#define NORTHWEST 9
//#define SOUTHWEST 10

/// Using the ^ operator or XOR, we can compared TRUE East and West bits against our direction,
/// since XOR will only return TRUE if one bit is False and the other is True, if East is 0, that bit will return TRUE
/// and if West is 1, then that bit will return 0
/// hence  EAST (0010) XOR EAST|WEST (0011) --> WEST (0001)

///Flips a direction along the horizontal axis, will convert E -> W, W -> E, NE -> NW, SE -> SW, etc
#define FLIP_DIR_HORIZONTALLY(dir) ((dir & (EAST|WEST)) ? dir ^ (EAST|WEST) : dir)
///Flips a direction along the vertical axis, will convert N -> S, S -> N, NE -> SE, SW -> NW, etc
#define FLIP_DIR_VERTICALLY(dir) ((dir & (NORTH|SOUTH)) ? dir ^ (NORTH|SOUTH) : dir)

/// for directions, each cardinal direction only has 1 TRUE bit, so `1000` or `0100` for example, so when you subtract 1
/// from a cardinal direction it results in that directions initial TRUE bit always switching to FALSE, so if you & check it
/// against its initial self, it will return false, indicating that the direction is straight and not diagonal

/// returns TRUE if direction is diagonal and false if not
#define IS_DIR_DIAGONAL(dir) (dir & (dir - 1))
/// returns TRUE if direction is cardinal and false if not
#define IS_DIR_CARDINAL(dir) (!IS_DIR_DIAGONAL(dir))
/// returns TRUE if the direction is EAST or WEST
#define DIR_JUST_HORIZONTAL(dir) ((dir == EAST) || (dir == WEST))
/// returns TRUE if the direction is NORTH or SOUTH
#define DIR_JUST_VERTICAL(dir) ((dir == NORTH) || (dir == SOUTH))
/*
* For getting coordinate signs from a direction define. I.E. NORTHWEST is (-1,1), SOUTH is (0,-1)
* Returns a length 2 list where the first value is the sign of x, and the second is the sign of y
*/
/proc/get_signs_from_direction(direction)
	var/x_sign = 1
	var/y_sign = 1
	x_sign = ((direction & EAST) ? 1 : -1)
	y_sign = ((direction & NORTH) ? 1 : -1)
	if(DIR_JUST_VERTICAL(direction))
		x_sign = 0
	if(DIR_JUST_HORIZONTAL(direction))
		y_sign = 0
	return list(x_sign, y_sign)
