from django.urls import path
from MyApp import views

urlpatterns = [
    path('login',views.login),
    path('admin_view_organization',views.admin_view_organization),
    path('admin_block_organization',views.admin_block_organization),
    path('admin_unblock_organization',views.admin_unblock_organization),
    path('admin_view_users',views.admin_view_users),
    path('admin_block_users',views.admin_block_users),
    path('admin_unblock_users',views.admin_unblock_users),
    path('AdminViewFeedbacks',views.AdminViewFeedbacks),
    path('AdminViewComplaint',views.AdminViewComplaint),
    path('AdminSendReply',views.AdminSendReply),
    path('AdminChangePassword', views.AdminChangePassword),
    path('AdminViewEvents',views.AdminViewEvents),
    path('AdminChatViewOrganization',views.AdminChatViewOrganization),

    path('Admin_sendchat',views.Admin_sendchat),
    path('Admin_viewchat',views.Admin_viewchat),

    #----------------------------------------ADMIN--------------------------------------------------------------------------



    path('admin_add_organization', views.admin_add_organization), # Ith Organization nte registration function aahn
    path('org_view_profile',views.org_view_profile),
    path('OrgEditProfile',views.OrgEditProfile),
    path('org_view_vol',views.org_view_vol),
    path('org_add_vol',views.org_add_vol),
    path('org_delete_vol',views.org_delete_vol),
    path('org_view_available_vol',views.org_view_available_vol),
    path('OrgSendEventNotification',views.OrgSendEventNotification),
    path('ViewInterestedVolunteers',views.ViewInterestedVolunteers),
    path('ViewMyEvents',views.ViewMyEvents),
    path('ViewFeedbacks',views.ViewFeedbacks),
    path('OrgViewComplaints',views.OrgViewComplaints),
    path('SendReply',views.SendReply),
    path('OrgChangePassword',views.OrgChangePassword),
    path('Organization_sendchat', views.Organization_sendchat),
    path('Organization_viewchat', views.Organization_viewchat),

    path('Organization_sendchat_User', views.Organization_sendchat_User),
    path('Organization_viewchat_User', views.Organization_viewchat_User),

#-----------------------------------ORGANIZATION------------------------------------------------------------------------

    path('user_view_profile',views.user_view_profile),
    path('update_availability',views.update_availability),
    path('edit_profile',views.edit_profile),
    path('ViewMyOrganization',views.ViewMyOrganization),
    path('ViewEvents',views.ViewEvents),
    path('ViewPastEvents',views.ViewPastEvents),
    path('ViewMorePastEvents',views.ViewMorePastEvents),
    path('ViewMyPastEvents',views.ViewMyPastEvents),
    path('SendEventRequest',views.SendEventRequest),
    path('UserChangePassword',views.UserChangePassword),
    path('ViewMyComplaints',views.ViewMyComplaints),
    path('SendAppComplaint',views.SendAppComplaint),
    path('DeleteMyComplaint',views.DeleteMyComplaint),
    path('SendFeedbackAboutEvent',views.SendFeedbackAboutEvent),
    path('SendComplaintAboutEvent',views.SendComplaintAboutEvent),
    path('ViewEventComplaintReply',views.ViewEventComplaintReply),
    path('ViewPostedEventFeedback',views.ViewPostedEventFeedback),


    path('User_sendchat_Org',views.User_sendchat_Org),
    path('User_viewchat_Org',views.User_viewchat_Org),






]
