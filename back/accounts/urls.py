from django.urls import path
from .views import (
    SignUpAPIView, SchoolListCreateAPIView, SchoolDetailAPIView,
    ApproveSchoolAPIView, UserMeView, MySchoolUpdateView
)

urlpatterns = [
    path('signup/', SignUpAPIView.as_view(), name='signup'),
    path('login/', 
         lambda *args, **kwargs: __import__('rest_framework_simplejwt.views', fromlist=['TokenObtainPairView']).TokenObtainPairView.as_view()(*args, **kwargs), 
         name='login'),
    
    path('token/refresh/', 
         lambda *args, **kwargs: __import__('rest_framework_simplejwt.views', fromlist=['TokenRefreshView']).TokenRefreshView.as_view()(*args, **kwargs), 
         name='token_refresh'),
    
    # Profile
    path('me/', UserMeView.as_view(), name='me'),
    
    # School CRUD
    path('schools/', SchoolListCreateAPIView.as_view(), name='school_list_create'),
    path('schools/register/', SchoolListCreateAPIView.as_view(), name='school_register'),
    path('schools/<int:id>/', SchoolDetailAPIView.as_view(), name='school_detail'),
    path('schools/approve/<int:school_id>/', ApproveSchoolAPIView.as_view(), name='approve_school'),
    
    # School Admin
    path('my-school/update/', MySchoolUpdateView.as_view(), name='my_school_update'),
]