# OnAirMega

OnAirMega is a "simple" powershell script that periodically checks in to multiple web services to use for controlling a Windows machine via multiple addon features such as sounds, gifs, voice, or youtube videos.

Changelog:

0. Needed a simple method to Cenafy people. C3NA.xyz Was born.
1. [Origin] Labs - Onair button  - Airplane Ding = All Clear/Green, Metal Gear Alert = Shutup/RED
2. [PS] Put on tv, browser didn't like autoplay.. Wrote ps script to run in background. PS Script calls New AHK Media script (OnAirPlayer.exe) that plays wav file - Same Files as above
3. [PS] Guys want new tones, Mike figures out how to change the tone by just replacing the alert.wav file with any other file named the same
4. [PS] Guys modify ps script to load a media directory listing into memory on script load, randomly choose sound on each All Clear, same alert tone
5. [PS] Too many replays, script rewrite to make sure it plays all sounds only once until all sounds are played then reloads
6. [PS/WEB] I rewrote script to send last played to alreadydev so we knew what was played
7. [WEB] Added voting system
8. [WEB] Added Spammer button
9. [PS/WEB] Added remote replay ability to powershell script
10. [PS/WEB] Added admin features - Remote Delete file
11. [PS/WEB] Added democracy - If downvotes > $var, remotely delete the file
12. [WEB] Added tagging
13. [WEB] Changed to tabulator
14. [WEB] Added Favorite Button
15. [PS] Force Volume to 100% on script load
16. [SCRIPT] Added GifDisplay.exe (AHK Script that displays a gif in the middle of the screen)
17. [PS] Added Gifs
18. [PS/WEB] Added Remote Stop
19. [PS] Added Remote Gif Feature
20. [WEB] Added Random Gif Button
21. [PS] removed files including _NSFW from autoplay (SFW Mode) [Currently enabled by default]
22. [PS/WEB] Added ability for users to upload file to alreadydev, and powershell script would pull down to the remotebox automatically
23. [PS] Added Network Check Feature
24. [SCRIPT] Added Voice.exe
25. [PS] Added remote talk
26. [WEB] Added Computron Buttons (EightBall)
27. [WEB] Added Computron Console (Raw data entry)
28. [PS/WEB] Added remote rename
29. [WEB] Added if tag=nsfw auto rename file to include _NSFW in name 
30. [WEB] Added RandomFact, CatFacts, TomFact
31. [SCRIPT] Added FullScreenYouTube.exe
32. [PS] Added ability to play full screen YouTube videos remotely


*. Guessing really, as I am not CERTAIN of where things fell into place..
