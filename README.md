tcl_expenses
============

Tcl/SQLite3 Expenses Manager

Just an exercise to start learning Tcl. 

Every record in the database is composed ot the date and the amount spent in that day. The script does the following:
- if the last date inserted is not today, fill up the database up to the current date (with amount=0$)
- update the current day's expense
- print all the database
- print the daily average
- print the weekly average

The Tcl script interfaces to the database with SQLite3; expenses.db is an example database.
