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