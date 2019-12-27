NAME=Minesweeper4i
BIN_LIB=MINE4I
DBGVIEW=*SOURCE
TGTRLS=V7R3M0
SHELL=/QOpenSys/usr/bin/qsh

#----------

all: minefm.dspf mine.rpgle
	@echo "Built all"

#----------

%.dspf:
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QSOURCE) MBR($*) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('QSOURCE/$*.dspf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSOURCE.file/$*.mbr') MBROPT(*REPLACE)"
	system "CRTDSPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QSOURCE) SRCMBR($*) TEXT('$(NAME)')"
	-system -qi "DLTF FILE($(BIN_LIB)/QSOURCE)"
	
%.rpgle:
	liblist -a $(BIN_LIB);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('QSOURCE/$*.rpgle') TEXT('$(NAME)') REPLACE(*YES) DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS))"

clean:
	-system -qi "CRTLIB LIB($(BIN_LIB)) TEXT('$(NAME)')"
	system "CLRLIB LIB($(BIN_LIB))"
