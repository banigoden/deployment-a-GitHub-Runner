from django.urls import path
from . import views
from .views import index, employee_detail

#Namespacing URL names.

urlpatterns = [
    path("", views.index, name='employees'),
    path("employee/<int:id>", views.employee_detail , name='employee-detail'),
    path("filtered/<str:criteria>", views.filtered_employees_criteria, name='filtered_employees_criteria'),
    path("filtered/<str:field>/<str:value>", views.filtered_employees_field_value, name='filtered-employees-field-value'),
    path("createemployee", views.create_employee, name="create-employee"),
]
