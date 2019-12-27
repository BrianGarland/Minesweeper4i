**FREE

// Minesweeper4i - This is the traditional minesweeper game for IBM i

// (c)Copyright 2019 Brian J. Garland

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW);

DCL-F MINEFM WORKSTN INFDS(DSPFDS);

DCL-C F3 x'33';
DCL-C F4 x'34';
DCL-C F5 x'35';

DCL-DS DSPFDS;
    FKey CHAR(1) POS(369);
END-DS;

DCL-DS RowDS;
    Row01;
    Row02;
    Row03;
    Row04;
    Row05;
    Row06;
    Row07;
    Row08;
    Row09;
    Row10;
    Row11;
    Row12;
    Row13;
    Row14;
    Row15;
    Row16;
    Row17;
    Row18;
    Row19;
    Rows DIM(19) LIKE(Row01) POS(1);
END-DS;

DCL-DS Board QUALIFIED;
    DCL-DS Row DIM(9);
        Col CHAR(1) DIM(9) INZ('*');
    END-DS;
END-DS;

DCL-DS Mines LIKEDS(Board);

DCL-S CursorCol PACKED(3:0);
DCL-S CursorRow PACKED(3:0);
DCL-S GameOver  IND;


InitBoard();


DOU Fkey = F3;
    DisplayBoard(Fkey:CursorRow:CursorCol);
    IF FKey = F5;
        InitBoard();
    ELSEIF NOT(GameOver);
        CheckMove(CursorRow:CursorCol);
    ENDIF;
ENDDO;


*INLR = *ON;
RETURN;



//------------------------------------------------------------------------------
DCL-PROC InitBoard EXPORT;
DCL-PI *N;
END-PI;

    DCL-PR CEERAN0 EXTPROC('CEERAN0');
        Seed INT(10);
        Rand FLOAT(8);
        FC   CHAR(12);
    END-PR;

    DCL-S C       INT(10);
    DCL-S FC      CHAR(12);
    DCL-S HighVal INT(10) INZ(81);
    DCL-S I       INT(10);
    DCL-S LowVal  INT(10) INZ(1);
    DCL-S R       INT(10);
    DCL-S Rand    FLOAT(8);
    DCL-S Range   INT(10);
    DCL-S Result  INT(10);
    DCL-S Seed    INT(10) INZ(0);

    RESET Board;

    CLEAR Mines;

    Range = (HighVal - LowVal) + 1;
    FOR i = 1 TO 10;
        CEERAN0(seed:rand:FC);
        Result = %INT(rand*range) + LowVal;
        R = %INT(Result/9) + 1;
        C = %REM(Result:9);
        %SUBST(Mines:Result:1) = 'M';
    ENDFOR;

    ErrMsg = '';
    Row = 12;
    Col = 40;

    GameOver = *OFF;
    RETURN;

END-PROC;



//------------------------------------------------------------------------------
DCL-PROC DisplayBoard EXPORT;
DCL-PI *N;
    FunctionKey CHAR(1);
    CursorRow   PACKED(3:0);
    CursorCol   PACKED(3:0);
END-PI;

    DCL-C Border1 '+---+---+---+---+---+---+---+---+---+';
    DCL-C Border2 '|   |   |   |   |   |   |   |   |   |';

    DCL-S i INT(10);
    DCL-S j INT(10);

    FOR i = 1 TO 19 BY 2;
        Rows(i) = Border1;
    ENDFOR;

    FOR i = 1 TO 9;
        Rows(i*2) = Border2;
        FOR j = 1 TO 9;
            %SUBST(Rows(i*2):(j-1)*4+3:1) = Board.Row(i).Col(j);
        ENDFOR;
    ENDFOR;

    EXFMT Level1;

    FunctionKey = FKey;
    CursorRow = Row;
    CursorCol = Col;

    RETURN;

END-PROC;



//------------------------------------------------------------------------------
DCL-PROC CheckMove EXPORT;
DCL-PI *N;
    CursorRow   PACKED(3:0);
    CursorCol   PACKED(3:0);
END-PI;

    DCl-S Col Packed(5:2);
    DCl-S Row Packed(5:2);

    Col = (CursorCol - 24) / 4 + 1;
    IF Col <> %INT(Col);
        Col = 0;
    ENDIF;

    Row = (CursorRow - 4) / 2 + 1;
    IF Row <> %INT(Row);
        Row = 0;
    ENDIF;

    IF Row >= 1 AND Row <= 9 AND Col >= 1 AND Col <= 9;

        CheckCell(row:col);

    ENDIF;

    IF GameOver;
        ErrMsg = 'You hit a mine!  Game over.';
    ENDIF;

    RETURN;

END-PROC;



//------------------------------------------------------------------------------
DCL-PROC CheckCell EXPORT;
DCL-PI *N;
    Row   PACKED(3:0) VALUE;
    Col   PACKED(3:0) VALUE;
END-PI;

    DCL-S #Mines PACKED(1:0);

    IF FKey = F4 AND Board.Row(Row).Col(Col) = '*';
        Board.Row(Row).Col(Col) = '&';
    ELSEIF FKey = F4 AND Board.Row(Row).Col(Col) = '&';
        Board.Row(Row).Col(Col) = '*';
    ELSEIF Mines.Row(Row).Col(Col) = 'M';
        Board.Row(Row).Col(Col) = 'M';
        GameOver = *ON;
    ELSE;
        #Mines = 0;
        IF Row > 1 AND Col > 1 AND Mines.Row(Row-1).Col(Col-1) = 'M';
            #Mines += 1;
        ENDIF;
        IF Row > 1 AND Mines.Row(Row-1).Col(Col) = 'M';
            #Mines += 1;
        ENDIF;
        IF Row > 1 AND Col < 9 AND Mines.Row(Row-1).Col(Col+1) = 'M';
            #Mines += 1;
        ENDIF;
        IF Col > 1 AND Mines.Row(Row).Col(Col-1) = 'M';
            #Mines += 1;
        ENDIF;
        IF Col < 9 AND Mines.Row(Row).Col(Col+1) = 'M';
            #Mines += 1;
        ENDIF;
        IF Row < 9 AND Col > 1 AND Mines.Row(Row+1).Col(Col-1) = 'M';
            #Mines += 1;
        ENDIF;
        IF Row < 9 AND Mines.Row(Row+1).Col(Col) = 'M';
            #Mines += 1;
        ENDIF;
        IF Row < 9 AND Col < 9 AND Mines.Row(Row+1).Col(Col+1) = 'M';
            #Mines += 1;
        ENDIF;
        IF #Mines <> 0;
            Board.Row(Row).Col(Col) = %CHAR(#Mines);
        ELSE;
            Board.Row(Row).Col(Col) = ' ';
        ENDIF;

        IF Board.Row(Row).Col(Col) = ' ';
            CheckNeighbors(Row:Col);
        ENDIF;

    ENDIF;

    RETURN;

END-PROC;



//------------------------------------------------------------------------------
DCL-PROC CheckNeighbors EXPORT;
DCL-PI *N;
    Row   PACKED(3:0) VALUE;
    Col   PACKED(3:0) VALUE;
END-PI;

    IF Row > 1 AND Col > 1 AND (Board.Row(row-1).Col(Col-1) = '*'
                                OR Board.Row(row-1).Col(Col-1) = '&');
        CheckCell(Row-1:Col-1);
    ENDIF;
    IF Row > 1 AND (Board.Row(row-1).Col(Col) = '*'
                    OR Board.Row(row-1).Col(Col) = '&');
        CheckCell(Row-1:Col);
    ENDIF;
    IF Row > 1 AND Col < 9 AND (Board.Row(row-1).Col(Col+1) = '*'
                                OR Board.Row(row-1).Col(Col+1) = '&');
        CheckCell(Row-1:Col+1);
    ENDIF;
    IF Col > 1 AND (Board.Row(row).Col(Col-1) = '*'
                    OR Board.Row(row).Col(Col-1) = '&');
        CheckCell(Row:Col-1);
    ENDIF;
    IF Col < 9 AND (Board.Row(row).Col(Col+1) = '*'
                    OR Board.Row(row).Col(Col+1) = '&');
        CheckCell(Row:Col+1);
    ENDIF;
    IF Row < 9 AND Col > 1 AND (Board.Row(row+1).Col(Col-1) = '*'
                                OR Board.Row(row+1).Col(Col-1) = '&');
        CheckCell(Row+1:Col-1);
    ENDIF;
    IF Row < 9 AND (Board.Row(row+1).Col(Col) = '*'
                    OR Board.Row(row+1).Col(Col) = '&');
        CheckCell(Row+1:Col);
    ENDIF;
    IF Row < 9 AND Col < 9 AND (Board.Row(row+1).Col(Col+1) = '*'
                                OR Board.Row(row+1).Col(Col+1) = '&');
        CheckCell(Row+1:Col+1);
    ENDIF;

    RETURN;

END-PROC;

