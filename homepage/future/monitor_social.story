# Social media monitoring.
when twitter stream tweets track:'#storyscript' as tweet
    sent = machinebox/textbox process input:tweet.text
    if sent.positive
        tweet like
