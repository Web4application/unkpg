# Gemfile
gem 'sinatra'
gem 'json'
gem 'fileutils'

# app.rb
require 'sinatra'
require 'json'
require 'fileutils'
require 'time'

# Ensure feedback folder exists
FEEDBACK_DIR = File.join('content', 'en', 'feedback')
FileUtils.mkdir_p(FEEDBACK_DIR)

# POST endpoint for contact form
post '/api/contact' do
  content_type :json

  # Parse JSON body
  request.body.rewind
  data = JSON.parse(request.body.read) rescue {}

  email = data['email']
  message = data['message']

  if email.nil? || message.nil? || email.strip.empty? || message.strip.empty?
    status 400
    return { error: "Email and message are required" }.to_json
  end

  # Save message as Markdown file
  timestamp = Time.now.utc.iso8601.gsub(":", "-")
  filename = File.join(FEEDBACK_DIR, "#{timestamp}.md")

  markdown_content = <<~MD
    ---
    email: #{email}
    date: #{Time.now.utc}
    ---
    
    #{message}
  MD

  File.write(filename, markdown_content)

  { success: true, file: filename }.to_json
end

# Optional: list all feedback files
get '/api/feedbacks' do
  content_type :json
  files = Dir.glob("#{FEEDBACK_DIR}/*.md").map { |f| File.basename(f) }
  { files: files }.to_json
end
