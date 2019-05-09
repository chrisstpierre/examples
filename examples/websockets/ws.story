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
