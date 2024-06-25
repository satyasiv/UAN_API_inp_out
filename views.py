from rest_framework.authentication import BasicAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from django.http import JsonResponse
from django.views import View
from django.urls import reverse
from django.http import HttpRequest
from datetime import datetime,date
from rest_framework import status
import threading
import subprocess
import uuid
import json
import requests
import os



#run robot_[api]
class run_robot(APIView):
    authentication_classes = [BasicAuthentication]
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        # user auth
        user_credentials = f"{request.user.username}_{request.user.password}" 
        #uuid in response
        user_uuid = uuid.uuid3(uuid.NAMESPACE_OID, user_credentials)
        request.session['user_uuid'] = str(user_uuid)
        timestamp = (user_uuid.time - 0x01b21dd213814000) * 100 / 1e9  # timestamp
        response = requests.get('https://app.hoppr.in/api/uan-generation-linking-process?username=adminapi&key=eshyosdmtoopcfrgxthftnfwthdicxmmioxedozotygbztmzfecjmxznzersteiketxusgydkpcqcljeptabzxthzmuvpyrfvjgdcwlytxpdvcfwmhytzvkzvrqammra&data_count=1')
        data = response.json()
        validated_data = []
        for instance in data:
            universal_account = instance.get('Universal_Account', None)
            validated_data.append({
                'employee_id': instance['employee_id'],
                'member_name': instance['member_name'],
                'gender': instance['gender'],
                'father_husband_name': instance['father_husband_name'],
                'relationship_with_member': instance['relationship_with_member'],
                'nationality': instance['nationality'],
                'marital_status': instance['marital_status'],
                'aadhaar_number': instance['aadhaar_number'],
                'name_as_on_aadhaar': instance['name_as_on_aadhaar'],
                'date_of_birth': convert_to_dd_mm_yyyy(instance['date_of_birth']),
                'date_of_joining': convert_to_dd_mm_yyyy(instance['date_of_joining']),
                'Universal_Account': universal_account,
                'wages_as_on_joining': instance['wages_as_on_joining'],
            })
        threading.Thread(target=run_bot, args=(validated_data,)).start()
        return Response({'message': 'Robot is in progress for valid users. Please view the status from localhost:8000/boturl to know about the bot status', 'uuid': str(user_uuid), 'timestamp': timestamp}, status=status.HTTP_200_OK)

#date function
def convert_to_dd_mm_yyyy(date_input):
    if isinstance(date_input, datetime):
        return date_input.strftime("%d/%m/%Y")
    elif isinstance(date_input, date):
        return date_input.strftime("%d/%m/%Y")
    else:
        try:
            parsed_date = datetime.strptime(date_input, "%Y-%m-%d")
            return parsed_date.strftime("%d/%m/%Y")
        except ValueError:
            return date_input



def run_bot(validated_data):
    robot_path = "/home/buzzadmin/Downloads/bots/apitask/DEV_UAN_API/tasks.robot"          
    # output_directory = "/home/buzzadmin/Downloads/bots/apitask/DEV_UAN_API/output"
    validated_data_json = json.dumps(validated_data)
    print('validated_data_json:', validated_data_json)
    # Generate a unique timestamp for the log file name
    timestamp = datetime.now().strftime("%Y:%m:%d:%H%M%S")
    print(timestamp)
    output_directory = f"/home/buzzadmin/Downloads/bots/apitask/DEV_UAN_API/logs_data/{timestamp}"  
    os.makedirs(output_directory, exist_ok=True)
    try:
        command = ['robot',
                   '--variable', f'validated_data:{validated_data_json}',
                   '--outputdir', output_directory,  
                    '--log', f'{output_directory}/log.html',
                    '--report', f'{output_directory}/report.html',
                    '--output', f'{output_directory}/output.xml',
                    robot_path
                  ]
        result = subprocess.run(command, capture_output=True)
        print('Result:', result)
        print('stdout:', result.stdout.decode())
        print('stderr:', result.stderr.decode())
    except Exception as e:
        print("An error occurred during the execution:", str(e))
        return "error"





class User_output_Data(APIView):
    def post(self, request, *args, **kwargs):
        try:
            # Extracting data from the form
            employee_id = request.data.get('employee_id')
            aadhaar_number = request.data.get('aadhaar_number')
            name = request.data.get('name')
            entity_status = request.data.get('entity_status')
            uan_status = request.data.get('uan_status')
            uan_num = request.data.get('uan_num')
            remarks = request.data.get('remarks')
            user_uuid = request.data.get('user_uuid')
            time = request.data.get('time')
            
            print('Received data:')
            print('employee_id:', employee_id)
            print('aadhaar_number:', aadhaar_number)
            print('name:', name)
            print('entity_status:', entity_status)
            print('uan_status:', uan_status)
            print('uan_num:', uan_num)
            print('remarks:', remarks)
            print('user_uuid:', user_uuid)
            print('time:', time)
            response_data = {
                'employee_id': employee_id,
                'aadhaar_number': aadhaar_number,
                'name': name,
                'entity_status': entity_status,
                'uan_status': uan_status,
                'uan_num': uan_num,
                'remarks': remarks,
                'user_uuid': user_uuid,
                'time': time
            }
            
            print('Response data to be sent:')
            print(response_data)
            
            # URL and credentials
            url = 'https://app.hoppr.in/api/uan-generation-linking-process'
            params = {
                'username': 'adminapi',
                'key': 'eshyosdmtoopcfrgxthftnfwthdicxmmioxedozotygbztmzfecjmxznzersteiketxusgydkpcqcljeptabzxthzmuvpyrfvjgdcwlytxpdvcfwmhytzvkzvrqammra'
            }
            response = requests.post(url, data=response_data, params=params)
            response.raise_for_status()  # Raises an error for bad status codes
            print('Data sent successfully.')
            return Response(response_data, status=status.HTTP_201_CREATED)
        except requests.RequestException as e:
            return Response({'error': f'HTTP request failed: {e}'}, status=status.HTTP_400_BAD_REQUEST)
        
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)







