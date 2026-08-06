import os

filepath = 'lib/presentation/unity_ar_screen/unity_ar_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """            if (_showGuide) _buildGuideOverlay(theme),

          ],
        ),
      ),
    );"""

new_block = """            if (_showGuide) _buildGuideOverlay(theme),

            // Top-left Back Button
            Positioned(
              top: 24,
              left: 24,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );"""

content = content.replace(old_block, new_block)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Added back button!')
