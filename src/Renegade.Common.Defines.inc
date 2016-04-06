{*******************************************************}
{                                                       }
{   Renegade BBS                                        }
{                                                       }
{   Copyright (c) 1990-2013 The Renegade Dev Team       }
{   Copyleft  (ↄ) 2016 Renegade BBS                     }
{                                                       }
{   This file is part of Renegade BBS                   }
{                                                       }
{   Renegade is free software: you can redistribute it  }
{   and/or modify it under the terms of the GNU General }
{   Public License as published by the Free Software    }
{   Foundation, either version 3 of the License, or     }
{   (at your option) any later version.                 }
{                                                       }
{   Foobar is distributed in the hope that it will be   }
{   useful, but WITHOUT ANY WARRANTY; without even the  }
{   implied warranty of MERCHANTABILITY or FITNESS FOR  }
{   A PARTICULAR PURPOSE.  See the GNU General Public   }
{   License for more details.                           }
{                                                       }
{   You should have received a copy of the GNU General  }
{   Public License along with Renegade.  If not, see    }
{   <http://www.gnu.org/licenses/>.                     }
{                                                       }
{*******************************************************}
{   _______                                  __         }
{  |   _   .-----.-----.-----.-----.---.-.--|  .-----.  }
{  |.  l   |  -__|     |  -__|  _  |  _  |  _  |  -__|  }
{  |.  _   |_____|__|__|_____|___  |___._|_____|_____|  }
{  |:  |   |                 |_____|                    }
{  |::.|:. |                                            }
{  `--- ---'                                            }
{*******************************************************}

{ Defines for Renegade BBS }

{$APPTYPE console}
{$DESCRIPTION Renegade Bulletin Board System}
{$MODE objfpc}

{$A+} { Align Data for faster execution }
{$B-} { Shortcut Boolean eval }

{$IFDEF RENEGADE_DEBUG}
{$D+} { Debug Info // for Turbo Pascal this switch is reversed. }
{$ENDIF}

{ Not supported on *nix systems}
{$IFNDEF UNIX} {$E-} { No Math-Co library } {$ENDIF}

{$I-} { Disable I/O checking }

{
  Optimization
  In turbo pascal this was to enable overlays,
  since we live in the year 2016, we don't need this.
  ORDERFIELDS - Reorder fields if this results in better alignment.
  REGVAR      - Use register variables.
  SIZE        - Optimize for size.
  LEVEL2      - Level 2 optimizations, Enables the assembler data flow analyzer,
     which allows the common subexpression elimination procedure to
     remove unnecessary reloads of registers with values they already
     contain.
}
{$O ORDERFIELDS,REGVAR,SIZE,LEVEL2}


{$Q-} { No overflow check // Possibly turn this on at a later date. Error code 215 }
{$R-} { No range check // Possibly turn this on at a later date. Error code 201
        See http://www.freepascal.org/docs-html/prog/progsu65.html#x72-710001.2.65,
        Probably a good idea to turn this on. }

{$IFDEF RENEGADE_DEBUG}
{$S+}              { Check stack usage // By default this is off. }
{$CHECKPOINTER ON} { Heep pointer checking, see
                     http://www.freepascal.org/docs-html/prog/progsu8.html#x15-140001.2.8 }
{$IEEEERRORS ON}   { IEEE (floating point) error checking for constants. }
{$ENDIF}

{$V-} { Variable string Length allowed }
{$X+} { Allow extended syntax, Meaning we can call functions as procedures.
        See http://www.freepascal.org/docs-html/prog/progsu125.html#x133-1340001.3.42
        for solid reasoning.  This is the default, but we will set it anyway. }
{$H-} { AnsiStrings Off }
{$J+} { Allow assignments to typed constants // Default setting }
{$PACKRECORDS 1} { Compatability with old Turbo Pascal records.
                   This means we won't have to rewrite all data files. }
{$OBJECTCHECKS OFF} { This is the default, but lets make sure.
                      See http://www.freepascal.org/docs-html/prog/progsu57.html#x64-630001.2.57 }
