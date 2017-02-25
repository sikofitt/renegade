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
{   Renegade is distributed in the hope that it will be }
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

{$I Renegade.Common.Defines.inc}

UNIT SysOp2L;

INTERFACE

PROCEDURE CreditConfiguration;

IMPLEMENTATION

USES
  Common;

PROCEDURE CreditConfiguration;
VAR
  Cmd: Char;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      CLS;
      Print('^5Credit System Configuration:');
      NL;
      PrintACR('^1A. Charge/minute       : ^5'+IntToStr(CreditMinute));
      PrintACR('^1B. Message post        : ^5'+IntToStr(CreditPost));
      PrintACR('^1C. Email sent          : ^5'+IntToStr(CreditEmail));
      PrintACR('^1D. Free time at logon  : ^5'+IntToStr(CreditFreeTime));
      PrintACR('^1E. Internet mail cost  : ^5'+IntToStr(CreditInternetMail));
      Prt('%LFEnter selection [^5A^4-^5E^4,^5Q^4=^5Quit^4]: ');
      OneK(Cmd,'QABCDE'^M,TRUE,TRUE);
      CASE Cmd OF
        'A' : InputIntegerWOC('%LFCredits charged per minute online',CreditMinute,[NumbersOnly],0,32767);
        'B' : InputIntegerWOC('%LFCredits charged per message post',CreditPost,[NumbersOnly],0,32767);
        'C' : InputIntegerWOC('%LFCredits charged per email sent',CreditEmail,[Numbersonly],0,32767);
        'D' : InputIntegerWOC('%LFMinutes to give users w/o credits at logon',CreditFreeTime,[NumbersOnly],0,32767);
        'E' : InputIntegerWOC('%LFCost for Internet mail messages',CreditInternetMail,[NumbersOnly],0,32767);
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
