from json import dumps
from firebase_functions import https_fn
from firebase_admin import initialize_app, messaging

initialize_app()

@https_fn.on_request()
def send_notification(req: https_fn.Request) -> https_fn.Response:
    try:
        req_body = req.get_json()

        # Check if the request body is empty
        if not req_body:
            return https_fn.Response("Invalid request body", status=400)
        
        # Check if the request body contains the required fields
        if 'device_token' not in req_body:
            return https_fn.Response("Invalid request body. 'device_token' is required.", status=400)

        if 'payload' not in req_body:
            return https_fn.Response("Invalid request body. 'payload' is required.", status=400)

        # Getting the device token from the request body
        device_token = req_body['device_token']

        # Get the payload for the notification
        payload = req_body['payload']

        # Overwrite the 'extra' field with the JSON string. 
        # This is required because FCM requires the data parameter to be a dictionary
        # of string values only.
        if 'extra' in payload:
            payload['extra'] = dumps(payload['extra'])

        # Create the message that needs to be sent to the device
        message = messaging.Message(
            data=payload,
            token=device_token,
        )

        # Send the message to the device
        message_id =  messaging.send(message)

        return https_fn.Response(f"Message sent successfully. Message ID={message_id}")
    except Exception as e:
        return https_fn.Response(f"An error occurred: {e}", status=500)
