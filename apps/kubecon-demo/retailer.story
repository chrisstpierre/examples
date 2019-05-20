function get_cup_iv_key size: string returns string
    return "inventory_cups_{size}"

function publish_event event_type: string content: any subject: string cause: string
    if content != null
        content = json stringify content: content

    props = {
         "cloudEvents:id": uuid generate,
         "cloudEvents:source": "Retailer.Storyscript",
         "cloudEvents:specversion": "0.3",
         "cloudEvents:time": "2019-05-10T09:54:58Z",  # todo
         "cloudEvents:type": event_type,
         "cloudEvents:subject": subject,
         "cloudEvents:cause": cause
    }
#     if subject != null
#         props["cloudEvents:subject"] = subject

    amqp1 publish_text exchange: "/exchange/amq.fanout"
                       content_type: "application/json; charset=utf-8"
                       properties: props
                       content: content

function request_for_more_cups size: string
    content = {
        "orderStatus": "OrderReleased",
        "customer": "Retailer.Storyscript",
        "offer": size
    }

    publish_event(event_type: "Order.OrderStatus.OrderReleased" subject: size content: content cause: null)

function publish_inventory size: string cups: int cause: string
    data = {
        "offer": size,
        "inventoryLevel": cups
    }
    publish_event(event_type: "Offer.InventoryLevel" subject: size content: data cause: cause)


function register
    # Send a connection event so that the controller knows that we're there.
    connection_data = {
         "system": "Retailer.Storyscript",
         "organization": "Storyscript Esp.",
         "logo": "https://avatars0.githubusercontent.com/u/34162468?s=400&u=3c1543e329b83a865603cb31da9a0600f4b95a3a&v=4"
    }

    publish_event(event_type: "Connection" subject: null content: connection_data cause: null)

    # Bootstrap our inventory of cups.
    redis set key: get_cup_iv_key(size: "small") value: 3
    redis set key: get_cup_iv_key(size: "medium") value: 3
    redis set key: get_cup_iv_key(size: "large") value: 3

    publish_inventory(size:"small" cups: 3 cause: null)
    publish_inventory(size:"medium" cups: 3 cause: null)
    publish_inventory(size:"large" cups: 3 cause: null)

# For the first time.
register()

when http server listen path: "/register"
    register()

when http server listen path: "/reset"
    publish_event(event_type: "Reset" subject: null content: null cause: null)
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
        publish_inventory(size: body["offer"] cups: 3 cause: message.properties["cloudEvents:id"])
        return
    else if event_type != "Order.OrderStatus.OrderReleased"
        return

    if message.properties["cloudEvents:source"] != "Passenger"
        return

    
    if body["provider"] != "Retailer.Storyscript"
        return

    log info msg: "We've received an order for us. Yay! {message}"

    # Inventory check.
    int cups_available = (redis get key: get_cup_iv_key(size: body["offer"])).result as int

    cups_available = cups_available - 1

    if cups_available <= 1
            request_for_more_cups(size: body["offer"])
            cups_available = 1  # To prevent it from being set to a -ve value.

    redis set key: get_cup_iv_key(size: body["offer"]) value: cups_available

    # Let's deliver.
    data = {
         "provider": body["provider"],
         "orderStatus": "OrderDelivered",
         "customer": body["customer"],
         "offer": body["offer"]
    }

    publish_event(event_type: "Order.OrderStatus.OrderDelivered" subject: message.properties["cloudEvents:subject"] content: data cause: message.properties["cloudEvents:id"])
    
    # Also notify the controller about our inventory level.
    publish_inventory(size: body["offer"] cups: cups_available cause: null)

    log info msg: "Order delivered. Peace out."
