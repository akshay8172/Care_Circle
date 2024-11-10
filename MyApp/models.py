from django.db import models
from datetime import date


class Login(models.Model):
    username = models.CharField(max_length=40)
    password = models.CharField(max_length=40)
    type = models.CharField(max_length=30)

class Organization(models.Model):
    LOGIN = models.ForeignKey(Login, on_delete=models.Model)
    name = models.CharField(max_length=40)
    place = models.CharField(max_length=40)
    pin = models.IntegerField()
    post = models.CharField(max_length=40)
    phone = models.BigIntegerField()
    email = models.EmailField(max_length=50)
    established_year = models.IntegerField()
    photo = models.FileField()

class User(models.Model):
    LOGIN = models.ForeignKey(Login, on_delete=models.CASCADE)
    ORGANIZATION = models.ForeignKey(Organization, on_delete=models.CASCADE)
    name = models.CharField(max_length=40)
    age = models.IntegerField()
    phone = models.BigIntegerField()
    place = models.CharField(max_length=40)
    pin = models.IntegerField()
    post = models.CharField(max_length=40)
    gender = models.CharField(max_length=30)
    email = models.EmailField(max_length=50)
    blood_group = models.CharField(max_length=30)
    photo = models.FileField()
    is_available = models.BooleanField(default=True)

class Chat(models.Model):
    FROMID = models.ForeignKey(Login,on_delete=models.CASCADE,related_name="Fromid")
    TOID = models.ForeignKey(Login,on_delete=models.CASCADE,related_name="Toid")
    message=models.CharField(max_length=100)
    date=models.DateField()

class Event(models.Model):
    ORGANIZATION = models.ForeignKey(Organization, on_delete=models.CASCADE)
    event_name = models.CharField(max_length=30)
    event_details = models.CharField(max_length=400)
    posted_date = models.DateField(auto_now_add=True)
    event_date = models.DateField()
    status = models.CharField(max_length=40)
    count = models.IntegerField()
    venue = models.CharField(max_length=100)
    photo = models.FileField()

    def check_and_update_status(self):
        if self.event_date < date.today():
            self.status = 'Event Completed'
        else:
            response_count = EventResponse.objects.filter(EVENT=self).count()
            if response_count >= self.count:
                self.status = 'filled'
        self.save(update_fields=['status'])


class EventResponse(models.Model):
    EVENT = models.ForeignKey(Event,on_delete=models.CASCADE)
    USER = models.ForeignKey(User,on_delete=models.CASCADE)
    date = models.DateField(auto_now_add=True)

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        self.EVENT.check_and_update_status()

class ComplaintForEvent(models.Model):
    USER = models.ForeignKey(User, on_delete=models.CASCADE)
    EVENT = models.ForeignKey(EventResponse,on_delete=models.CASCADE)
    complaint = models.TextField()
    date = models.DateField(auto_now_add=True)
    reply = models.TextField(default='pending')

class ComplaintForApp(models.Model):
    USER = models.ForeignKey(User,on_delete=models.CASCADE)
    complaint = models.TextField()
    date = models.DateField(auto_now_add=True)
    reply = models.TextField(default='pending')


class FeedbackRating(models.Model):
    USER = models.ForeignKey(User, on_delete=models.CASCADE)
    EVENT = models.ForeignKey(EventResponse,on_delete=models.CASCADE)
    feedback = models.CharField(max_length=200)
    rating = models.FloatField()
    date = models.DateTimeField(auto_now_add=True)



