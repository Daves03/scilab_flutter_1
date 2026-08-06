import re

def main():
    # 1. Fix app_routes.dart
    routes_path = 'd:/StudioProjects/scilab_flutter_1/lib/routes/app_routes.dart'
    with open(routes_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add Course import if missing
    if "import '../models/course_model.dart';" not in content:
        content = content.replace("import '../models/user_model.dart';", "import '../models/user_model.dart';\nimport '../models/course_model.dart';")

    # Fix the syntax error
    content = content.replace("transitionDuration: const Duration(milliseconds: 280),\n              ),\n              },", "transitionDuration: const Duration(milliseconds: 280),\n              );\n              },")

    with open(routes_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print("Fixed app_routes.dart")

    # 2. Fix student_home_screen.dart
    home_path = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_home_screen/student_home_screen.dart'
    with open(home_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Undo the bad replacements for _buildAlertCard and _buildStatCard
    # They both look like:
    # return GestureDetector(
    #   onTap: onTap,
    #   child: Container(
    #     padding: const EdgeInsets.all(16),
    # ...
    # And have a missing closing parenthesis at the end.
    
    # We will search for _buildAlertCard and fix its return
    old_alert = """  Widget _buildAlertCard({required String title, required String subtitle, required String icon, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),"""
    new_alert = """  Widget _buildAlertCard({required String title, required String subtitle, required String icon, required Color color}) {
    return Container(
        padding: const EdgeInsets.all(16),"""
    content = content.replace(old_alert, new_alert)

    # Search for _buildStatCard and fix its return
    old_stat = """  Widget _buildStatCard({required String title, required String value, required String icon, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),"""
    new_stat = """  Widget _buildStatCard({required String title, required String value, required String icon, required Color color}) {
    return Container(
        padding: const EdgeInsets.all(16),"""
    content = content.replace(old_stat, new_stat)
    
    # The closing parenthesis error: I added a `))` at the end of every `Container` that matched.
    # The replaced end block was:
    #                   ),
    #                 ],
    #               ),
    #             ),
    #           ],
    #         ),
    #       ),
    #     ));
    # Let's fix the bad closing parens that belong to _buildAlertCard and _buildStatCard.
    # We can just change all instances of that block, but we need ONE of them to keep the `))` which is for `_buildNotificationItem`.
    # Wait, instead of guessing, let's regex specifically the end of _buildAlertCard and _buildStatCard.
    # Actually, it's safer to just replace ALL `));` blocks with `);` and then manually fix `_buildNotificationItem`.

    bad_end_block = """                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));"""
    good_end_block = """                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );"""
    
    # Replace all to the normal one:
    content = content.replace(bad_end_block, good_end_block)
    
    # Now explicitly add `))` to the end of _buildNotificationItem only.
    # Let's find _buildNotificationItem and replace its specific end block.
    
    old_notif_func = """                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""
    
    new_notif_func = """                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }"""
    content = content.replace(old_notif_func, new_notif_func)
    
    with open(home_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print("Fixed student_home_screen.dart")

if __name__ == '__main__':
    main()
