from rest_framework import permissions

class IsSchoolAdmin(permissions.BasePermission):
    """Зөвхөн тухайн сургуулийн админ"""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'school_admin'

class IsStudent(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'student'

class IsClubLeader(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'club_leader'