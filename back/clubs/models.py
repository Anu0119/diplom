from django.db import models
from django.conf import settings

class Club(models.Model):
    name = models.CharField(max_length=255, verbose_name="Клубын нэр")
    description = models.TextField(verbose_name="Клубын тайлбар")
    logo = models.ImageField(upload_to='club_logos/', default='club_default.png', blank=True)
    school = models.ForeignKey('accounts.School', on_delete=models.CASCADE, related_name='clubs')
    leader = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='led_clubs')
    is_active = models.BooleanField(default=False) # Админ зөвшөөрөх хүртэл False
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Membership(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Хүлээгдэж буй'),
        ('approved', 'Баталгаажсан'),
        ('rejected', 'Татгалзсан'),
    )
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='memberships')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    message = models.TextField(blank=True, null=True, verbose_name="Элсэх хүсэлтийн тайлбар")
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
    max_participants = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def current_count(self):
        return self.participants.count()

    def __str__(self):
        return self.name

class Notification(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)