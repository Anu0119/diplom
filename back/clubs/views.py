from rest_framework import status, generics, permissions
from rest_framework import status, generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from rest_framework.permissions import IsAuthenticated  
from django.db.models import Q

from .models import Club, Membership, Event, Notification
from .serializers import ClubSerializer, NotificationSerializer, EventSerializer, MembershipSerializer, ClubCreateSerializer
from .permissions import IsClubLeaderOrReadOnly

class ClubCreateAPIView(generics.CreateAPIView):
    queryset = Club.objects.all()
    serializer_class = ClubCreateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(leader=self.request.user, school=self.request.user.school, is_active=False)

class ClubListAPIView(generics.ListAPIView):
    serializer_class = ClubSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        # Хэрэв админ хандаж байвал бүгдийг, үгүй бол зөвхөн идэвхтэйг харуулна
        if self.request.user.is_authenticated and self.request.user.role == 'school_admin':
            return Club.objects.all()
        return Club.objects.filter(is_active=True)

class ApproveClubAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, club_id):
        try:
            if request.user.role != 'school_admin' and not request.user.is_superuser:
                return Response({"error": "Танд эрх байхгүй байна."}, status=403)

            club = Club.objects.get(id=club_id)
            action = request.data.get('action')

            if action == 'approve':
                club.is_active = True
                club.save() # Энэ үед сигнал ажиллаж "Баталгаажлаа" мэдэгдэл очно
                return Response({"message": "Клуб баталгаажлаа."})
            
            elif action == 'reject':
                # Устгахаас өмнө оюутанд мэдэгдэл илгээх
                Notification.objects.create(
                    user=club.leader,
                    title="Клубын хүсэлт татгалзлаа",
                    message=f"Таны '{club.name}' клуб нээх хүсэлтээс сургуулийн захиргаа татгалзлаа."
                )
                club.delete() 
                return Response({"message": "Клубын хүсэлтээс татгалзлаа."})
                
            return Response({"error": "Буруу үйлдэл."}, status=400)
        except Club.DoesNotExist:
            return Response({"error": "Клуб олдсонгүй."}, status=404)
        
class JoinClubAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        club = get_object_or_404(Club, pk=pk)
        
        # Аль хэдийн хүсэлт илгээсэн эсэхийг шалгах
        membership, created = Membership.objects.get_or_create(
            user=request.user, 
            club=club,
            defaults={'status': 'pending'}
        )

        if not created:
            return Response(
                {"message": "Та аль хэдийн хүсэлт илгээсэн байна."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        return Response(
            {"message": "Элсэх хүсэлт амжилттай илгээгдлээ."}, 
            status=status.HTTP_201_CREATED
        )
    
class EventCreateAPIView(generics.CreateAPIView):
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated]


class JoinEventAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        event = get_object_or_404(Event, pk=pk)
        user = request.user
        
        # 1. Хэрэглэгч аль хэдийн бүртгүүлсэн эсэхийг шалгах
        if event.participants.filter(id=user.id).exists():
            return Response({"success": False, "message": "Та аль хэдийн бүртгүүлсэн байна."}, status=400)

        # 2. Оролцогч дүүрсэн эсэхийг шалгах
        current_count = event.participants.count()
        if event.max_participants > 0 and current_count >= event.max_participants:
            return Response({"success": False, "message": "Уучлаарай, оролцогчийн тоо дүүрсэн байна."}, status=400)
        
        # 3. Хэрэглэгчийг нэмэх
        event.participants.add(user)
        
        return Response({
            "success": True, 
            "message": "Амжилттай бүртгүүллээ.",
            "current_participants": event.participants.count()
        }, status=200)
    
# Клуб засах, устгах, дэлгэрэнгүй харах
class ClubDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Club.objects.all()
    serializer_class = ClubSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsClubLeaderOrReadOnly]

# --- EVENT CRUD ---

# Эвент үүсгэх (Зөвхөн нэвтэрсэн хэрэглэгч)
class EventCreateAPIView(generics.CreateAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated]

# Эвент засах, устгах
class EventDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsClubLeaderOrReadOnly]

class EventListAPIView(generics.ListAPIView):
    serializer_class = EventSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Event.objects.all().order_by('-created_at')
        club_id = self.request.query_params.get('club_id')
        
        if club_id:
            try:
                # Талбарын нэрийг 'clubs' байгаа эсэхийг дахин нэг шалгаарай
                queryset = queryset.filter(clubs__id=int(club_id))
            except ValueError:
                pass # Буруу ID ирвэл шүүлтүүр хийхгүй алгасана
        return queryset
    
# --- MEMBERSHIP CRUD ---

# Гишүүнчлэлийн жагсаалт (Ахлагч өөрийн клубын хүсэлтүүдийг харах)
class ClubMembershipListView(generics.ListAPIView):
    serializer_class = MembershipSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # club_id-аар шүүх боломжтой болгох
        club_id = self.request.query_params.get('club_id')
        queryset = Membership.objects.filter(club__leader=self.request.user)
        if club_id:
            queryset = queryset.filter(club_id=club_id)
        return queryset

# Гишүүнчлэл засах (Зөвшөөрөх/Татгалзах/Устгах)
class MembershipDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Membership.objects.all()
    serializer_class = MembershipSerializer
    permission_classes = [permissions.IsAuthenticated, IsClubLeaderOrReadOnly]


class MyClubsListView(generics.ListAPIView):
    serializer_class = ClubSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # .models биш .objects байх ёстой
        return Club.objects.filter(
            Q(leader=user) | Q(memberships__user=user, memberships__status='approved')
        ).distinct()
    
class UpdateMembershipStatusAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        membership_id = request.data.get('membership_id')
        new_status = request.data.get('status') # 'approved' эсвэл 'rejected'

        try:
            membership = Membership.objects.get(id=membership_id)
            
            # Зөвхөн клубын ахлагч зөвшөөрөх эрхтэйг шалгах (Сайжруулалт)
            if membership.club.leader != request.user:
                return Response({"message": "Танд эрх байхгүй."}, status=status.HTTP_403_FORBIDDEN)

            membership.status = new_status
            membership.save()
            
            return Response({"message": "Статус амжилттай шинэчлэгдлээ."}, status=status.HTTP_200_OK)
        except Membership.DoesNotExist:
            return Response({"message": "Хүсэлт олдсонгүй."}, status=status.HTTP_404_NOT_FOUND)
        

class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Зөвхөн нэвтэрсэн хэрэглэгчийн мэдэгдлүүдийг харуулна
        return Notification.objects.filter(user=self.request.user).order_by('-created_at')

class MarkNotificationReadAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        notification = get_object_or_404(Notification, pk=pk, user=request.user)
        notification.is_read = True
        notification.save()
        return Response({"status": "success"})