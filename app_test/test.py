import os

# 현재 디렉토리부터 트리 구조 출력
def list_files(startpath):
    tree_structure = []
    for root, dirs, files in os.walk(startpath):
        level = root.replace(startpath, '').count(os.sep)
        indent = ' ' * 4 * level
        tree_structure.append(f"{indent}{os.path.basename(root)}/")
        sub_indent = ' ' * 4 * (level + 1)
        for file in files:
            tree_structure.append(f"{sub_indent}{file}")
    return "\n".join(tree_structure)

current_directory = os.getcwd()
tree_structure = list_files(current_directory)

print(tree_structure)
