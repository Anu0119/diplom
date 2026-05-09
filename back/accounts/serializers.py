from rest_framework import serializers
from .models import User, School

class SchoolSerializer(serializers.ModelSerializer):
    class Meta:
        model = School
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'school', 'role', 'phone']
        extra_kwargs = {
            'password': {'write_only': True} # Нууц үгийг харах боломжгүй болгох
        }

    def create(self, validated_data):
        # Энэ хэсэг нь нууц үгийг Hash хийж хадгалдаг хэсэг юм
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            school=validated_data.get('school'),
            role=validated_data.get('role', 'student'),
            phone=validated_data.get('phone', '')
        )
        return user

    def create(self, validated_data):
        # Нууц үгийг hash хийж хадгалах
        user = User.objects.create_user(**validated_data)
        return user 

class UserMeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "email", "school", "role", "phone"]