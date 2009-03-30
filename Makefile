Compiler=/opt/iphone-sdk/bin/arm-apple-darwin9-g++
IP=root@ipod

BUNDLEDIR=/Library/MobileSubstrate/DynamicLibraries
BUNDLENAME=CyDelete.bundle

LDFLAGS=	-lobjc \
		-framework Foundation \
		-framework UIKit \
		-framework CoreFoundation \
		-multiply_defined suppress \
		-dynamiclib \
		-init _CyDeleteInitialize \
		-Wall \
		-Werror \
		-lsubstrate \
		-lobjc \
		-ObjC++ \
		-fobjc-exceptions \
		-fobjc-call-cxx-cdtors #-ggdb

CFLAGS= -dynamiclib -DBUNDLE="@\"$(BUNDLEDIR)/$(BUNDLENAME)\""#-ggdb

Objects= Hook.o

Target=CyDelete.dylib
all: CyDelete.dylib setuid

setuid:
		/opt/iphone-sdk/bin/arm-apple-darwin9-gcc -o setuid setuid.c
		CODESIGN_ALLOCATE=/opt/iphone-sdk/bin/arm-apple-darwin9-codesign_allocate ldid -S $@

$(Target):	$(Objects)
		$(Compiler) $(LDFLAGS) -o $@ $^
		CODESIGN_ALLOCATE=/opt/iphone-sdk/bin/arm-apple-darwin9-codesign_allocate ldid -S $@

install: $(Target) setuid
		scp cydelete_$(shell grep Version DEBIAN/control | cut -d' ' -f2).deb $(IP):
		ssh $(IP) dpkg -i cydelete_$(shell grep Version DEBIAN/control | cut -d' ' -f2).deb
		ssh $(IP) killall -HUP SpringBoard

%.o:	%.mm
		$(Compiler) -c $(CFLAGS) $< -o $@

clean:
		rm -f *.o $(Target) setuid

package: $(Target) setuid
	rm -rf _
	svn export layout _
	cp $(Target) _/Library/MobileSubstrate/DynamicLibraries
	cp CyDelete.plist _/Library/MobileSubstrate/DynamicLibraries
	cp setuid _/usr/libexec/cydelete
	rm _$(BUNDLEDIR)/$(BUNDLENAME)/convert.sh
	svn export ./DEBIAN _/DEBIAN
	chown 0.80 _ -R
	chmod 6755 _/usr/libexec/cydelete/setuid
	dpkg-deb -b _ cydelete_$(shell grep Version DEBIAN/control | cut -d' ' -f2).deb

