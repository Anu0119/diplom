from rest_framework import status, generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Club, Membership, Event
from .serializers import ClubSerializer, EventSerializer, MembershipSerializer
from rest_framework.permissions import IsAuthenticated  

class ClubCreateAPIView(generics.CreateAPIView):
    serializer_class = ClubSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(leader=self.request.user, school=self.request.user.school, is_active=False)

class ClubListAPIView(generics.ListAPIView):
    serializer_class = ClubSerializer
    permission_classes = [permissions.AllowAny]
    def get_queryset(self):
        return Club.objects.filter(is_active=True)

class ApproveClubAPIView(APIView):
    permission_classes = [IsAuthenticated] # Эсвэл өөрийн IsSchoolAdmin

    def post(self, request, club_id):
        try:
            # Хэрэв User-ийн role нь school_admin биш бол татгалзах (Optional)
            if request.user.role != 'school_admin' and not request.user.is_superuser:
                return Response({"error": "Танд эрх байхгүй байна."}, status=403)

            from clubs.models import Club # Клуб моделио импортлох
            club = Club.objects.get(id=club_id)
            action = request.data.get('action')

            if action == 'approve':
                club.is_active = True
                club.save()
                return Response({"message": "Клуб баталгаажлаа."})
            elif action == 'reject':
                club.delete() # Эсвэл status='rejected'
                return Response({"message": "Клубын хүсэлтээс татгалзлаа."})
                
            return Response({"error": "Буруу үйлдэл."}, status=400)
        except Exception as e:
            return Response({"error": str(e)}, status=404)

class JoinClubAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request, pk):
        club = get_object_or_404(Club, pk=pk, is_active=True)
        membership, created = Membership.objects.get_or_create(user=request.user, club=club)
        return Response({"message": "Хүсэлт илгээгдлээ."}, status=201)

class EventCreateAPIView(generics.CreateAPIView):
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated]

class EventListAPIView(generics.ListAPIView):
    queryset = Event.objects.all().order_by('-created_at')
    serializer_class = EventSerializer
    permission_classes = [permissions.AllowAny]