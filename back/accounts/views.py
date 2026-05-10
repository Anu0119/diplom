from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.permissions import IsAdminUser, AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404

from .models import School, User
from .serializers import UserSerializer, SchoolSerializer, UserMeSerializer
from .permissions import IsSchoolAdmin

# 1. Сургуулийн CRUD (Зөвхөн Системийн Админ болон Сургууль хүсэлт илгээх)
class SchoolListCreateAPIView(generics.ListCreateAPIView):
    """
    GET: Батлагдсан сургуулиудыг харах
    POST: Сургууль бүртгүүлэх хүсэлт илгээх (Pending төлөвтэй үүснэ)
    """
    serializer_class = SchoolSerializer
    
    def get_permissions(self):
        if self.request.method == 'POST':
            return [AllowAny()]
        return [AllowAny()]

    def get_queryset(self):
        # Системийн админ (staff) бүх сургуулийг харна, бусад нь зөвхөн батлагдсаныг
        if self.request.user.is_authenticated and self.request.user.is_staff:
            return School.objects.all()
        return School.objects.filter(status='approved')

class SchoolDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    """Сургуулийн мэдээлэл харах, засах, устгах (Зөвхөн Системийн Админ)"""
    queryset = School.objects.all()
    serializer_class = SchoolSerializer
    lookup_field = 'id'
    permission_classes = [IsAdminUser]

# 2. Оюутан бүртгүүлэх (Сургуулийг и-мэйлээр автоматаар танина)
class SignUpAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        
        if not email or '@' not in email:
            return Response({"error": "Хүчинтэй и-мэйл хаяг оруулна уу."}, status=status.HTTP_400_BAD_REQUEST)

        # 1. Домэйныг салгаж авах (жишээ нь: student@must.edu.mn -> must.edu.mn)
        user_domain = email.split('@')[-1].lower()

        # 2. Тухайн домэйнтэй батлагдсан сургуулийг хайх
        school = School.objects.filter(
            admin_email__icontains=user_domain, 
            status='approved'
        ).first()

        if not school:
            return Response({
                "error": f"Таны и-мэйл домэйн ({user_domain}) бүртгэлтэй сургууль олдсонгүй. Сургууль тань батлагдаагүй байна."
            }, status=status.HTTP_400_BAD_REQUEST)

        # 3. Мэдээллийг бэлдэх
        data = request.data.copy()
        
        # Username байхгүй бол и-мэйлийг нь username болгох (IntegrityError-оос сэргийлнэ)
        if not data.get('username'):
            data['username'] = email

        serializer = UserSerializer(data=data)
        if serializer.is_valid():
            # Оюутныг олсон сургуульд нь автоматаар холбож хадгалах
            serializer.save(school=school, role='student')
            return Response({
                "message": f"Та {school.name} сургуулийн оюутнаар амжилттай бүртгэгдлээ.",
                "user": serializer.data
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 3. Сургуулийг баталгаажуулах
class ApproveSchoolAPIView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request, school_id):
        school = get_object_or_404(School, id=school_id)
        action = request.data.get('action') # 'approve' эсвэл 'reject'

        if action == 'approve':
            school.status = 'approved'
            school.save() # Энэ үед Model-ийн save() ажиллаж сургуулийн админ User үүснэ
            return Response({"message": f"{school.name} баталгаажлаа."}, status=status.HTTP_200_OK)
        elif action == 'reject':
            school.status = 'rejected'
            school.save()
            return Response({"message": "Хүсэлтээс татгалзлаа."}, status=status.HTTP_200_OK)
        
        return Response({"error": "Буруу үйлдэл. 'approve' эсвэл 'reject' утга илгээнэ үү."}, status=status.HTTP_400_BAD_REQUEST)

# 4. Профайл (User Me)
class UserMeView(generics.RetrieveUpdateAPIView):
    """Өөрийн мэдээллийг харах болон засах (Зураг оруулах хэсэг)"""
    permission_classes = [IsAuthenticated]
    serializer_class = UserMeSerializer
    parser_classes = (MultiPartParser, FormParser) # Зураг хүлээж авахад хэрэгтэй

    def get_object(self):
        return self.request.user

# 5. Сургуулийн админ өөрийн сургуулийг засах
class MySchoolUpdateView(generics.UpdateAPIView):
    serializer_class = SchoolSerializer
    permission_classes = [IsSchoolAdmin]

    def get_object(self):
        if not self.request.user.school:
            return Response({"error": "Танд харьяалагдах сургууль байхгүй байна."}, status=404)
        return self.request.user.school