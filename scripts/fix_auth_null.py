import os

filepath = 'lib/services/auth_service.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("if (googleUser == null) { return false; }", "if (googleUser == null) { return null; }")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed null return!')
