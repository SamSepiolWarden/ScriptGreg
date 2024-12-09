import requests

# API endpoint and credentials
api_url = "https://sociabble.with22.glpi-network.cloud/apirest.php"
headers = {
    "Authorization": "user_token YOUR_USER_TOKEN",
    "App-Token": "YOUR_APP_TOKEN",
    "Content-Type": "application/json"
}

# Data to update
data = {
    "input": {
        "name": "Updated Computer Name",
        "serial": "ABC123XYZ",
        "your_custom_field": "New Value"
    }
}

# Make the PUT request
response = requests.put(api_url, json=data, headers=headers)

# Check the response
if response.status_code == 200:
    print("Update successful")
else:
    print(f"Failed to update: {response.text}")
