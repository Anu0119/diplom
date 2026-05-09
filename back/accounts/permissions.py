
from rest_framework import permissions 



class IsAdmin(permissions.BasePermission):
    """Зөвхөн Админ хэрэглэгчдэд зөвшөөрнө."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'school_admin'
class IsStudent(permissions.BasePermission):
    """Зөвхөн student role-той хэрэглэгчдэд зөвшөөрнө."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'student'


class IsLeader(permissions.BasePermission):
    """Зөвхөн club_leader role-той хэрэглэгчдэд зөвшөөрнө."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'club_leader'
