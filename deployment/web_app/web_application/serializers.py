
from rest_framework import serializers
from .models import Employee
#Serializers allow you to convert complex data types, such as Django models, into Python data types

class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = '__all__'
