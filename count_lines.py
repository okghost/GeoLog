import os
import fnmatch

def count_lines_of_code(directory):
    total_lines = 0
    excluded_dirs = ['node_modules', '.git', 'build', 'dist']
    excluded_files = ['*.md', '*.json', '*.log', '*.txt', '*.jpg', '*.png', '*.gif', '*.svg', '*.ico', '*.webp', '*.DS_Store']

    for root, dirs, files in os.walk(directory):
        # Exclude directories
        dirs[:] = [d for d in dirs if d not in excluded_dirs]

        print(f"Entering Directory: {root}")

        for file in files:
            # Check if the file should be excluded
            if any(fnmatch.fnmatch(file, pattern) for pattern in excluded_files):
                continue

            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    file_lines = sum(1 for line in f if line.strip())
                    total_lines += file_lines
                    print(f"   > {file}: {file_lines}")
            except Exception as e:
                print(f"Error reading file {file_path}: {e}")

    return total_lines

project_path = './'
total_lines = count_lines_of_code(project_path)
print(f"Total lines of code: {total_lines}")
