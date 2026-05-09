from django.urls import path
from .views import (
    ClubCreateAPIView, ClubListAPIView, ApproveClubAPIView, 
    JoinClubAPIView, EventCreateAPIView, EventListAPIView
)

urlpatterns = [
    path('create/', ClubCreateAPIView.as_view(), name='club-create'),
    path('list/', ClubListAPIView.as_view(), name='club-list'),
    path('approve/<int:pk>/', ApproveClubAPIView.as_view(), name='club-approve'),
    path('join/<int:pk>/', JoinClubAPIView.as_view(), name='club-join'),
    path('events/', EventListAPIView.as_view(), name='event-list'),
    path('events/create/', EventCreateAPIView.as_view(), name='event-create'),
]