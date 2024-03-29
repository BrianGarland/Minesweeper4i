NAME=Minesweeper4i
BIN_LIB=MINE4I
DBGVIEW=*SOURCE
TGTRLS=V7R2M0
SHELL=/QOpenSys/usr/bin/qsh

#----------

all: $(BIN_LIB).lib mine.rpgle
	@echo "Built all"

mine.rpgle: minefm.dspf

#----------

%.rpgle:
	liblist -a $(BIN_LIB);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('QSOURCE/$*.rpgle') TEXT('$(NAME)') REPLACE(*YES) DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS))"

%.dspf:
	system "CPYFRMSTMF FROMSTMF('QSOURCE/$*.dspf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSOURCE.file/$*.mbr') MBROPT(*REPLACE)"
	system "CRTDSPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QSOURCE) SRCMBR($*) TEXT('$(NAME)')"
	
%.lib:
	-system -qi "CRTLIB LIB($(BIN_LIB)) TEXT('$(NAME)')"
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QSOURCE) MBR($*) RCDLEN(112)"

clean:
	system "CLRLIB LIB($(BIN_LIB))"

erase:
	-system -qi "DLTLIB LIB($(BIN_LIB))"	
