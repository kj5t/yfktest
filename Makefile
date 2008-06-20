VERSION=0.0.10

clean:
	rm -f *~ *.yfk *.yfk~ *.yfk.cbr* *.yfk.adi* *.sum

dist:
	sed 's/Version [0-9].[0-9].[0-9]/Version $(VERSION)/g' README > README2
	rm -f README
	mv README2 README
	sed 's/Version [0-9].[0-9].[0-9]/Version $(VERSION)/g' MANUAL > MANUAL2
	rm -f MANUAL
	mv MANUAL2 MANUAL
	rm -f releases/yfktest-$(VERSION).tar.gz
	rm -rf releases/yfktest-$(VERSION)
	mkdir yfktest-$(VERSION)
	mkdir yfktest-$(VERSION)/defs/
	mkdir yfktest-$(VERSION)/subs/
	cp ChangeLog yfktest.pl hamlibrigs friend.ini master.scp cty.dat README COPYING MANUAL INSTALL \
			yfktest-$(VERSION)
	cp defs/*.def yfktest-$(VERSION)/defs/
	cp subs/*.pl yfktest-$(VERSION)/subs/
	tar -zcf yfktest-$(VERSION).tar.gz yfktest-$(VERSION)
	mv yfktest-$(VERSION) releases/
	mv yfktest-$(VERSION).tar.gz releases/
	md5sum releases/*.gz > releases/md5sums.txt
	chmod a+r releases/*
