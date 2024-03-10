from django.apps import AppConfig

from rest_framework import serializers, viewsets

class MyProjectConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'web_application'
