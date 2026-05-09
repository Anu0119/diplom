from rest_framework import serializers
from .models import Club, Event, Membership

class ClubSerializer(serializers.ModelSerializer):
    leader_name = serializers.ReadOnlyField(source='leader.username')
    school_name = serializers.ReadOnlyField(source='school.name')
    class Meta:
        model = Club
        fields = ['id', 'name', 'description', 'logo', 'school_name', 'leader_name', 'is_active', 'created_at']
        read_only_fields = ['is_active', 'leader', 'school']

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = '__all__'

class MembershipSerializer(serializers.ModelSerializer):
    class Meta:
        model = Membership
        fields = '__all__'