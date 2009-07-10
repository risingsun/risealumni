#!/bin/sh
cd $1
./script/runner "Greeting.new.day_greetings" -e production
./script/runner "DailyReport.daily_signup_report" -e production