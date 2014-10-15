#
# Expenses database manager
#
# Update current day expense
# Calculates daily/weekly average
# Fill the un-updated days
#
# harrym 2014
#
#

package require sqlite3


proc update_null {day} {
	dbcmd eval {INSERT INTO daily VALUES(NULL, date($day, '+1 day'), 0)}
}

proc show {} {
	set data [dbcmd eval {SELECT date, amount FROM daily}]
	puts \nDate\t\tAmount
	for {set i 0} {$i < [llength $data] } {incr i 2} {
		set date [lindex $data $i]
		set amount [lindex $data [expr $i+1]]
		puts $date\t$amount\$
	}
}

proc week_avg {today} {
	set cnt [dbcmd eval {SELECT MAX(id) FROM daily}]
	set cnt [expr ($cnt-$cnt%7)/7]
	puts "Weekly average:\n"
	for {set i 0} {$i <= $cnt} {incr i 1} {

		set off [expr 7*$i]
		set off_end [expr $off+6]
		set avg [dbcmd eval {SELECT AVG(amount) FROM( SELECT amount FROM daily LIMIT 7 OFFSET $off)}]
		set avg [format "%.2f" $avg]
		set date_start [dbcmd eval {SELECT date FROM daily LIMIT 1 OFFSET $off}]
		set date_stop [dbcmd eval {SELECT date FROM daily LIMIT 1 OFFSET $off_end}]
		if {[string equal $date_stop {}]} {set date_stop $today}
		puts "From $date_start to $date_stop: $avg\$."
	}
}



#MAIN SCRIPT
set dir [file dirname [info script]]
set datafile [file join $dir expenses.db]
set today [clock format [set systemTime [clock seconds]] -format {%Y-%m-%d}]

if {![file exists $datafile]} {
	sqlite3 dbcmd $datafile -create true -readonly false
	dbcmd eval {CREATE TABLE daily(id INTEGER PRIMARY KEY, date DATE, amount REAL)}
	#dbcmd eval {INSERT INTO daily VALUES(NULL, '2014-09-22', 13)} ONLY FOR TESTING

} else {
	sqlite3 dbcmd $datafile
}
#update with amount=0 the days that were not updated
while {1} {
	set last [dbcmd eval {SELECT day FROM(SELECT MAX(id), date as day from daily)}]

	if {! [string equal $last $today]} {
		update_null $last
		puts "Inserted null record for $last."
	} else {
		break
	}
}

if {$argc eq 0} {
	puts "\nCOMMANDS:\n-a: daily average\n-wa: weekly average\n-s: show all database\nint: insert an expense\n"
} else {
	set arg [lindex $argv 0]
		if {[string equal $arg "-wa"]} {
		week_avg $today
	} elseif {[string equal $arg "-a"]} {
		set da [dbcmd eval {SELECT AVG(amount) from daily}]
		puts [format "Daily average: %.2f\$." $da]
	} elseif {[string equal $arg "-s"]} {
		show
	} else {
		dbcmd eval {UPDATE daily SET amount=$arg WHERE date=$today}
		puts "Inserted $arg\$ for $today."
	}
}

dbcmd close
