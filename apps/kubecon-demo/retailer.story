# Send a connection event so that the controller knows that we're there.
connection_data = json stringify content: {
     "system": "Retailer.Storyscript",
     "organization": "Storyscript Espresso",
     "logo": "https://avatars0.githubusercontent.com/u/34162468?s=400&u=3c1543e329b83a865603cb31da9a0600f4b95a3a&v=4"
}

amqp1 publish_text exchange: "/exchange/amq.fanout"
                   content_type: "application/json; charset=utf-8"
                   properties: {
                        "cloudEvents:id": "03E8B2E8-44A8-4796-ADF4-35D7B7D7D34D",  # todo
                        "cloudEvents:source": "Retailer.Storyscript",
                        "cloudEvents:specversion": "0.3",
                        "cloudEvents:time": "2019-05-10T09:54:58Z",  # todo
                        "cloudEvents:type": "Connection"
                   }
                   content: connection_data

when amqp1 subscribe_text exchange name: "/exchange/amq.fanout" as message
    log info msg: "Incoming message from amq.fanout: {message}"

    if message.properties["cloudEvents:source"] != "Passenger"
        return

    if message.properties["cloudEvents:type"] != "Order.OrderStatus.OrderReleased"
        return

    body = json parse content: message.text
    if body["provider"] != "Retailer.Storyscript"
        return

    log info msg: "We've received an order for us. Yay!"

    # Let's deliver. todo: inventory check
    data = json stringify content: {
         "provider": body["provider"],
         "orderStatus": "OrderDelivered",
         "customer": body["customer"],
         "offer": body["offer"]
    }

    amqp1 publish_text exchange: "/exchange/amq.fanout"
                       content_type: "application/json; charset=utf-8"
                       properties: {
                            "cloudEvents:id": "95825A66-0441-491C-9BBC-DE10300AFCC8",  # todo
                            "cloudEvents:cause": message.properties["cloudEvents:id"],
                            "cloudEvents:specversion": "0.3",
                            "cloudEvents:source": "Retailer.Storyscript",
                            "cloudEvents:time": "2019-04-30T15:54:58Z",  # todo
                            "cloudEvents:subject": message.properties["cloudEvents:subject"],
                            "cloudEvents:type": "Order.OrderStatus.OrderDelivered"
                       }
                       content: data

    log info msg: "Order delivered. Peace out."
