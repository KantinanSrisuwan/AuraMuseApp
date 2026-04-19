import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

enum NotifType {
  verified,
  reportConfirmed,
  reportPending,
  reportRejected,
  deckRejected,
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return "-";
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // Helper สำหรับแปลงข้อมูลป้องการ Error กรณีข้อมูลเป็น List
  String _getString(dynamic value) {
    if (value == null) return "-";
    if (value is List) {
      return value.join(", ");
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: Text("Please Login")));

    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textWhite,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "การแจ้งเตือน",
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('decks')
            .where('creator_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cosmicCyan),
            );
          }

          final decks = snapshot.data!.docs;
          final List<Widget> notificationWidgets = [];

          for (var doc in decks) {
            final data = doc.data() as Map<String, dynamic>;
            final String deckStatus = data['deck_status'] ?? 'unverified';
            final bool? reportAccept = data['report_accept'];
            final String reports = _getString(data['reports']);
            final String rejectReportStr = _getString(
              data['reject_report_str'],
            );

            // 1. Verified
            if (deckStatus == 'verified') {
              notificationWidgets.add(
                _buildNotifItem(context, doc, NotifType.verified),
              );
            }
            // 2. Report Confirmed
            if (deckStatus == 'unverified' && reportAccept == true) {
              notificationWidgets.add(
                _buildNotifItem(context, doc, NotifType.reportConfirmed),
              );
            }
            // 3. Report Pending
            if (reports != "-" && reports.isNotEmpty) {
              notificationWidgets.add(
                _buildNotifItem(context, doc, NotifType.reportPending),
              );
            }
            // 4. Report Rejected
            if (reportAccept == false &&
                rejectReportStr != "-" &&
                rejectReportStr.isNotEmpty) {
              notificationWidgets.add(
                _buildNotifItem(context, doc, NotifType.reportRejected),
              );
            }
            // 5. Deck Rejected
            if (deckStatus == 'reject') {
              notificationWidgets.add(
                _buildNotifItem(context, doc, NotifType.deckRejected),
              );
            }
          }

          if (notificationWidgets.isEmpty) {
            return const Center(
              child: Text(
                "ไม่มีการแจ้งเตือนในขณะนี้",
                style: TextStyle(color: AppColors.textWhiteMuted),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: notificationWidgets,
          );
        },
      ),
    );
  }

  Widget _buildNotifItem(
    BuildContext context,
    DocumentSnapshot doc,
    NotifType type,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final String coverImage = data['cover_image'] ?? '';
    String title = "";
    String subTitle = "";
    Color themeColor = Colors.white;
    IconData icon = Icons.notifications;

    switch (type) {
      case NotifType.verified:
        title = "Deck ของคุณได้รับอนุญาตแล้ว ✨";
        subTitle = "สำรับ: ${data['deck_name']}";
        themeColor = AppColors.actionGreen;
        icon = Icons.verified;
        break;
      case NotifType.reportConfirmed:
        title = "การรายงาน Deck ของคุณได้รับการยืนยัน";
        subTitle = "Deck ถูกระงับชั่วคราวเพื่อตรวจสอบ";
        themeColor = AppColors.errorRed;
        icon = Icons.report_gmailerrorred;
        break;
      case NotifType.reportPending:
        title = "สำรับของคุณถูกรายงาน";
        subTitle = "อยู่ระหว่างการตรวจสอบโดยระบบ";
        themeColor = AppColors.actionAmber;
        icon = Icons.warning_amber_rounded;
        break;
      case NotifType.reportRejected:
        title = "การรายงาน Deck ถูกปฏิเสธ";
        subTitle = "ตรวจสอบรายละเอียดการโต้แย้ง";
        themeColor = AppColors.cosmicCyan;
        icon = Icons.info_outline;
        break;
      case NotifType.deckRejected:
        title = "สำรับของคุณไม่ผ่านการอนุมัติ";
        subTitle = "ดูเหตุผลและแก้ไขความถูกต้อง";
        themeColor = AppColors.errorRed;
        icon = Icons.cancel_outlined;
        break;
    }

    return GestureDetector(
      onTap: () => _showDetailDialog(context, doc, type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassDecoration(radius: 16),
        child: Row(
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 50,
                height: 70,
                color: AppColors.backgroundNavyLight,
                child: coverImage.isNotEmpty
                    ? Image.network(
                        coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.style, color: Colors.white24),
                      )
                    : const Icon(Icons.style, color: Colors.white24),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subTitle,
                    style: const TextStyle(
                      color: AppColors.textWhiteMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status Icon logic
            Icon(
              icon,
              color: themeColor.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    DocumentSnapshot doc,
    NotifType type,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final String coverImage = data['cover_image'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(25),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: AppColors.glassDecoration(
              radius: 20,
            ).copyWith(color: AppColors.backgroundNavyLight.withOpacity(0.95)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "รายละเอียด",
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textWhite,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 15),
                  
                  // Large Cover Image in Dialog
                  Center(
                    child: Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: coverImage.isNotEmpty
                            ? Image.network(
                                coverImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.style, size: 50, color: Colors.white10)),
                              )
                            : const Center(child: Icon(Icons.style, size: 50, color: Colors.white10)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),

                  _buildDetailRow("ชื่อสำรับ", data['deck_name'] ?? '-'),
                  _buildDetailRow("หมายเลขเด็ค", doc.id),
                  _buildDetailRow("เจ้าของ", data['creator_username'] ?? '-'),
                  _buildDetailRow(
                    "วันที่สร้าง",
                    _formatDate(data['created_at']),
                  ),

                  if (type == NotifType.verified) ...[
                    _buildDetailRow(
                      "วันที่อนุมัติ",
                      _formatDate(data['accept_timestamp']),
                    ),
                    _buildDetailRow(
                      "สถานะ",
                      "Verified ✨",
                      color: AppColors.actionGreen,
                    ),
                  ],

                  if (type == NotifType.reportPending) ...[
                    _buildDetailRow(
                      "ความเห็นการรายงาน",
                      _getString(data['reports']),
                      color: AppColors.actionAmber,
                    ),
                  ],

                  if (type == NotifType.reportRejected) ...[
                    _buildDetailRow(
                      "เหตุผลที่ปฏิเสธรายงาน",
                      _getString(data['reject_report_str']),
                      color: AppColors.cosmicCyan,
                    ),
                  ],

                  if (type == NotifType.deckRejected) ...[
                    _buildDetailRow(
                      "เหตุผลที่ไม่ผ่านกการอนุมัติ",
                      _getString(data['reject_reason']),
                      color: AppColors.errorRed,
                    ),
                  ],

                  if (type == NotifType.reportConfirmed) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "⚠️ Deck ของคุณถูกตรวจสอบพบว่ามีการละเมิดกฎ และได้รับการยืนยันการรายงานแล้ว",
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundNavy,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.glassBorder),
                          ),
                        ),
                        child: const Text(
                          "ปิด",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textWhiteMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
