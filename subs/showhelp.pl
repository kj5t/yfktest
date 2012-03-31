



sub showhelp {
	my ($ch, $help1, $help2) = ('','','');

	$ENV{LANG} =~ /^([a-z]{2})/;
	my $lang = $1;
	$lang ||= 'en';  # avoids empty string perl warnings

	if ($lang eq 'pt') {
		$help1 = 'Referencia rapida ao YFKtest - Premir qualquer tecla para retornar.';
		$help2 = 'Alt-W, F11  Wipe QSO. Apaga indicativo- e muda campos

Alt-X       Para o CW imediatamente (como com o ESC) 

Alt-K       Modo teclado em CW

Alt-R       Grafico de Rate

Alt-M       Editar mensagens CW

F1..7       Mensagens CW como no CT. Podem ser alteradas com Alt-M,
INS         sao escritas no ficheiro do log e respostas quando comeca o
ESC         programa.

10M..160M   Faz com que o YFKtest mude para a banda desejada no campo do
            indicativo.

SSB, CW     Muda para SSB ou CW no campo do indicativo.

WRITELOG    Escreve o log nos formatos Cabrillo e ADIF- para enviar para o
            responsavel do contest e / ou importar para o seu programa de
            logbook/LOTW etc. Tambem um ficheiro de sumario e escrito.
';
	}
	elsif ($lang eq 'es') {
		$help1 = 'Referencia rapida al YFKtest - Pulsar qualquier letra para retornar.';
		$help2 = 'Alt-W, F11  Wipe QSO. Borra indicativo- y cambia campos

Alt-X       Para el CW immediatamiente (como con ESC) 

Alt-K       Modo teclado en CW

Alt-R       Rate Graph

Alt-M       Editar mensagens  CW

F1..7       Mensagens CW como con el CT. Pueden ser cambiadas con Alt-M, y
INS         son escritas en el fichero del log y respuestas quando empienza el
ESC         contest.

10M..160M   Hace que el YFKtest cambie para la banda deseada en el campo del 
            indicativo.

SSB, CW     Cambia la operacion para SSB o CW en el campo del indicativo.

WRITELOG    Escribe el log en formatos Cabrillo y ADIF- para enviar para el 
            responsable del contest y / o importar hasta su programa de 
            logbook/LOTW etc. Tambien un fichero de sumario es escrito.
';
	}
	else {
		$help1 = 'YFKtest Quick Reference - Press **ENTER** to return to logging window.';
		$help2 = "Alt+r           Rate Graph Window.
Alt+c           (Re-)set configuration settings - Window.

F1..9           Play CW messages. - INS, ESC work during sending.
Alt+k           Send CW direct from the keyboard.
Alt+x, ESC      Stops sending CW immediately.
PGUP, PGDN      Change CW speed in 2wpm steps.

Alt+m           Edit CW messages. - Changes are written to the log file.
UP, DOWN        Edit log. DUPECHECKING and WIPEING do not work in edit mode.
Alt+w, F11      Wipe entire QSO.

TAB, SPACEBAR   Move between fields. - TAB can be set to snap to call field.
DEL, BACKSPACE  @ ANY field  - Edit/remove individual characters.
LEFT, RIGHT     @ ANY field  - Move to specific character.
ENTER           @ ANY field  - Log QSO as long as ALL FIELDS are entered.
Alt+l		@ ANY field  - Over-ride protection (if set) & log a DUPE !!

10M..160M       @ Call field - You can directly enter the freq too !!
SSB, CW         @ Call field - RTTY and FM also work.

WRITELOG        @ Call field - Writes Cabrillo, ADIF, & ASCII Summary files.
QUIT, EXIT      @ Call field - Ends program.
";
	}

	curs_set(0);
	my $whelp = newwin(24,80,0,0);
	attron($whelp, COLOR_PAIR(6));
	addstr($whelp , 0,0, ' 'x(24*80));
	attron($whelp, A_BOLD);
	addstr($whelp , 0,0, $help1);
	attroff($whelp, A_BOLD);

	attron($whelp, COLOR_PAIR(5));
	addstr($whelp, 1,0, $help2);

	refresh($whelp);
	$ch = getch() until ($ch =~ /\s+/);

	delwin($whelp);
	curs_set(1);
	return 0;

}



return 1;

# Local Variables:
# tab-width:4
# End: **
