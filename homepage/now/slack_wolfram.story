# Respond to incoming Slack messages with Wolfram Alpha answers.
when slack bot responds as msg
    msg reply text:(wolfram answer query:msg.text).answer
