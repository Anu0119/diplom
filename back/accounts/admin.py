from django.contrib import admin
from .models import School, User

@admin.register(School)
class SchoolAdmin(admin.ModelAdmin):
    # Жагсаалт дээр харагдах баганууд
    list_display = ('name', 'admin_email', 'status', 'created_at')
    # Шүүлтүүр (Төлөвөөр нь шүүх)
    list_filter = ('status',)
    # Хайлт хийх талбарууд
    search_fields = ('name', 'admin_email')
    # Жагсаалт дээрээс шууд төлөвийг нь өөрчлөх боломжтой болгох
    list_editable = ('status',)

admin.site.register(User)