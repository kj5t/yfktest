sub colorinfo {

if ($colorscheme == 0) {
	init_pair(1, COLOR_BLACK, COLOR_YELLOW);
	init_pair(2, COLOR_BLUE, COLOR_GREEN);
	init_pair(3, COLOR_BLUE, COLOR_CYAN);
	init_pair(4, COLOR_WHITE, COLOR_BLUE);
	init_pair(5, COLOR_WHITE, COLOR_BLACK);
	init_pair(6, COLOR_WHITE, COLOR_RED);
	}
if ($colorscheme == 1) {
	init_pair(1, COLOR_BLACK, COLOR_YELLOW);
	init_pair(2, COLOR_BLACK, COLOR_GREEN);
	init_pair(3, COLOR_BLACK, COLOR_WHITE);
	init_pair(4, COLOR_WHITE, COLOR_BLUE);
	init_pair(5, COLOR_WHITE, COLOR_BLACK);
	init_pair(6, COLOR_WHITE, COLOR_RED);
	}
if ($colorscheme == 2) {
	init_pair(1, COLOR_BLACK, COLOR_YELLOW);
	init_pair(2, COLOR_BLUE, COLOR_GREEN);
	init_pair(3, COLOR_BLACK, COLOR_YELLOW);
	init_pair(4, COLOR_WHITE, COLOR_BLUE);
	init_pair(5, COLOR_WHITE, COLOR_BLACK);
	init_pair(6, COLOR_WHITE, COLOR_RED);
	}
if ($colorscheme == 3) {
	init_pair(1, COLOR_BLACK, COLOR_YELLOW);
	init_pair(2, COLOR_BLUE, COLOR_GREEN);
	init_pair(3, COLOR_BLUE, COLOR_YELLOW);
	init_pair(4, COLOR_WHITE, COLOR_BLUE);
	init_pair(5, COLOR_WHITE, COLOR_BLACK);
	init_pair(6, COLOR_WHITE, COLOR_RED);
	}

}

return 1;
