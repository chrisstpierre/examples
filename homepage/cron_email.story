# Send a reminder email once every day.
cron schedule as client
  when client daily hour:12
    email send from:'admin@example.com' to:'user@example.com' subject:'Reminder!' message:'Reminder message!'
