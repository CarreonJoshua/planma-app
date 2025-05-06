from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserChangeForm
from api.models import CustomUser, CustomTask, CustomSemester, CustomSubject, UserPref

# Custom User Change Form
class CustomUserChangeForm(UserChangeForm):
    class Meta:
        model = CustomUser
        # Update field names here to match your model fields
        fields = ('email', 'firstname', 'lastname', 'is_active', 'is_staff', 'is_superuser')

# Custom User Admin
class CustomUserAdmin(UserAdmin):
    form = CustomUserChangeForm
    list_display = ('email', 'firstname', 'lastname', 'is_active', 'is_staff', 'is_superuser')
    search_fields = ('email',)

    # Update fieldsets to use 'firstname' and 'lastname' instead of 'first_name' and 'last_name'
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal info', {'fields': ('firstname', 'lastname', 'profile_picture')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
        ('Important dates', {'fields': ('last_login',)}),
    )

    # Add fieldsets for creating new users (like the default UserAdmin)
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'firstname', 'lastname', 'is_active', 'is_staff'),
        }),
    )

# Registering the models in the admin site
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(CustomTask)
admin.site.register(CustomSemester)
admin.site.register(CustomSubject)
admin.site.register(UserPref)
