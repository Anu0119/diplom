from django.urls import path
from .views import (
    SignUpAPIView, 
    SchoolListAPIView, 
    SchoolRequestAPIView, 
    ApproveSchoolAPIView, 
    UserMeView,
    UserProfileUpdateView  # Профайл засах хэсэг
)
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    # Аутентификаци
    path('signup/', SignUpAPIView.as_view(), name='api_signup'),
    path('login/', TokenObtainPairView.as_view(), name='api_token_obtain'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Хэрэглэгчийн мэдээлэл (Профайл)
    path('me/', UserMeView.as_view(), name='user-me'),
    path('me/update/', UserProfileUpdateView.as_view(), name='user-profile-update'),

    # Сургуулийн удирдлага
    path('schools/', SchoolListAPIView.as_view(), name='api_schools'),
    path('schools/register/', SchoolRequestAPIView.as_view(), name='api_school_register'),
    path('schools/approve/<int:school_id>/', ApproveSchoolAPIView.as_view(), name='approve_school'),
]