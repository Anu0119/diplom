from django.contrib.auth.models import AbstractUser
from django.db import models

class School(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Хүлээгдэж буй'),
        ('approved', 'Баталгаажсан'),
        ('rejected', 'Татгалзсан'),
    )

    name = models.CharField(max_length=255, unique=True)
    address = models.CharField(max_length=500, blank=True, null=True)
    admin_email = models.EmailField(unique=True) 
    admin_password = models.CharField(max_length=128, help_text="Админ хэрэглэгчийн түр нууц үг")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        is_new_approval = False
        if self.pk:
            old_status = School.objects.get(pk=self.pk).status
            if old_status != 'approved' and self.status == 'approved':
                is_new_approval = True
        
        super().save(*args, **kwargs)

        if is_new_approval:
            from .models import User
            # Username-ийг и-мэйлээр нь тавих нь хамгийн найдвартай (давхцахгүй)
            # Учир нь танай User модель USERNAME_FIELD = 'email' гэсэн байгаа.
            username_source = self.admin_email 
            
            if not User.objects.filter(email=self.admin_email).exists():
                User.objects.create_user(
                    username=username_source, # Энд admin_email-ийг бүхлээр нь ашиглав
                    email=self.admin_email,
                    password=self.admin_password,
                    role='school_admin',
                    school=self
                )

    def __str__(self):
        return self.name

class User(AbstractUser):
    ROLE_CHOICES = (
        ('student', 'Оюутан'),
        ('school_admin', 'Сургуулийн админ'),
        ('club_leader', 'Клубын ахлагч'),
        ('teacher', 'Багш'),
        ('admin', 'Админ'),
    )
    email = models.EmailField(unique=True)
    school = models.ForeignKey(School, on_delete=models.SET_NULL, null=True, blank=True)
    phone = models.CharField(max_length=15, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='student')
    avatar = models.ImageField(upload_to='avatars/', default='default.jpg', blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']