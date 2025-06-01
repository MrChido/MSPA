This is the app that my wife wants to use to track how she feels
It is meant to record her fatigue, her pain,
A scale from 1-10 of her pain threshold
As well as documenting her sleeping hours, her blood readings,
medications and meals that she is taking
and what her activities are

I am sure  this is the very basic level of what  she wants out of this app.

As of right now, it only shows 30 days being selectable at a time. 

The next steps are: 
Completing the database entry *done*
retrieving the database entries into a display
refining a few of the aesthetics *in progress*
ensuring compatibility with devices ( using my Pixel 8 Pro, Her Galaxy 24, and quite possibly the nieces Iphone*)

Program dev timeline

5/13/2025
Project started, took the ChatGPT Seed from Melissa and started to code, running into a few name usage errors
also ran into some numbering issues on the display

5/22/2025
Name usage errors resolved, current display issues resolved, began implementation of database usage from entry storage.

5/25/2025
All current database fields are satisfied. I noticed that there is no DB field for Wake and sleep, but that will be added soon.
Wife also wants a symptom field, easily added. New dB will need to be created and linked; that is fine. 

5/29/2025
Wake, Sleep, and symptom fields now report to the database. I had to recreate the database from scratch, apparently, SQLite doesn't like
appending databases mid-project. Something to remember the next time I use SQLite. I also ensured that 2 formatting instances are
accepted in the wake/time fields. using either : or .
Also, I added code to ensure that when somebody enters am or pm that it is evaluated in the 24-hour cycle, preparing for future math as needed.
Planning the implementation of database entry review practices.

6/1/2025
Development is slowing down, right now I need to focus on finding employment, This project is still moving forward, just at a slower pace.
Today a button was added to trigger a app shift into "review mode" and some of the white space was adressed. More development will happen after i get a few hours of
doordashing In.

*that will take some research
Due to the resulting research, iOS implementation is not feasible due to cost.
