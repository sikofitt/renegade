### [2.0.0-dev.1] - 2016-04-05

  * Moved all UpCase function calls to Free Pascal's [UpperCase](http://www.freepascal.org/docs-html/rtl/sysutils/ansiuppercase.html "Free Pascal AnsiUpperCase")

### [2.0.0-dev.2] - 2016-04-06

  * Added Changelog
  * Added Renegade Defines (Renegade.Common.Defines.inc)
  * Removed more {$IFDEF WIN32} blocks.
  * Updated Records to include TargetCPU,  BuildTime, BuildDate and changed OS to be dynamic with FPC %TARGETOS% call.

### [2.0.0-dev.3] - 2016-04-08

  * Added function RandomBytes, to return a specified number of random characters to user in crypto functions.
  * Added php_bcrypt c files for reference when I start writing the bcrypt password functions.

### [2.0.0-dev.4] - 2016-04-12

  * Added a string helper (Renegade.Extension.Strings.pas) to give more OOP functionality.  (AnsiString.toLowerCase, AnsiString.Equals, etc.) ala Java.
  * Added RandomBytes and RandomInt function to unit (Renegade.Random.pas)
<<<<<<< HEAD
  * Updated BCrypt unit.  checking function is timing safe now, inspired by php verify_password function.
  * Added testing framework FPTest

### [2.0.0-dev.5] - 2016-04-15

  * Updated BCrypt unit to stand on its own. (Random Functions)
  * removed php c bcrypt files
  * Switched randomBytes to use /dev/urandom or /dev/random respectively if the os supports it.


=======
  * Updated BCrypt unit.  checking function is timing safe now, inspired by php verify_password function. removed php c bcrypt files.
  * Added testing framework FPTest
>>>>>>> 749009e1abe3608660fb73ca3e4544fe7d856625
