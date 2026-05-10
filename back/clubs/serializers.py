from rest_framework import serializers
from .models import Club, Event, Membership, Notification

class ClubSerializer(serializers.ModelSerializer):
    is_leader = serializers.SerializerMethodField()
    user_status = serializers.SerializerMethodField()

    class Meta:
        model = Club
        fields = '__all__'

    def get_is_leader(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.leader == request.user
        return False

    def get_user_status(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            membership = Membership.objects.filter(user=request.user, club=obj).first()
            if membership:
                return membership.status # 'pending', 'approved' г.м
        return "not_member"

class MembershipSerializer(serializers.ModelSerializer):
    user_name = serializers.ReadOnlyField(source='user.username')
    club_name = serializers.ReadOnlyField(source='club.name')

    class Meta:
        model = Membership
        fields = ['id', 'user', 'user_name', 'club', 'club_name', 'status', 'message', 'joined_at']
        read_only_fields = ['status']

class EventSerializer(serializers.ModelSerializer):
    # Зөвхөн харах зориулалттай клубын дэлгэрэнгүй
    club_details = ClubSerializer(source='clubs', many=True, read_only=True)
    # Эвент үүсгэхэд ашиглах клубын ID (заавал write_only байна)
    club = serializers.IntegerField(write_only=True)
    # Оролцогчдын тоог тооцож гаргах талбар
    current_participants = serializers.SerializerMethodField()

    class Meta:
        model = Event
        fields = [
            'id', 'name', 'location', 'description', 'image', 
            'club_details', 'max_participants', 'current_participants', 
            'club', 'created_at'
        ]

    # --- ЭНЭ ХЭСГИЙГ НЭМЭВ ---
    def get_current_participants(self, obj):
        """
        ManyToMany талбар болох 'participants'-ийг тоолж буцаана.
        """
        # obj.participants нь ManyToManyManager учраас .count() ашиглана
        return obj.participants.count()

    def create(self, validated_data):
        # 1. 'club' ID-г салгаж авна
        club_id = validated_data.pop('club')
        
        # 2. Эвентээ үүсгэнэ
        event = Event.objects.create(**validated_data)
        
        # 3. Клубыг олоод ManyToMany холбоос дээр нэмнэ
        try:
            club = Club.objects.get(id=club_id)
            event.clubs.add(club)
        except Club.DoesNotExist:
            # Хэрэв клуб олдохгүй бол эвент нь үүснэ, гэхдээ клубгүй үлдэнэ
            pass
            
        return event
class ClubCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Club
        # Хэрэглэгчээс зөвхөн эдгээр утгыг авна
        fields = ['name', 'description']

    def create(self, validated_data):
        request = self.context.get('request')
        user = request.user
        
        # Ахлагчийг нэвтэрсэн хэрэглэгчээр онооно
        validated_data['leader'] = user
        # Сургуулийг хэрэглэгчийн сургуулиар онооно
        # Тэмдэглэл: Таны User модел school талбартай байх ёстой
        validated_data['school'] = user.school 
        
        return super().create(validated_data)
    

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'message', 'is_read', 'created_at']