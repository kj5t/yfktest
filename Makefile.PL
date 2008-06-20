#!/usr/bin/perl

use ExtUtils::MakeMaker;

%opts = (
	 'NAME'		=> 'yfktest',
	 'PREREQ_PM'    => { Curses => 0 },
	 'EXE_FILES'    => [qw(yfktest)],
         'VERSION_FROM' => 'yfktest',         # finds $VERSION
	);

# convert paths from hard-coded /usr/local paths to PREFIX defined
if (!($^O eq 'MSWin32' || $Config{'ccflags'} =~ /-D_?WIN32_?/)) {
    # doesn't work on windows: no sed
    $opts{'PM_FILTER'} = 'sed -e "s|/usr/local|$(PREFIX)|"';
}

WriteMakefile(%opts);

sub MY::postamble {
    return '

YFKTESTDIR=$(DESTDIR)$(PREFIX)/share/yfktest

INSTALL=$(PERL) "-MExtUtils::Command" -e cp

install:: installstuff installfixpaths

installstuff:
	@for dir in livescores defs subs ; do 		\\
        	$(MKPATH) $(YFKTESTDIR)/$$dir ; 		\\
		for i in defs/* ; do  			\\
			$(INSTALL) $$i $(YFKTESTDIR)/$$dir/$$i	; \\
			echo installing $$I in $(YFKTESTDIR)/$$dir/$$i ; \\
		done				;	\\
	done

installfixpaths:
	$(PERL) -p -i -e "s|/usr/local|$(PREFIX)|" $(DISTDIR)$(PREFIX)/bin/yfk
';
}
