#include <ncurses.h>


#define PB_WID 20

typedef int pos_t;

pos_t MaxX = 80, MaxY = 25;


struct SegInfo {
	short val = 0;
	int color;
	unsigned short chance = 127;
	float chancedif = 1;
	float speed = 1;
	bool sp = false;
	char text = ' ';
};

namespace SegTypes {
	const struct SegInfo zero {
		.color = C_GREY,
		.text = '0'
	};
	const struct SegInfo p1 {
		.val = 1,
		.color = C_BLUE
	};
	const struct SegInfo p2 {
		.val = 2,
		.color = C_CYAN,
		.text = '2',
		.chance = 85,
		.chancedif = 0.75
	};
	const struct SegInfo p3 {
		.val = 3,
		.color = C_CYAN,
		.text = '3',
		.chance = 64,
		.chancedif = 0.75
	};
	const struct SegInfo all {
		.val = 100,
		.color = C_GREEN,
		.text = '%',
		.chance = 10
	};
	const struct SegInfo n1 {
		.val = -1,
		.color = C_PINK,
		.text = '-',
	};
	const struct SegInfo fatal {
		.sp = true,
		.color = C_RED,
		.text = '!',
		.chance = 32,
		.chancedif = 2
	};
	const struct SegInfo err {
		.sp = true,
		.color = C_ORANGE
	};
	/*const*/ struct SegInfo unk {
		.sp = true,
		.color = C_BLUE
	};
}

typedef struct SegInfo* SegType;

class Seg {
	public:
		SegType type;
		pos_t x, y = 0;

		void frame (void) {
			if (type -> sp) {
				switch (&type) {
					//case &SegInfo::fatal:
					case &SegInfo::unk:
						SegInfo::unk.color = random_color ();
						break;
				}
			}
		}

	private:
		float yspeed;
};

namespace PB {
	WINDOW *Window = NULL;
	SegType Bar [PB_WID + 1];
}



void init (void) {
	initscr ();
	start_color ();
	
	PB::Window = newwin (1,PB_WID, 0,0);
	box (PB::Window, 0,0);
	
	for (size_t i = 0; i != PB_WID; i ++)
		PB::Bar [i] = null;
}



void end (void) {
	endwin ();
}



void partialrefresh (void) {
	refresh ();
}



void fullrefresh (void) {
	getmaxyx (stdscr, MaxY, MaxX);
	
	partialrefresh ();
}

int main (void) {
	init ();
	
	while (true) {
		fullrefresh ();
	}
}
