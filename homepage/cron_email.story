# Send a reminder email once every day.
when cron schedule daily hour:12
    email send from:'admin@example.com' to:'user@example.com' subject:'Reminder!' message:'Reminder message!'
