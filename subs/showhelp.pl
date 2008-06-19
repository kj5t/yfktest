



sub showhelp {
	my ($ch, $help1, $help2) = ('','','');

	$ENV{LANG} =~ /^([a-z]{2})/;

	if ($1 eq 'pt') {
		$help1 = 'Referência rápida ao YFKtest - Premir qualquer tecla para retornar.';
		$help2 = 'Alt-W, F11  Wipe QSO. Apaga indicativo- e muda campos

Alt-X       Pára o CW imediatamente (como com o ESC) 

Alt-K       Modo teclado em CW

Alt-R       Rate Graph

Alt-M       Editar mensagens CW

F1..7       Mensagens CW como como no CT. Podem ser alteradas com Alt-M,
INS         são escritas no ficheiro do log e respostas quando começa o
ESC         programa.

10M..160M   Faz com que o YFKtest mude para a banda desejada no campo do 
	    indicativo.

SSB, CW     Muda o modo de operação escrivendo SSB/CW no campo do 
	    indicativo.

WRITELOG    Escreve o log nos formatos Cabrillo e ADIF- para enviar para o 
	    responsável do contest e / ou importar para o seu programa de 
	    logbook/LOTW etc. Também um ficheiro de sumário é escrito.
';
	}
	elsif ($1 eq 'es') {
		$help1 = 'Referencia rápida al YFKtest - Pulsar qualquier letra para retornar.';
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

SSB, CW     Cambia el modo de operacion escribindo SSB/CW en el campo del 
	    indicativo.

WRITELOG    Escribe el log en formatos Cabrillo y ADIF- para enviar para el 
	    responsable del contest y / o importar hasta su programa de 
	    logbook/LOTW etc. También un fichero de sumário es escrito.
';
	}
	else {
		$help1 = 'YFKtest Quick Reference - Press any key to return.';
		$help2 = "Alt-W, F11  Wipe QSO. Delete callsign- and exchange fields

Alt-X       Stops CW sending immediately (like ESC) 

Alt-K       Keyboard-Mode in CW

Alt-R       Rate Graph

Alt-M       Edit CW messages

F1..7       CW messages like in CT. They can be modified by Alt-M, and
INS         are written to the log file and restored when restarting the
ESC         contest.

10M..160M   Entering the desired band in the callsign-field causes YFKtest to
            QSY.

SSB, CW     Change the mode my entering SSB/CW in the callsign field.

WRITELOG    Writes the log in Cabrillo- and ADIF-Format for submission to the
            log-checker and / or import to your main logbook/LOTW etc.
            Also a summary file of the contest score is written to a file.
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
	addstr($whelp, 2,0, $help2);

	refresh($whelp);
	$ch = getch() until ($ch =~ /\s+/);

	delwin($whelp);
	curs_set(1);
	return 0;

}



return 1;
