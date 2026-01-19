require 'maruku'
require 'yaml'
require 'digest'

# Simple in-memory cache
$markdown_cache = {}

# Render Markdown to HTML
# Supports:
# - Multi-language folders (content/en, content/es, etc.)
# - Front-matter metadata (YAML at the top)
# - Caching based on file hash
def render_markdown(file, lang = 'en')
  path = File.join('content', lang, "#{file}.md")

  unless File.exist?(path)
    return "<p>Error: Markdown file not found: #{file}</p>"
  end

  # Compute a simple hash for caching
  hash = Digest::MD5.hexdigest(File.read(path, encoding: 'utf-8'))

  # Return cached HTML if exists
  return $markdown_cache[hash] if $markdown_cache.key?(hash)

  content = File.read(path, encoding: 'utf-8')

  # Check for front-matter (YAML block at the top)
  metadata = {}
  if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
    yaml_block = $1
    metadata = YAML.safe_load(yaml_block) || {}
    content = content.sub(/\A---\s*\n.*?\n---\s*\n/m, '')
  end

  html = Maruku.new(content).to_html

  # Cache it
  $markdown_cache[hash] = { html: html, metadata: metadata }

  $markdown_cache[hash]
end
