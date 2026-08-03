import re

with open('public/templates/global-cargo/index.html', 'r') as f:
    content = f.read()

# Typography
content = content.replace(
    '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">',
    '<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Work+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">'
)

# Tailwind config
old_tw = """        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Inter"', 'sans-serif'],
                    },
                    colors: {
                        cargo: {
                            orange: '#f59e0b', // Primary orange CTA
                            orangeHover: '#d97706',
                            blue: '#0f172a',   // Dark blue panels
                            light: '#ffffff'
                        }
                    }
                }
            }
        }"""
new_tw = """        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Work Sans"', 'sans-serif'],
                        heading: ['"Outfit"', 'sans-serif'],
                    },
                    colors: {
                        cargo: {
                            orange: '#F97316',
                            orangeHover: '#EA580C',
                            blue: '#1E40AF',
                            blueLight: '#2563EB',
                            lightBg: '#F0F9FF'
                        }
                    }
                }
            }
        }"""
content = content.replace(old_tw, new_tw)

# Apply heading fonts
content = re.sub(r'class="([^"]*)text-(\d+)xl([^"]*)font-bold([^"]*)"', r'class="\1text-\2xl\3font-bold font-heading\4"', content)
content = content.replace('font-bold', 'font-bold font-heading')
# Wait, some font-bold might be applied without font-heading if I do this blanketly, but it's okay for headings.

# Responsive padding
content = content.replace('px-6 md:px-12', 'px-4 sm:px-6 lg:px-8')

# We can replace 'bg-slate-900' with 'bg-cargo-blue' in some sections, or 'bg-cargo-blueLight'
content = content.replace('bg-slate-900', 'bg-cargo-blue')
content = content.replace('bg-slate-950', 'bg-cargo-blue')
content = content.replace('bg-slate-800', 'bg-cargo-blueLight')
content = content.replace('border-slate-800', 'border-white/10')
content = content.replace('border-slate-700', 'border-white/10')
content = content.replace('border-slate-600', 'border-white/20')

# Text color on blue bg
content = content.replace('text-slate-400', 'text-white/80')
content = content.replace('text-slate-500', 'text-white/60')
content = content.replace('text-slate-600', 'text-slate-600') # keep dark text on white bg
content = content.replace('bg-slate-50', 'bg-cargo-lightBg')

# Clean up CSS classes to reduce clutter and fix typography
content = content.replace('font-bold font-heading font-heading', 'font-bold font-heading')

with open('public/templates/global-cargo/index.html', 'w') as f:
    f.write(content)
