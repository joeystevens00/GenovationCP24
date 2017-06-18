## Building  
For the sake of maintainability the CKD file can be generated using the build_macro tool 

### Key files
Each key file inside of the [macro set]_keys directory uses the following syntax   
```# is a comment
%%Level1 starts a level 1 macro block
%Name sets the name of the current block
%%Level1End ends the level 1 block
%%Level2 starts a level 2 macro block
%%Level2End ends the level 2 block
everything else is presumed to be keycodes 
```  

Each key file's name determines its location. e.g. key1, key2, key3 (if in doubt look at the mapping in Genovation MacroMasterCPxx and subtract by 1 as the CKD starts counting at 0).  

## Executing commands when working in multiple machines/OSes  
- Output to Clipboard and "print" with CTRL+V. E.g. `perl -e "use Clipboard; Clipboard->copy(time);"`  
- If going back and forth between linux/windows then change the Run Command shortcut to META+R on linux   
- Longer scripts should be in path on all systems  
- Insert a long delay after META+R (e.g. 500ms - `e2017d`)  
- Use alt-tab after copying to clipboard followed by a long delay as the current window will lose focus  
- If a level modifier (alt, ctrl, shft, meta) key gets pressed (down) double check that it gets unpressed (up) 

### Get current epoch time and paste into current window  
Codes  
`e01f2de2017de0f01f4d242d4b294e24291252f0123c1b24291221f0124b434d32441c2d234c291221f0124b434d32441c2d234e1249f01221444d351246f0122c433a241245f0124c1252f0125a110de2017df011142af014`  
Decoded  
`L Win Dn r Dly 500ms L Win Up p e r l Space - e Space L Shift Dn - L Shift Up u s e Space L Shift Dn C L Shift Up l i p b o a r d ; Space L Shift Dn C L Shift Up l i p b o a r d - L Shift Dn > L Shift Up c o p y L Shift Dn ( L Shift Up t i m e L Shift Dn ) L Shift Up ; L Shift Dn - L Shift Up Enter L Alt Dn Tab Dly 500ms L Alt Up L Ctrl Dn v L Ctrl up`   
   
 Win+R perl with appropriate delays
```
e01f
2d
e2017d
e0f01f
4d242d4b
29
```