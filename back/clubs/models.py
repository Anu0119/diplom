from django.db import models
from django.conf import settings

class Club(models.Model):
    name = models.CharField(max_length=255, verbose_name="Клубын нэр")
    description = models.TextField(verbose_name="Клубын тайлбар")
    logo = models.ImageField(upload_to='club_logos/', default='club_default.png', blank=True)
    school = models.ForeignKey('accounts.School', on_delete=models.CASCADE, related_name='clubs')
    leader = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='led_clubs')
    is_active = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.school.name}"

class Membership(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Хүлээгдэж буй'),
        ('approved', 'Баталгаажсан'),
    )
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='memberships')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'club')

class Event(models.Model):
    name = models.CharField(max_length=255)
    location = models.CharField(max_length=255)
    description = models.TextField()
    image = models.ImageField(upload_to='event_images/', blank=True, null=True)
    clubs = models.ManyToManyField(Club, related_name='events')
    participants = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='participating_events', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)