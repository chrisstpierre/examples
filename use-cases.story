# Cron Job
when schedule cron daily hour:9
    # do stuff here


# Social media monitoring
when twitter stream tweets track:'#storyscript' as tweet
    sent = machinebox/textbox process input:tweet.text
    if sent.positive
        tweet like



# IoT Streaming
when nest doorbell rings where:'frontdoor'
    twilio sms text:'Someones at the door!' to:'+14151231234'
    

# Websockets
clients = []
websocket server
    when connect as event
        clients append item: event.client
    when disconnect as event
        clients remove item: event.client
    when receives as event
        foreach clients as client
            client send message: event.text


# API's
when http server listen path:'/user' as req
    user = psql exec query:'select ...'
    req write content:user

    
# Automations
when google/docs listener newRowAdded as row
    fc = fullcontact person email:row.cell['email']
    row update cells:{'twitter': fc.twitter}
    

# Chat Ops
when slack bot responds as msg
    ...


# Image Minipluation
when http server listen method:'post' path:'/upload' as req
    dest = '/uploads/{awesome id}.png'
    req write content:{location:dest}
    req finish
    img = imagemagik resize image:req.files['image'] width:50 height:50
    aws/s3 put content:img :dest



###
Machine Learning
###
./gmail/auto-label/app.story

# Backends
...

... 


# CI/CD
jenkins build ...

