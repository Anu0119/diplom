from django.urls import path
from .views import (
    ClubCreateAPIView, ClubListAPIView, ApproveClubAPIView, 
    JoinClubAPIView, EventCreateAPIView, EventListAPIView, ClubDetailAPIView, 
    EventDetailAPIView, ClubMembershipListView, MembershipDetailAPIView, MyClubsListView, 
    UpdateMembershipStatusAPIView, NotificationListView, MarkNotificationReadAPIView, JoinEventAPIView
)

urlpatterns = [
    # Клуб
    path('list/', ClubListAPIView.as_view(), name='club-list'),
    path('create/', ClubCreateAPIView.as_view(), name='club-create'),
    path('approve/<int:club_id>/', ApproveClubAPIView.as_view(), name='club-approve'),
    path('my-clubs/', MyClubsListView.as_view(), name='my-clubs'), 
    path('memberships/update-status/', UpdateMembershipStatusAPIView.as_view(), name='update-membership-status'),
    path('join/<int:pk>/', JoinClubAPIView.as_view(), name='join-club'),
    path('<int:pk>/', ClubDetailAPIView.as_view(), name='club-detail'), # GET, PUT, PATCH, DELETE
    
    # Эвент
    path('events/', EventListAPIView.as_view(), name='event-list'),
    path('events/create/', EventCreateAPIView.as_view(), name='event-create'),
    path('events/<int:pk>/join/', JoinEventAPIView.as_view(), name='event-join'),
    path('events/<int:pk>/', EventDetailAPIView.as_view(), name='event-detail'), # GET, PUT, PATCH, DELETE

    # Гишүүнчлэл
    path('my-club/memberships/', ClubMembershipListView.as_view()),
    path('memberships/<int:pk>/', MembershipDetailAPIView.as_view()), # Зөвшөөрөх эсвэл хасах


    path('notifications/', NotificationListView.as_view(), name='notification-list'),
    path('notifications/<int:pk>/read/', MarkNotificationReadAPIView.as_view(), name='notification-read'),
]