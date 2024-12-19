import requests
import json
from datetime import datetime
import sys
from msgraph.core import GraphClient
from azure.identity import DeviceCodeCredential

class GLPIApi:
    def __init__(self, url, app_token, user_token):
        self.url = url.rstrip('/')
        self.app_token = app_token
        self.user_token = user_token
        self.session_token = None

    def init_session(self):
        """Initialize GLPI session"""
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'user_token {self.user_token}',
            'App-Token': self.app_token
        }

        try:
            response = requests.get(
                f'{self.url}/initSession',
                headers=headers
            )
            response.raise_for_status()
            self.session_token = response.json()['session_token']
            print("GLPI Session initialized successfully")
            return True
        except Exception as e:
            print(f"Failed to initialize GLPI session: {str(e)}")
            return False

    def get_states(self):
        """Get GLPI states"""
        if not self.session_token:
            print("No session token available")
            return None

        headers = {
            'Session-Token': self.session_token,
            'App-Token': self.app_token
        }

        try:
            response = requests.get(
                f'{self.url}/State',
                headers=headers
            )
            response.raise_for_status()
            states = response.json()
            
            print("\nAvailable GLPI States:")
            print("------------------------")
            spare_state = None
            for state in states:
                if state['name'] == "Spare":
                    print(f"ID: {state['id']} - Name: {state['name']} (Spare State)")
                    spare_state = state
                else:
                    print(f"ID: {state['id']} - Name: {state['name']}")
            
            return states, spare_state
        except Exception as e:
            print(f"Failed to get GLPI states: {str(e)}")
            return None, None

    def update_computer_status(self, serial_number, device_name, spare_state_id):
        """Update computer status to spare"""
        if not self.session_token:
            print("No session token available")
            return False

        headers = {
            'Session-Token': self.session_token,
            'App-Token': self.app_token,
            'Content-Type': 'application/json'
        }

        try:
            # First search for the computer
            search_params = {
                'is_deleted': 0,
                'as_map': 0,
                'criteria[0][field]': 5,
                'criteria[0][searchtype]': 'equals',
                'criteria[0][value]': serial_number
            }
            
            response = requests.get(
                f'{self.url}/search/Computer',
                headers=headers,
                params=search_params
            )
            response.raise_for_status()
            search_result = response.json()

            if search_result.get('data') and len(search_result['data']) > 0:
                computer_id = search_result['data'][0][2]  # Adjust field number if needed
                
                # Update computer status
                data = {
                    "input": {
                        "id": computer_id,
                        "states_id": spare_state_id
                    }
                }
                
                # Try different methods if one fails
                methods = ['patch', 'put', 'post']
                for method in methods:
                    try:
                        response = requests.request(
                            method,
                            f'{self.url}/Computer/{computer_id}',
                            headers=headers,
                            json=data
                        )
                        response.raise_for_status()
                        print(f"Updated status for device {device_name} (Serial: {serial_number}) using {method.upper()}")
                        print(f"Response: {response.text}")
                        return True
                    except Exception as method_error:
                        print(f"Method {method.upper()} failed: {str(method_error)}")
                        continue
                
                return False
            else:
                print(f"Computer not found in GLPI: {device_name} (Serial: {serial_number})")
                return False

        except Exception as e:
            print(f"Failed to update GLPI status for {device_name}: {str(e)}")
            return False

    def close_session(self):
        """Close GLPI session"""
        if self.session_token:
            headers = {
                'Session-Token': self.session_token,
                'App-Token': self.app_token
            }
            try:
                requests.get(f'{self.url}/killSession', headers=headers)
                print("GLPI Session closed")
            except Exception as e:
                print(f"Failed to close GLPI session: {str(e)}")

def get_graph_client():
    """Initialize Microsoft Graph client"""
    try:
        credential = DeviceCodeCredential()
        return GraphClient(credential=credential)
    except Exception as e:
        print(f"Failed to initialize Graph client: {str(e)}")
        return None

def get_intune_devices(graph_client):
    """Get devices from Intune"""
    try:
        devices = graph_client.get('/deviceManagement/managedDevices')
        return devices.json()['value']
    except Exception as e:
        print(f"Failed to get Intune devices: {str(e)}")
        return None

def main():
    # Configuration
    glpi_url = "https://sociabble.with22.glpi-network.cloud/apirest.php"
    app_token = "4qv8BFV6jR6FJ8nR7FqcNDnNypMNbcqj94u54erJ"
    user_token = "EdBBbrmKNWZU0ieIUQCax4iFoHbjjTNKc4MGHzdm"


    try:
        # Initialize GLPI API
        glpi = GLPIApi(glpi_url, app_token, user_token)
        if not glpi.init_session():
            return

        # Get GLPI states
        states, spare_state = glpi.get_states()
        if not spare_state:
            print("Could not find Spare state in GLPI")
            return

        # Get Graph client and devices
        graph_client = get_graph_client()
        if not graph_client:
            return

        devices = get_intune_devices(graph_client)
        if not devices:
            return

        # Process devices
        success_count = 0
        failure_count = 0
        
        for device in devices:
            # Skip shared devices
            if "shared" in device['deviceName'].lower() or "pc-lyon" in device['deviceName'].lower():
                continue

            # Check if device should be marked as spare
            if not device.get('userPrincipalName') or "dsi" in device.get('userPrincipalName', '').lower():
                if glpi.update_computer_status(
                    device['serialNumber'],
                    device['deviceName'],
                    spare_state['id']
                ):
                    success_count += 1
                else:
                    failure_count += 1

        print("\nUpdate Summary:")
        print(f"Successfully updated: {success_count}")
        print(f"Failed to update: {failure_count}")

    except Exception as e:
        print(f"An error occurred: {str(e)}")
    finally:
        if 'glpi' in locals():
            glpi.close_session()

if __name__ == "__main__":
    main()