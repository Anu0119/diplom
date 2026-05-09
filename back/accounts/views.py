from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from rest_framework.permissions import IsAdminUser, AllowAny, IsAuthenticated
from django.contrib.auth import authenticate
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from rest_framework_simplejwt.tokens import RefreshToken # JWT import нэмэв

from .serializers import UserSerializer, SchoolSerializer, UserMeSerializer
from .models import School, User

# 1. Оюутан өөрөө бүртгүүлэх
@method_decorator(csrf_exempt, name='dispatch')
class SignUpAPIView(APIView):
    permission_classes = [AllowAny] 

    def post(self, request):
        email = request.data.get('email')
        school_id = request.data.get('school')
        
        if school_id and email:
            try:
                school = School.objects.get(id=school_id)
                # Домэйн шалгах: admin@must.edu.mn -> must.edu.mn
                expected_domain = school.admin_email.split('@')[-1]
                user_domain = email.split('@')[-1]
                
                if user_domain != expected_domain:
                    return Response({
                        "error": f"Та заавал {school.name}-ийн албан ёсны и-мэйлээр (@{expected_domain}) бүртгүүлэх ёстой."
                    }, status=status.HTTP_400_BAD_REQUEST)
            except School.DoesNotExist:
                return Response({"error": "Сургууль олдсонгүй."}, status=status.HTTP_404_NOT_FOUND)

        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({
                "message": "Хэрэглэгч амжилттай бүртгэгдлээ.",
                "user": serializer.data 
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 2. Нэвтрэх
class LoginAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        
        user = authenticate(request, username=email, password=password)
        
        if user:
            # JWT токен үүсгэх
            refresh = RefreshToken.for_user(user)
            
            return Response({
                "message": "Амжилттай нэвтэрлээ",
                "refresh": str(refresh),
                "access": str(refresh.access_token),
                "role": getattr(user, 'role', 'student'), # Role талбар байхгүй бол алдаа гарахаас сэргийлэв
                "user": UserSerializer(user).data
            }, status=status.HTTP_200_OK)
        
        return Response({
            "error": "И-мэйл эсвэл нууц үг буруу байна"
        }, status=status.HTTP_401_UNAUTHORIZED) 

# 3. Баталгаажсан сургуулиудын жагсаалт харах
@method_decorator(csrf_exempt, name='dispatch')
class SchoolListAPIView(APIView):
    permission_classes = [AllowAny] # Нэвтрээгүй хэрэглэгч сургуулиа сонгох боломжтой байна
    
    def get(self, request):
        approved_schools = School.objects.filter(status='approved')
        serializer = SchoolSerializer(approved_schools, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

# 4. Сургууль шинээр бүртгүүлэх хүсэлт илгээх
@method_decorator(csrf_exempt, name='dispatch')
class SchoolRequestAPIView(APIView):
    permission_classes = [AllowAny] 

    def post(self, request):
        serializer = SchoolSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(status='pending') 
            return Response({
                "message": "Сургуулийн бүртгэлийн хүсэлт амжилттай илгээгдлээ. Админ шалгаж байна.",
                "data": serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 5. Сургуулийг баталгаажуулах (Зөвхөн Админ)
@method_decorator(csrf_exempt, name='dispatch')
class ApproveSchoolAPIView(APIView):
    permission_classes = [IsAdminUser] # Аюулгүй байдлын үүднээс зөвхөн админ хандана

    def post(self, request, school_id):
        try:
            school = School.objects.get(id=school_id)
            action = request.data.get('action') # 'approve' эсвэл 'reject'

            if action == 'approve':
                school.status = 'approved'
                school.save()
                return Response({"message": f"{school.name} баталгаажлаа."}, status=status.HTTP_200_OK)
            
            elif action == 'reject':
                school.status = 'rejected'
                school.save()   
                return Response({"message": f"{school.name} хүсэлтээс татгалзлаа."}, status=status.HTTP_200_OK)
            
            return Response({"error": "Буруу үйлдэл. 'approve' эсвэл 'reject' илгээнэ үү."}, status=status.HTTP_400_BAD_REQUEST)

        except School.DoesNotExist:
            return Response({"error": "Сургууль олдсонгүй."}, status=status.HTTP_404_NOT_FOUND)

# 6. Хэрэглэгчийн мэдээлэл
class UserMeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserMeSerializer(request.user)
        return Response(serializer.data)

# 7. Профайл шинэчлэх
class UserProfileUpdateView(generics.RetrieveUpdateAPIView):
    serializer_class = UserMeSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user