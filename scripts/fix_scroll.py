import re

def main():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_home_screen/student_home_screen.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the StreamBuilder builder function in _showNotificationsDialog
    # We want to replace from "return SingleChildScrollView(" up to the end of the builder
    
    old_code = """                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CustomIconWidget(iconName: 'notifications', color: Color(0xFF00D4FF), size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(iconName: 'close', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (notifs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No recent activity.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...notifs.map((n) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNotificationItem(
                            n['title'] as String,
                            n['desc'] as String,
                            n['icon'] as String,
                            n['color'] as Color,
                            n['timeStr'] as String,
                          ),
                        );
                      }).toList(),
                  ],
                  ),
                );"""

    new_code = """                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CustomIconWidget(iconName: 'notifications', color: Color(0xFF00D4FF), size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(iconName: 'close', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notifs.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No recent activity.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ...notifs.map((n) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildNotificationItem(
                                    n['title'] as String,
                                    n['desc'] as String,
                                    n['icon'] as String,
                                    n['color'] as Color,
                                    n['timeStr'] as String,
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );"""
                
    if old_code in content:
        content = content.replace(old_code, new_code)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Updated student_home_screen.dart")
    else:
        print("Could not find the exact old_code block.")

if __name__ == '__main__':
    main()
