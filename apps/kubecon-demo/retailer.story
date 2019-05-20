function get_cup_iv_key size: string returns string
    return "inventory_cups_{size}"

function request_for_more_cups size: string
    content = json stringify content: {
        "orderStatus": "OrderReleased",
        "customer": "Retailer.Storyscript",
        "offer": size
    }
    amqp1 publish_text exchange: "/exchange/amq.fanout"
                       content_type: "application/json; charset=utf-8"
                       properties: {
                            "cloudEvents:id": "03E8B2E8-44A8-4796-ADF4-35D7B7D7D34D",  # todo
                            "cloudEvents:source": "Retailer.Storyscript",
                            "cloudEvents:specversion": "0.3",
                            "cloudEvents:time": "2019-05-10T09:54:58Z",  # todo
                            "cloudEvents:type": "Order.OrderStatus.OrderReleased",
                            "cloudEvents:subject": "7a9c0408-b17a-4c63-bbe0-a5b6f3c62695"  # todo - what should this be set to?
                       }
                       content: content

function publish_inventory size: string cups: int
    data = json stringify content: {
        "offer": size,
        "inventoryLevel": cups
    }

    amqp1 publish_text exchange: "/exchange/amq.fanout"
                       content_type: "application/json; charset=utf-8"
                       properties: {
                            "cloudEvents:id": "95825A66-0441-491C-9BBC-DE10300AFCC8",  # todo
                            "cloudEvents:specversion": "0.3",
                            "cloudEvents:source": "Retailer.Storyscript",
                            "cloudEvents:time": "2019-04-30T15:54:58Z",  # todo
                            "cloudEvents:subject": size,
                            "cloudEvents:type": "Offer.InventoryLevel"
                       }
                       content: data


function register
    # Send a connection event so that the controller knows that we're there.
    connection_data = json stringify content: {
         "system": "Retailer.Storyscript",
         "organization": "Storyscript Esp.",
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

    # Bootstrap our inventory of cups.
    redis set key: get_cup_iv_key(size: "small") value: 3
    redis set key: get_cup_iv_key(size: "medium") value: 3
    redis set key: get_cup_iv_key(size: "large") value: 3

    publish_inventory(size:"small" cups: 3)
    publish_inventory(size:"medium" cups: 3)
    publish_inventory(size:"large" cups: 3)

# For the first time.
register()

when http server listen path: "/register"
    register()

when http server listen path: "/reset"
    amqp1 publish_text exchange: "/exchange/amq.fanout"
                       content_type: "application/json; charset=utf-8"
                       properties: {
                            "cloudEvents:id": "03E8B2E8-44A8-4796-ADF4-35D7B7D7D34D",  # todo
                            "cloudEvents:source": "Retailer.Storyscript",
                            "cloudEvents:specversion": "0.3",
                            "cloudEvents:time": "2019-05-10T09:54:58Z",  # todo
                            "cloudEvents:type": "Reset"
                       }
    register()

when amqp1 subscribe_text exchange name: "/exchange/amq.fanout" as message
    log info msg: "Incoming message from amq.fanout: {message}"
    event_type = message.properties["cloudEvents:type"]

    if event_type == "Disconnect" or event_type == "Reset"
        cause = message.properties["cloudEvents:cause"]
        log error msg: "We got disconnected! cloudEvents:cause = {cause}"
        register()
        return

    body = json parse content: message.text


    if event_type == "TransferAction.ActionStatus.CompletedActionStatus" and body["toLocation"] == "Retailer.Storyscript"
        redis set key: get_cup_iv_key(size: body["offer"]) value: 3
        publish_inventory(size: body["offer"] cups: 3)
        return
    else if event_type != "Order.OrderStatus.OrderReleased"
        return

    if message.properties["cloudEvents:source"] != "Passenger"
        return

    
    if body["provider"] != "Retailer.Storyscript"
        return

    log info msg: "We've received an order for us. Yay!"

    # Inventory check.
    int cups_available = (redis get key: get_cup_iv_key(size: body["offer"])).result as int
    if cups_available <= 1
        request_for_more_cups(size: body["offer"])
        cups_available = 1  # To prevent it from being set to a -ve value.

    cups_available = cups_available - 1
    redis set key: get_cup_iv_key(size: body["offer"]) value: cups_available

    # Let's deliver.
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
    
    # Also notify the controller about our inventory level.
    publish_inventory(size: body["offer"] cups: cups_available)

    log info msg: "Order delivered. Peace out."
