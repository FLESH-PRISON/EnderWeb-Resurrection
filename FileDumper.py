import os
from datetime import datetime

def generate_directory_md(start_path, output_file):
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Directory Structure\n\n")
        _write_directory(start_path, '', f)

def _write_directory(path, indent, f):
    for item in sorted(os.listdir(path)):
        full_path = os.path.join(path, item)
        stats = os.stat(full_path)
        size = stats.st_size
        modified = datetime.fromtimestamp(stats.st_mtime).strftime('%Y-%m-%d %H:%M')
        
        if os.path.isdir(full_path):
            f.write(f"{indent}### [DIR] {item}/\n")
            f.write(f"{indent}_Modified: {modified}_\n\n")
            _write_directory(full_path, indent + '  ', f)
        else:
            f.write(f"{indent}- **{item}** ({size:,} bytes)\n")
            f.write(f"{indent}  _Modified: {modified}_\n\n")

# Usage
generate_directory_md('.', 'directory_structure.md')