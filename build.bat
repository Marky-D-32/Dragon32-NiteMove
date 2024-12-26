SET XROARPATH=C:\Users\Mark\Documents\Emulators\Dragon32\apps\xroar-1.6.3-w64
SET ASMPATH=C:\Users\Mark\Documents\Emulators\Dragon32\apps\asm6809-2.12-w64

SET path=%XROARPATH%;%ASMPATH%

asm6809.exe --dragondos NiteMove.asm -o NiteMove.bin -l NiteMove.lst

xroar.exe -default-machine d32 -rompath %XROARPATH% -run NiteMove.bin
