import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AttachmentPopupDemo extends StatefulWidget {
  @override
  _AttachmentPopupDemoState createState() => _AttachmentPopupDemoState();
}

class _AttachmentPopupDemoState extends State<AttachmentPopupDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPopupVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _togglePopup() {
    if (_isPopupVisible) {
      _controller.reverse().then((_) {
        setState(() {
          _isPopupVisible = false;
        });
      });
    } else {
      setState(() {
        _isPopupVisible = true;
      });
      _controller.forward();
    }
  }

  Widget _buildAttachmentPopup() {
    if (!_isPopupVisible) return SizedBox.shrink();

    return Positioned(
      bottom: 80,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.white,
          elevation: 4,
          // shape: CircleBorder(),
          child: Container(
            width: Get.width * 0.80 ,
            height: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: 6,
                itemBuilder: (context, index){
              return _buildAttachmentItem(Icons.insert_drive_file, "Document");
              // _buildAttachmentItem(Icons.camera_alt, "Camera"),
              // _buildAttachmentItem(Icons.photo, "Gallery"),
              // _buildAttachmentItem(Icons.location_on, "Location"),
              // _buildAttachmentItem(Icons.person, "Contact"),
            })
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue,
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WhatsApp-like Popup")),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton.icon(
              onPressed: _togglePopup,
              icon: Icon(Icons.attach_file),
              label: Text("Show Attachments"),
            ),
          ),
          _buildAttachmentPopup(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}