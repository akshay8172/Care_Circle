import 'package:flutter/material.dart';
import 'package:care_circle_new/user/my_profile.dart';
import 'package:care_circle_new/user/ViewMyOrganization.dart';
import 'package:care_circle_new/user/ViewEvents.dart';
import 'package:care_circle_new/user/ChangePassword.dart';
import 'package:care_circle_new/user/SendAppComplaint.dart';
import 'package:care_circle_new/user/ViewPastEvents.dart';
import 'package:care_circle_new/user/ViewMyPastEvents.dart';
import 'package:care_circle_new/main_files/login.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final ScrollController _scrollController = ScrollController();
  double _scrollFadeExtent = 0.0;
  int _selectedIndex = 0;

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
          'Care Circle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          ),
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
            children: [
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome To Care Circle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // _buildDrawerItem(
              //   icon: Icons.person,
              //   title: 'View Profile',
              //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile())),
              // ),
              _buildDrawerItem(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserChangePassword())),
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'View My Past Event History',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyPastEvents())),
              ),
              _buildDrawerItem(
                icon: Icons.history_toggle_off_rounded,
                title: 'View Past Events',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPastEvents())),
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
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: Icon(Icons.person, size: 35, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 15),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Explore your care circle',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildActionCard(
                          icon: Icons.business,
                          label: 'View Organization',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMyOrganization())),
                        ),
                        _buildActionCard(
                          icon: Icons.notifications,
                          label: 'View Events',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEvents())),
                        ),
                        _buildActionCard(
                          icon: Icons.report,
                          label: 'Manage Complaints',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppComplaint())),
                        ),
                      ],
                    ),
                  ],
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
      bottomNavigationBar: NavigationBar(
        elevation: 8,
        height: 65,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
            // Already on home
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEvents()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile()));
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note, color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Profile',
          ),
        ],
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
    required String label,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 12),
              Text(
                label,
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