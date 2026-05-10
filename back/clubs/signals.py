from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Membership, Notification, Club
from django.contrib.auth import get_user_model


User = get_user_model()

# --- КЛУБ ҮҮСГЭХ ХҮСЭЛТИЙН МЭДЭГДЭЛ ---
@receiver(post_save, sender=Club)
def club_creation_notification(sender, instance, created, **kwargs):
    if created:
        # 1. Оюутан клуб нээх хүсэлт гаргахад Сургуулийн админуудад мэдэгдэл очих
        school_admins = User.objects.filter(role='school_admin', school=instance.school)
        for admin in school_admins:
            Notification.objects.create(
                user=admin,
                title="Клуб нээх хүсэлт",
                message=f"'{instance.name}' нэртэй шинэ клуб бүртгүүлэх хүсэлт ирлээ."
            )
    else:
        # 2. Админ клубыг идэвхжүүлэх (approve) үед оюутан (leader)-д мэдэгдэл очих
        # Хэрэв is_active талбар False-оос True болж өөрчлөгдсөн эсэхийг шалгах логик
        if instance.is_active:
            # Өмнө нь мэдэгдэл очсон эсэхийг шалгахгүй бол save хийх болгонд очих аюултай тул 
            # get_or_create эсвэл title-аар шүүж нэг удаа илгээхээр тохируулж болно.
            Notification.objects.get_or_create(
                user=instance.leader,
                title="Клуб баталгаажлаа",
                defaults={'message': f"Таны гаргасан '{instance.name}' клубыг сургуулийн захиргаанаас зөвшөөрч, идэвхжүүллээ."}
            )

@receiver(post_save, sender=Membership)
def membership_status_notification(sender, instance, created, **kwargs):
    if created:
        # 1. Шинэ хүсэлт ирэхэд Клубын ахлагчид мэдэгдэл илгээх
        Notification.objects.create(
            user=instance.club.leader,
            title="Элсэх хүсэлт",
            message=f"{instance.user.username} таны '{instance.club.name}' клубт элсэх хүсэлт илгээлээ."
        )
    else:
        # 2. Статус өөрчлөгдөхөд (Зөвшөөрөх/Татгалзах) оюутанд мэдэгдэл илгээх
        status_mn = {
            'approved': 'зөвшөөрөгдлөө',
            'rejected': 'татгалзлаа'
        }
        
        if instance.status in status_mn:
            Notification.objects.create(
                user=instance.user,
                title="Хүсэлтийн хариу",
                message=f"Таны '{instance.club.name}' клубт элсэх хүсэлт {status_mn[instance.status]}."
            )



