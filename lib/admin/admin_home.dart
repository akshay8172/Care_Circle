import 'package:flutter/material.dart';
import 'package:care_circle_new/admin/ManageOrganizations.dart';
import 'package:care_circle_new/admin/ManageUsers.dart';
import 'package:care_circle_new/admin/view_feedbacks.dart';
import 'package:care_circle_new/admin/ViewComplaints.dart';
import 'package:care_circle_new/main_files/login.dart';
import 'package:care_circle_new/admin/ChangePassword.dart';
import 'package:care_circle_new/admin/view_report.dart';
import 'package:care_circle_new/admin/ChatViewOrganizations.dart';

class admin_home_full extends StatefulWidget {
  const admin_home_full({super.key});

  @override
  State<admin_home_full> createState() => _admin_home_fullState();
}

class _admin_home_fullState extends State<admin_home_full> {
  final ScrollController _scrollController = ScrollController();
  double _scrollFadeExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    setState(() {
      _scrollFadeExtent = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.feedback,
                title: 'View Feedback',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewFeedbacks())),
              ),
              _buildDrawerItem(
                icon: Icons.password_sharp,
                title: 'Change Password',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminChangePassword())),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  _onScroll();
                }
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, Colors.blue.shade900],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset('assets/images/admin_image.png', height: 150),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome to the Admin Dashboard!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Grid of Action Cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildActionCard(
                            icon: Icons.business,
                            title: 'Manage Organizations',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageOrganizationsPage())),
                          ),
                          _buildActionCard(
                            icon: Icons.chat,
                            title: 'Chat with Organization',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminChatViewOrganization())),
                          ),
                          _buildActionCard(
                            icon: Icons.people,
                            title: 'Manage Users',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUserPage())),
                          ),
                          _buildActionCard(
                            icon: Icons.assessment,
                            title: 'View Event Report',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewReport())),
                          ),
                          _buildActionCard(
                            icon: Icons.report_problem,
                            title: 'Manage Complaints',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewComplaints())),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(_scrollFadeExtent),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstOut,
              child: Container(
                height: 80,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: Colors.white,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 28),
                color: Colors.blue.shade700,
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const admin_home_full()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue.shade700),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}