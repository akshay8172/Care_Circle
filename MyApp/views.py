from django.core.files.storage import FileSystemStorage
from django.db.models import Q
from django.http import JsonResponse
from .models import *
import json
from django.utils import timezone



def login(request):
    username = request.POST['user_name']
    password = request.POST['password']

    login_fetch = Login.objects.filter(username=username,password=password)
    if login_fetch.exists():
        login_get = Login.objects.get(username=username,password=password)
        if login_get.type == 'user':
            return JsonResponse({'status':'ok','lid':str(login_get.id),'type':'user'})
        elif login_get.type == 'admin':
            return JsonResponse({'status':'ok','lid':str(login_get.id),'type':'admin'})
        elif login_get.type == 'organization':
            return JsonResponse({'status':'ok','lid':str(login_get.id),'type':'organization'})
        else:
            return JsonResponse({'status':'not ok'})
    else:
        return JsonResponse({'status': 'not ok'})


def admin_add_organization(request):
    name = request.POST['name']
    place = request.POST['place']
    pin = request.POST['pin']
    post = request.POST['post']
    phone = request.POST['phone']
    email = request.POST['email']
    established_year = request.POST['established_year']
    username = request.POST['username']
    password = request.POST['password']
    photo = request.FILES.get('photo')

    if Login.objects.filter(username=username,password=password).exists():
        return JsonResponse({'status': 'not ok'})

    log = Login(username=username, password=password, type='organization')
    log.save()
    fs = FileSystemStorage()
    fp = fs.save(photo.name, photo)
    profile = Organization(LOGIN=log, name=name, place=place, pin=pin, post=post, phone=phone, email=email,
                established_year=established_year, photo=fp)
    profile.save()
    return JsonResponse({'status': 'ok'})

def admin_view_organization(request):
    organization = Organization.objects.all().order_by('-id')
    org = []
    for i in organization:
        org.append({
            'id':i.id,
            'name':i.name,
            'place':i.place,
            'pin':i.pin,
            'post':i.post,
            'phone':i.phone,
            'email':i.email,
            'established_year':i.established_year,
            'photo':i.photo.url if i.photo else None,
            'LOGIN':i.LOGIN.type
        })
    return JsonResponse({'status': 'ok', 'org': org})



def admin_block_organization(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            org_id = data.get('orgId')
            organization = Organization.objects.get(id=org_id)

            log = organization.LOGIN
            log.type = 'blocked'
            log.save()

            return JsonResponse({'status': 'ok', 'message': 'Organization Blocked successfully'})
        except Organization.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Organization not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)


def admin_unblock_organization(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            org_id = data.get('orgId')
            organization = Organization.objects.get(id=org_id)

            log = organization.LOGIN
            log.type = 'organization'
            log.save()

            return JsonResponse({'status': 'ok', 'message': 'Organization Unblocked successfully'})
        except Organization.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Organization not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)



def admin_view_users(request):
    try:
        users = User.objects.all()
        user_list = []
        for i in users:
            user_list.append({
                'id': i.id,
                'org': i.ORGANIZATION.name,
                'status': i.LOGIN.type,
                'name': i.name,
                'age': i.age,
                'phone': i.phone,
                'place': i.place,
                'pin': i.pin,
                'post': i.post,
                'gender': i.gender,
                'email': i.email,
                'blood_group': i.blood_group,
                'is_available': i.is_available,
                'photo': i.photo.url if i.photo else None
            })
        return JsonResponse({'status': 'ok', 'org': user_list})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


def admin_block_users(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            org_id = data.get('orgId')
            user = User.objects.get(id=org_id)

            log = user.LOGIN
            log.type = 'blocked'
            log.save()

            return JsonResponse({'status': 'ok', 'message': 'User Blocked successfully'})
        except Organization.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)


def admin_unblock_users(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            org_id = data.get('orgId')
            user = User.objects.get(id=org_id)

            log = user.LOGIN
            log.type = 'user'
            log.save()

            return JsonResponse({'status': 'ok', 'message': 'User UNblocked successfully'})
        except Organization.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)


def AdminViewFeedbacks(request):
    feedback = FeedbackRating.objects.all()
    feedbacks = []
    for i in feedback:
        feedbacks.append({
            'sender':i.USER.name,
            'event':i.EVENT.EVENT.event_name,
            'event_date':i.EVENT.EVENT.event_date,
            'feedback':i.feedback,
            'rating':i.rating,
            'date':i.date,
            'photo':i.EVENT.EVENT.photo.url
        })
    return JsonResponse({'status':'ok','feedbacks':feedbacks})


def AdminViewComplaint(request):
    comp = ComplaintForApp.objects.all().order_by('-id')
    complaints = []
    for i in comp:
        complaints.append({
            'id':i.id,
            'user':i.USER.name,
            'complaint':i.complaint,
            'date':i.date,
            'reply':i.reply
        })
    return JsonResponse({'status': 'ok', 'complaints': complaints})

def AdminSendReply(request):
    complaint_id = request.POST['complaint_id']
    reply = request.POST['reply']
    complaint = ComplaintForApp.objects.get(id=complaint_id)
    complaint.reply = reply
    complaint.save()
    return JsonResponse({'status': 'ok'})

def AdminChangePassword(request):
    id = request.POST['id']
    old_password = request.POST.get('current_password')
    new_password = request.POST.get('new_password')
    confirm_password = request.POST.get('confirm_password')

    credentials = Login.objects.filter(id=id, password=old_password)
    if credentials.exists():
        if new_password == confirm_password:
            new_credentials = credentials.update(password=confirm_password)
            if new_credentials:
                return JsonResponse({'status': 'ok', })
            else:
                return JsonResponse({'status': 'not ok', })
        else:
            return JsonResponse({'status': 'not ok', })
    else:
        return JsonResponse({'status': 'not ok', })


def AdminViewEvents(request):
    events = Event.objects.prefetch_related('ORGANIZATION', 'eventresponse_set').all()

    event_data = []

    for event in events:
        organization = event.ORGANIZATION
        response_count = event.eventresponse_set.count()
        users = event.eventresponse_set.select_related('USER').all()
        user_details = []

        for response in users:
            user = response.USER
            user_details.append({
                'user_id': user.id,
                'name': user.name,
                'phone': user.phone,
                'email': user.email,
                'place': user.place,
                'pin': user.pin,
            })
        event_info = {
            'event_id': event.id,
            'event_name': event.event_name,
            'event_details': event.event_details,
            'posted_date': event.posted_date,
            'event_date': event.event_date,
            'status': event.status,
            'count': event.count,
            'venue': event.venue,
            'photo_url': event.photo.url if event.photo else None,
            'organization': {
                'name': organization.name,
                'place': organization.place,
                'phone': organization.phone,
                'email': organization.email,
            },
            'response_count': response_count,
            'respondents': user_details,
        }
        event_data.append(event_info)
    return JsonResponse({'events': event_data}, safe=False)


def AdminChatViewOrganization(request):
    organization = Organization.objects.filter(LOGIN__type='organization').order_by('-id')
    org = []
    for i in organization:
        org.append({
            'id': i.id,
            'name': i.name,
            'place': i.place,
            'pin': i.pin,
            'post': i.post,
            'phone': i.phone,
            'email': i.email,
            'established_year': i.established_year,
            'photo': i.photo.url if i.photo else None,
            'LOGIN': i.LOGIN.id
        })
    return JsonResponse({'status': 'ok', 'org': org})

def Admin_sendchat(request):
    FROM_id=request.POST['from_id']
    TOID_id=request.POST['to_id']
    print(FROM_id)
    print(TOID_id)
    msg=request.POST['message']

    from  datetime import datetime
    c=Chat()
    c.FROMID_id=FROM_id
    c.TOID_id=TOID_id
    c.message=msg
    c.date=datetime.now()
    c.save()
    return JsonResponse({'status':"ok"})

def Admin_viewchat(request):
    fromid = request.POST["from_id"]
    toid = request.POST["to_id"]


    res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid)).order_by('id')
    l = []

    for i in res:
        l.append({"id": i.id, "msg": i.message, "from": i.FROMID_id, "date": i.date, "to": i.TOID_id})

    return JsonResponse({"status":"ok",'data':l})



















#------------------------------------------------------------Organization-----------------------------------------------

def org_view_profile(request):
    try:
        org_id = request.POST['id']
        org = Organization.objects.get(LOGIN=org_id)

        profile = {
            'id': org.id,
            'name': org.name,
            'place': org.place,
            'pin': org.pin,
            'post': org.post,
            'phone': org.phone,
            'email': org.email,
            'established_year': org.established_year,
            'image': org.photo.url if org.photo else None
        }

        return JsonResponse({'status': 'ok', 'profile': [profile]})
    except Organization.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'Organization illa'})


from django.http import JsonResponse
from django.core.files.storage import FileSystemStorage
from .models import Organization  # Make sure this import matches your project structure


def OrgEditProfile(request):
    try:
        org_id = request.POST['id']
        name = request.POST['name']
        place = request.POST['place']
        pin = request.POST['pin']
        post = request.POST['post']
        phone = request.POST['phone']
        email = request.POST['email']
        established_year = request.POST['established_year']
        photo = request.FILES.get('image')  # Correct key used here

        org = Organization.objects.get(LOGIN=org_id)

        if photo:
            fs = FileSystemStorage()
            filename = fs.save(photo.name, photo)
            org.photo = filename  # Assuming 'photo' is the field name in your Organization model

        org.name = name
        org.place = place
        org.pin = pin
        org.post = post
        org.phone = phone
        org.email = email
        org.established_year = established_year
        org.save()

        return JsonResponse({'status': 'ok'})
    except Organization.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'organization not found'})
    except Exception as e:
        return JsonResponse({'status': 'not ok', 'message': str(e)})


def org_view_vol(request):
    org_id = request.POST.get('user_id')
    try:
        user = User.objects.filter(ORGANIZATION__LOGIN_id=org_id).select_related('ORGANIZATION').order_by('name')
        users = []
        for i in user:
            users.append({
                'id':i.id,
                'name':i.name,
                'age':i.age,
                'phone':i.phone,
                'place':i.place,
                'pin':i.pin,
                'post':i.post,
                'gender':i.gender,
                'email':i.email,
                'blood_group':i.blood_group,
                'photo':i.photo.url if i.photo else None,
                'is_available':i.is_available,
                'LOGIN':i.LOGIN.id
            })
        return JsonResponse({'status':'ok', 'users':users})
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'No users found for this organization'})

def org_delete_vol(request):
    vol = request.POST['id']
    user = User.objects.get(LOGIN=vol)
    user.delete()
    log = Login.objects.get(id=vol)
    log.delete()
    return JsonResponse({'status': 'ok', 'message':'User deleted'})


def org_add_vol(request):
    org_id = request.POST['org_id']
    org = Organization.objects.get(LOGIN=org_id)
    name = request.POST['name']
    age = request.POST['age']
    phone = request.POST['phone']
    place = request.POST['place']
    pin = request.POST['pin']
    post = request.POST['post']
    gender = request.POST['gender']
    email = request.POST['email']
    blood_group = request.POST['blood_group']
    photo = request.FILES.get('photo')

    fs = FileSystemStorage()
    fp = fs.save(photo.name, photo)

    login_details = Login(username=email,password=phone,type='user')
    login_details.save()

    profile = User(
        LOGIN=login_details,
        ORGANIZATION = org,
        name=name,
        age=age,
        phone=phone,
        place=place,
        pin=pin,
        post=post,
        gender=gender,
        email=email,
        blood_group=blood_group,
        photo=fp,
    )
    profile.save()
    return JsonResponse({'status': 'ok', 'message': 'User Added successfully'})


def org_view_available_vol(request):
    try:
        org_id = request.POST['id']
        org = Organization.objects.get(LOGIN=org_id)
        users = User.objects.filter(ORGANIZATION=org,is_available=True)
        user_list = []
        for i in users:
            user_list.append({
                'id':i.id,
                'name':i.name,
                'age':i.age,
                'phone':i.phone,
                'place':i.place,
                'pin':i.pin,
                'post':i.post,
                'gender':i.gender,
                'email':i.email,
                'blood_group':i.blood_group,
                'photo':i.photo.url,
                'LOGIN':i.LOGIN.id
            })
        return JsonResponse({'status':'ok', 'users':user_list})
    except User.DoesNotExist:
        return JsonResponse({'status':'not ok', 'message':'organization illa'})



def ViewMyEvents(request):
    try:
        org_id = request.POST['user_id']
        org = Organization.objects.get(LOGIN=org_id)
        event = Event.objects.filter(ORGANIZATION=org).order_by('-id')
        events = []
        for i in event:
            events.append({
                'id':i.id,
                'event_name':i.event_name,
                'event_details':i.event_details,
                'posted_date':i.posted_date,
                'event_date':i.event_date,
                'status':i.status,
                'count':i.count,
                'venue':i.venue,
                'photo':i.photo.url
            })
        return JsonResponse({'status':'ok','events': events})
    except Event.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'Event illa'})


def ViewInterestedVolunteers(request):
    event_id = request.POST.get('event_id')
    print(event_id)
    if event_id:
        event_response = EventResponse.objects.filter(EVENT=event_id)

        responses = []
        for response in event_response:
            user = response.USER  # Access the User instance linked to the EventResponse
            responses.append({
                'date': response.date,
                'name': user.name,
                'age': user.age,
                'phone': user.phone,
                'gender': user.gender,
                'blood_group': user.blood_group,
                'photo': user.photo.url if user.photo else None,  # Check if photo exists
                'email': user.email
            })

        return JsonResponse({'status': 'ok', 'responses': responses})
    else:
        return JsonResponse({'status': 'error', 'message': 'Event ID not provided'}, status=400)


def OrgSendEventNotification(request):
    try:
        org_id = request.POST['org_id']
        event_name = request.POST['event_name']
        event_details = request.POST['event_details']
        event_date = request.POST['event_date']
        venue = request.POST['venue']
        count = request.POST['count']
        photo = request.FILES['event_photo']

        fs = FileSystemStorage()
        fp = fs.save(photo.name,photo)

        organization = Organization.objects.get(LOGIN=org_id)

        event = Event(
            ORGANIZATION=organization,
            event_name=event_name,
            event_details=event_details,
            event_date=event_date,
            status='needed',
            count=count,
            venue=venue,
            photo=fp
        )
        event.save()
        return JsonResponse({'status':'ok'})
    except Organization.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'error': 'Organization Illa'})


def ViewFeedbacks(request):
    try:
        org_id = request.POST['org_id']
        org = Organization.objects.get(LOGIN=org_id)
        feedback = FeedbackRating.objects.filter(EVENT__EVENT__ORGANIZATION=org).order_by('date')
        feedbacks = []
        for i in feedback:
            feedbacks.append({
                'sender':i.USER.name,
                'event':i.EVENT.EVENT.event_name,
                'event_date':i.EVENT.EVENT.event_date,
                'feedback':i.feedback,
                'rating':i.rating,
                'date':i.date,
                'photo':i.EVENT.EVENT.photo.url
            })
        return JsonResponse({'status':'ok','feedbacks':feedbacks})
    except FeedbackRating.DoesNotExist:
        return JsonResponse({'status':'Not ok','message': 'Feedback Illa'})

def OrgViewComplaints(request):
    try:
        org_id = request.POST['org_id']
        org = Organization.objects.get(LOGIN=org_id)
        complaint = ComplaintForEvent.objects.filter(EVENT__EVENT__ORGANIZATION=org).order_by('-id')
        complaints = []
        for i in complaint:
            complaints.append({
                'id':i.id,
                'event':i.EVENT.EVENT.event_name,
                'user':i.USER.name,
                'complaint':i.complaint,
                'date':i.date,
                'reply':i.reply
            })
        return JsonResponse({'status':'ok','complaints':complaints})
    except Organization.DoesNotExist:
        return JsonResponse({'status':'Not ok','message':'Organization illa'})

def SendReply(request):
    if request.method == 'POST':
        try:
            complaint_id = request.POST['complaint_id']
            reply = request.POST['reply']
            complaint = ComplaintForEvent.objects.get(id=complaint_id)
            complaint.reply = reply
            complaint.save()
            return JsonResponse({'status': 'ok'})
        except ComplaintForEvent.DoesNotExist:
            return JsonResponse({'status': 'Not ok', 'message': 'Complaint does not exist'})
        except Exception as e:
            return JsonResponse({'status': 'Not ok', 'message': str(e)})


def OrgChangePassword(request):
    id = request.POST['id']
    old_password = request.POST.get('current_password')
    new_password = request.POST.get('new_password')
    confirm_password = request.POST.get('confirm_password')

    credentials = Login.objects.filter(id=id, password=old_password)
    if credentials.exists():
        if new_password == confirm_password:
            new_credentials = credentials.update(password=confirm_password)
            if new_credentials:
                return JsonResponse({'status': 'ok', })
            else:
                return JsonResponse({'status': 'not ok', })
        else:
            return JsonResponse({'status': 'not ok', })
    else:
        return JsonResponse({'status': 'not ok', })

def Organization_sendchat(request):
    FROM_id = request.POST['from_id']
    TOID_id = request.POST['to_id']
    print(FROM_id)
    print(TOID_id)
    msg = request.POST['message']

    from  datetime import datetime
    c = Chat()
    c.FROMID_id = FROM_id
    c.TOID_id = TOID_id
    c.message = msg
    c.date = datetime.now()
    c.save()
    return JsonResponse({'status': "ok"})

def Organization_viewchat(request):
    fromid = request.POST["from_id"]
    toid = request.POST["to_id"]

    res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid)).order_by('id')
    l = []

    for i in res:
        l.append({"id": i.id, "msg": i.message, "from": i.FROMID_id, "date": i.date, "to": i.TOID_id})

    return JsonResponse({"status": "ok", 'data': l})



def Organization_sendchat_User(request):
    FROM_id=request.POST['from_id']
    TOID_id=request.POST['to_id']
    print(FROM_id)
    print(TOID_id)
    msg=request.POST['message']

    from  datetime import datetime
    c=Chat()
    c.FROMID_id=FROM_id
    c.TOID_id=TOID_id
    c.message=msg
    c.date=datetime.now()
    c.save()
    return JsonResponse({'status':"ok"})

def Organization_viewchat_User(request):
    fromid = request.POST["from_id"]
    toid = request.POST["to_id"]


    res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid))
    l = []

    for i in res:
        l.append({"id": i.id, "msg": i.message, "from": i.FROMID_id, "date": i.date, "to": i.TOID_id})

    return JsonResponse({"status":"ok",'data':l})





#-----------------------------------------------USER--------------------------------------------------------------------

def user_view_profile(request):
    try:
        user_id = request.POST['id']
        user = User.objects.get(LOGIN=user_id)

        profile = {
            'id': user.id,
            'name': user.name,
            'org_name':user.ORGANIZATION.name,
            'org_phone':user.ORGANIZATION.phone,
            'org_email':user.ORGANIZATION.email,
            'age': user.age,
            'phone': user.phone,
            'place': user.place,
            'pin': user.pin,
            'post': user.post,
            'gender': user.gender,
            'email': user.email,
            'blood_group': user.blood_group,
            'is_available': user.is_available,
            'photo': user.photo.url if user.photo else None
        }

        return JsonResponse({'status': 'ok', 'profile': [profile]})
    except Organization.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'Organization illa'})

def update_availability(request):
    try:
        user_id = request.POST.get('id')
        status = request.POST.get('is_available')  # '1' for available, '0' for not available

        # Fetch the user and update the availability status
        user = User.objects.get(LOGIN=user_id)
        user.is_available = status == '1'  # Set to True if '1', else False
        user.save()  # Save the changes
        return JsonResponse({'status': 'ok'})  # Success response
    except User.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'error': 'User not found'})  # Error if user is not found
    except Exception as e:
        return JsonResponse({'status': 'not ok', 'error': str(e)})  # General error handling

def edit_profile(request):
    try:
        user_id = request.POST['id']
        phone = request.POST['phone']
        place = request.POST['place']
        pin = request.POST['pin']
        post = request.POST['post']
        email = request.POST['email']
        photo = request.FILES.get('photo')

        user = User.objects.get(LOGIN=user_id)
        user.phone = phone
        user.place = place
        user.pin = pin
        user.post = post
        user.email = email

        if photo:
            fs = FileSystemStorage()
            fp = fs.save(photo.name,photo)
            user.photo = fp
            user.save()
        user.save()
        return JsonResponse({'status':'ok'})
    except User.DoesNotExist:
        return JsonResponse({'status':'not ok', 'message':'user does not exists'})

def ViewMyOrganization(request):
    try:
        user_id = request.POST.get('user_id')
        i = User.objects.get(LOGIN=user_id)

        org = {
            'id':i.id,
            'name':i.ORGANIZATION.name,
            'place':i.ORGANIZATION.place,
            'pin':i.ORGANIZATION.pin,
            'post':i.ORGANIZATION.post,
            'phone':i.ORGANIZATION.phone,
            'email':i.ORGANIZATION.email,
            'established_year':i.ORGANIZATION.established_year,
            'photo':i.ORGANIZATION.photo.url,
            'LOGIN':i.ORGANIZATION.LOGIN.id
        }
        return JsonResponse({'status': 'ok', 'profile': [org]})
    except Organization.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'User illa'})


def ViewEvents(request):
    try:
        user_id = request.POST['user_id']
        user = User.objects.get(LOGIN=user_id)
        today = timezone.now().date()

        events = Event.objects.filter(
            ORGANIZATION=user.ORGANIZATION,
            status='needed',
            posted_date__lte=today,
            event_date__gte=today
        ).order_by('event_date')

        events_data = []
        for event in events:
            # Check if the user has already sent a request for this event
            already_requested = EventResponse.objects.filter(EVENT=event, USER=user).exists()

            events_data.append({
                'event_id': event.id,
                'event_name': event.event_name,
                'event_details': event.event_details,
                'posted_date': event.posted_date.strftime('%Y-%m-%d'),
                'event_date': event.event_date.strftime('%Y-%m-%d'),
                'status': event.status,
                'count': event.count,
                'venue': event.venue,
                'photo': event.photo.url if event.photo else None,
                'already_requested': already_requested,  # Add this field
            })

        return JsonResponse({
            'status': 'ok',
            'events': events_data,
        })
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})



def SendEventRequest(request):
    try:
        user_id = request.POST['user_id']
        user = User.objects.get(LOGIN=user_id)
        event_id = request.POST['event_id']
        event = Event.objects.get(id=event_id)

        if EventResponse.objects.filter(EVENT=event,USER=user).exists():
            return JsonResponse({'status': 'error', 'message': 'You cannot send more than 1 request'})

        EventResponse.objects.create(EVENT=event,USER=user)
        return JsonResponse({'status': 'ok'})
    except Event.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Id Not found'})

def UserChangePassword(request):
    id = request.POST['id']
    old_password = request.POST.get('current_password')
    new_password = request.POST.get('new_password')
    confirm_password = request.POST.get('confirm_password')

    credentials = Login.objects.filter(id=id, password=old_password)
    if credentials.exists():
        if new_password == confirm_password:
            new_credentials = credentials.update(password=confirm_password)
            if new_credentials:
                return JsonResponse({'status': 'ok', })
            else:
                return JsonResponse({'status': 'not ok', })
        else:
            return JsonResponse({'status': 'not ok', })
    else:
        return JsonResponse({'status': 'not ok', })

def SendAppComplaint(request):
    try:
        user_id = request.POST['id']
        complaint = request.POST['complaint']
        user = User.objects.get(LOGIN=user_id)

        ComplaintForApp.objects.create(USER=user,complaint=complaint)
        return JsonResponse({'status': 'ok'})
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User Illa tto'})

def ViewMyComplaints(request):
    try:
        user_id = request.POST['id']
        user = User.objects.get(LOGIN=user_id)
        complaints = ComplaintForApp.objects.filter(USER=user).order_by('-id')
        complaint = []
        for i in complaints:
            complaint.append({
                'id':i.id,
                'complaint':i.complaint,
                'date':i.date,
                'reply':i.reply
            })
        return JsonResponse({'status':'ok', 'complaint':complaint})
    except User.DoesNotExist:
        return JsonResponse({'status':'not ok', 'message': 'User Illa'})

def DeleteMyComplaint(request):
    try:
        complaint_id = request.POST['complaint_id']
        com = ComplaintForApp.objects.get(id=complaint_id)
        com.delete()
        return JsonResponse({'status': 'ok'})
    except ComplaintForApp.DoesNotExist:
        return JsonResponse({'status':'not ok', 'message': 'Complaint Illa'})


def ViewPastEvents(request):
    try:
        current_date = timezone.now().date()
        events = Event.objects.filter(event_date__lt=current_date).order_by('event_date')

        events_data = []
        for event in events:
            events_data.append({
                'event_id': event.id,
                'event_name': event.event_name,
                'event_details': event.event_details,
                'posted_date': event.posted_date.strftime('%Y-%m-%d'),
                'event_date': event.event_date.strftime('%Y-%m-%d'),
                'status': event.status,
                'count': event.count,
                'venue': event.venue,
                'photo': event.photo.url if event.photo else None,
            })

        return JsonResponse({'status': 'ok','events': events_data,})
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})

import datetime
def ViewMyPastEvents(request):
    try:
        user_id = request.POST['user_id']
        user = User.objects.get(LOGIN=user_id)
        event_responses = EventResponse.objects.filter(USER=user)
        current_date = datetime.date.today()

        completed_events = []
        for i in event_responses:
            if i.EVENT.event_date < current_date:
                completed_events.append({
                    'id': i.id,
                    'event_name': i.EVENT.event_name,
                    'event_details': i.EVENT.event_details,
                    'event_date': i.EVENT.event_date.strftime('%Y-%m-%d'),
                    'venue': i.EVENT.venue,
                    'photo': i.EVENT.photo.url,
                    'event_request': i.date.strftime('%Y-%m-%d')
                })

        return JsonResponse({'status': 'ok', 'events': completed_events})

    except User.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'User not found'})
    except EventResponse.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'No events found for this user'})

def ViewMorePastEvents(request):
    try:
        event_response_id = request.POST['event_id']
        event_responses = EventResponse.objects.filter(id=event_response_id)
        current_date = datetime.date.today()

        completed_events = []
        for i in event_responses:
            if i.EVENT.event_date < current_date:
                has_feedback = FeedbackRating.objects.filter(USER=i.USER, EVENT=i).exists()
                has_complaint = ComplaintForEvent.objects.filter(USER=i.USER, EVENT=i).exists()

                completed_events.append({
                    'id': i.id,
                    'user': i.USER.id,
                    'event_name': i.EVENT.event_name,
                    'event_details': i.EVENT.event_details,
                    'event_date': i.EVENT.event_date.strftime('%Y-%m-%d'),
                    'venue': i.EVENT.venue,
                    'photo': i.EVENT.photo.url if i.EVENT.photo else '',
                    'event_request': i.date.strftime('%Y-%m-%d'),
                    'has_feedback': has_feedback,
                    'has_complaint': has_complaint,
                })

        return JsonResponse({'status': 'ok', 'events': completed_events})

    except EventResponse.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'No events found for this user'})
    except Exception as e:
        return JsonResponse({'status': 'not ok', 'message': str(e)})


def SendFeedbackAboutEvent(request):
    try:
        user_id = request.POST['id']
        user = User.objects.get(LOGIN=user_id)
        event_id = request.POST['event_id']
        event = EventResponse.objects.get(id=event_id)
        feedback = request.POST['feedback']
        rating = request.POST['rating']

        if FeedbackRating.objects.filter(USER=user,EVENT=event).exists():
            return JsonResponse({'status': 'not ok', 'message': 'Already added'})

        FeedbackRating.objects.create(
            USER=user,
            EVENT=event,
            feedback=feedback,
            rating=rating
        )
        return JsonResponse({'status': 'ok'})
    except EventResponse.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'No events found for this user'})

def SendComplaintAboutEvent(request):
    try:
        user_id = request.POST['id']
        user = User.objects.get(LOGIN=user_id)
        event_id = request.POST['event_id']
        event = EventResponse.objects.get(id=event_id)
        complaint = request.POST['complaint']

        if ComplaintForEvent.objects.filter(USER=user,EVENT=event).exists():
            return JsonResponse({'status': 'not ok', 'message': 'Already added'})

        ComplaintForEvent.objects.create(
            USER=user,
            EVENT=event,
            complaint=complaint,
        )
        return JsonResponse({'status': 'ok'})
    except EventResponse.DoesNotExist:
        return JsonResponse({'status': 'not ok', 'message': 'No events found for this user'})


def ViewEventComplaintReply(request):
    try:
        user_id = request.POST['user_id']
        user = User.objects.get(LOGIN=user_id)
        event_id = request.POST['event_id']
        complaint = ComplaintForEvent.objects.get(EVENT=event_id, USER=user)

        # Modified to return in expected format
        response = {
            'status': 'ok',
            'events': [{
                'event_id': complaint.EVENT.id,
                'complaint': complaint.complaint,
                'reply': complaint.reply or 'No reply yet',
                'date': complaint.date.strftime('%Y-%m-%d'),
            }]
        }
        return JsonResponse(response)
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found.'})
    except ComplaintForEvent.DoesNotExist:
        return JsonResponse({'status': 'ok', 'events': []})  # Return empty array instead of error
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})

def ViewPostedEventFeedback(request):
    try:
        user_id = request.POST['user_id']
        user = User.objects.get(LOGIN=user_id)
        event_id = request.POST['event_id']
        feedback = FeedbackRating.objects.get(USER=user, EVENT=event_id)

        # Modified to return in expected format
        response = {
            'status': 'ok',
            'events': [{
                'event_id': feedback.EVENT.id,
                'feedback': feedback.feedback,
                'rating': feedback.rating,
                'date': feedback.date.strftime('%Y-%m-%d'),
            }]
        }
        return JsonResponse(response)
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found.'})
    except FeedbackRating.DoesNotExist:  # Fixed exception type
        return JsonResponse({'status': 'ok', 'events': []})  # Return empty array instead of error
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


def User_sendchat_Org(request):
    FROM_id=request.POST['from_id']
    TOID_id=request.POST['to_id']
    msg=request.POST['message']

    from  datetime import datetime
    c=Chat()
    c.FROMID_id=FROM_id
    c.TOID_id=TOID_id
    c.message=msg
    c.date=datetime.now()
    c.save()
    return JsonResponse({'status':"ok"})

def User_viewchat_Org(request):
    fromid = request.POST["from_id"]
    toid = request.POST["to_id"]

    res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid)).order_by('id')
    l = []

    for i in res:
        time_str = i.date.strftime("%I:%M %p")
        l.append({
            "id": i.id,
            "msg": i.message,
            "from": i.FROMID_id,
            "date": i.date.strftime("%Y-%m-%d"),
            "time": time_str,
            "to": i.TOID_id
        })

    return JsonResponse({"status": "ok", 'data': l})