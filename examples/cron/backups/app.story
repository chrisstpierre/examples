when schedule cron daily hour:9 tz:'UTC'
    ips = postgres run query:'select ips from servers'
    today = date now format:'YYYY-MM-DD'
    foreach ips as ip
        zip = foobar/backupCreator backup :ip
        aws/s3 put content:zip dest:'/backups/{today}/{ip}.zip'
