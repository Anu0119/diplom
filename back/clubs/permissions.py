from rest_framework import permissions

class IsAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'school_admin'

class IsStudent(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'student'

class IsLeader(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'club_leader'

class IsClubLeaderOrReadOnly(permissions.BasePermission):
    """
    Клубын ахлагч өөрийн клубыг засах, эсвэл клубын ахлагч өөрийн клубын эвентийг засах.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
            
        if not request.user.is_authenticated:
            return False

        if hasattr(obj, 'leader'):
            return obj.leader == request.user
            
        if hasattr(obj, 'club'):
            return obj.club.leader == request.user
            
        return False