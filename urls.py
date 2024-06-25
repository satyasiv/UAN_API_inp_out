from django.urls import path
from . import views
from app import views

urlpatterns = [
    path('api/run_bot/', views.run_robot.as_view(), name='obtain_auth_token_and_run_bot'),           
    path('output_data/', views.User_output_Data.as_view(), name='output_data'), 
]


#   http://localhost:8000/api/run_bot/
#   http://localhost:8000/output_data/


