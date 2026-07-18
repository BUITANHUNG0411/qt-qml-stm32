import re
import sys

def minify_markdown(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove HTML comments
    content = re.sub(r'<!--.*?-->', '', content, flags=re.DOTALL)
    
    # Condense tables into bullet points
    def table_to_bullets(match):
        rows = match.group(0).strip().split('\n')
        if len(rows) < 3: return match.group(0) # Not a real table
        bullets = []
        for row in rows[2:]: # Skip header and separator
            cols = [c.strip() for c in row.split('|')[1:-1]]
            if len(cols) >= 2:
                bullets.append(f"- **{cols[0]}**: {cols[1]}")
        return '\n'.join(bullets)

    # Simple markdown table regex
    content = re.sub(r'(\|.*?\|\n\|[-:| ]+\|\n(?:\|.*?\|\n)+)', table_to_bullets, content)

    # Remove extra blank lines
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    with open(filepath, 'w') as f:
        f.write(content)

for f in sys.argv[1:]:
    minify_markdown(f)
