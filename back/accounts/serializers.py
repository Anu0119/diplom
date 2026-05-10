from rest_framework import serializers
from .models import User, School

class SchoolSerializer(serializers.ModelSerializer):
    class Meta:
        model = School
        fields = ['id', 'name', 'address', 'admin_email', 'admin_password', 'status', 'created_at']
        extra_kwargs = {
            'admin_password': {'write_only': True}, # Нууц үг API хариунд харагдахгүй
            'status': {'read_only': True}
        }

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'school', 'role', 'phone']
        extra_kwargs = {
            'password': {'write_only': True},
            'school': {'required': False} # Энд заавал шаардахгүй болгов
        }

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class UserMeSerializer(serializers.ModelSerializer):
    school_name = serializers.CharField(source='school.name', read_only=True)

    class Meta:
        model = User
        # 'first_name', 'last_name'-г нэмсэн
        fields = ["id", "username", "first_name", "last_name", "email", "school", "school_name", "role", "phone", "avatar"]
        read_only_fields = ['username', 'email', 'role', 'school']