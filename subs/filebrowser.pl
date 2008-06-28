# Chose a contest from the list of available contests.

use strict;
use warnings;
#use Cwd;

sub filebrowser {

my ($ch, $file, $cwd, $done);
my @files;



my $wmain = newwin(24,80,0,0);
attron($wmain, COLOR_PAIR(4));
addstr($wmain, 0, 0, " " x (24*80));
addstr($wmain, 0, 0, "YFKtest - Open Contest - Please chose a contest file...");

my $wdialog = newwin(20,70,3,5);
attron($wdialog , COLOR_PAIR(5));
addstr($wdialog , 0, 0, " " x (20*70));

refresh($wmain);
refresh($wdialog);

my $x = 0;
my $y = -1;
my $nr = 0;
my $page = 0;
my $activeentry=1;			# nr of the highlighted contest

$cwd = getcwd();

do {
	$y = -1;
	$x = 0;
	$nr = 0;

	@files = ("..", <$cwd/*>);
	addstr($wmain, 2, 0, sprintf("     %-70s", $files[$activeentry-1]));
	refresh($wmain);

	foreach my $file (@files) {
		$nr++;
		$y++;

		$file =~ s#^(.+)/##;	# basename

		if ($y > 19) {			# Check if we need to go to the next column
			$y = 0;
			$x += 1;
		}

		if ($nr == $activeentry) {
			attron($wdialog, COLOR_PAIR(1));
		}
		else {
			attron($wdialog, COLOR_PAIR(5));
		}
		
		addstr($wdialog, $y, ($x*14), substr($file, 0, 13));
		attron($wdialog, COLOR_PAIR(5));
	}
	refresh($wdialog);

#	addstr($wmain, 23, 0, "Contest: $names{$tmp}                           ");
	refresh($wmain);
	
	$ch = getch();


	if (($ch eq KEY_DOWN) && ($activeentry <= $#files)) {
		$activeentry++;
	}
	elsif (($ch eq KEY_UP) && ($activeentry > 1)) {
		$activeentry--;
	}
	elsif (($ch eq KEY_RIGHT) && $#files > ($activeentry + 18)) {
		$activeentry += 20;
	}
	elsif (($ch eq KEY_LEFT) && ($activeentry > 20)) {
		$activeentry -= 20;
	}
	elsif ($ch =~ /\s+/) {
		addstr($wdialog , 0, 0, " " x (20*70));
		if ($activeentry == 1) {			# cd ..
			$cwd =~ s#(/[^\/]+)$##;
		}
		else {
			if (-d $cwd.'/'.$files[$activeentry-1]) {
				$cwd .= "/$files[$activeentry-1]";
				$x = $nr = 0;
				$activeentry = 1;
				$y = -1;
			}
			elsif (-r $cwd.'/'.$files[$activeentry-1]) {
					return $cwd.'/'.$files[$activeentry-1];
			}
		}
	}

} until ("DJ1YFK" eq "LID");



}	# sub filebrowser



return 1;

# Local Variables:
# tab-width:4
# End: **
