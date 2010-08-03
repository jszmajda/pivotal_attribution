#!/usr/bin/ruby

require 'rubygems'
require 'fastercsv'
require 'chronic'
require 'active_support'

def col_num(val, pad, inverse=false)
  v = val.to_i
  s = case v
      when 0
        inverse ? "1;33" : "1;30"
      when (1..5)
        inverse ? "1;33" : "1;31"
      when (6..10)
        inverse ? "1;32" : "1;34"
      when (10..20)
        inverse ? "1;34" : "1;32"
      when (20..999999)
        inverse ? "1;31" : "1;33"
      end
  "\e[#{s}m#{v.to_s.ljust(pad)}\e[0m"
end
def user_color(user, pad)
  "\e[36m#{user.ljust(pad)}\e[0m"
end

user_stories = {}
since = Chronic.parse(ARGV[1]) if ARGV[1]
puts "\e[1;32mSince #{since || "Project Inception"}\e[0m"

iterations = []
current_iteration = nil
iteration = {}
FasterCSV.foreach(ARGV.first, :headers => true) do |row|
  #<FasterCSV::Row 
  #  "Id"              : "3090942"
  #  "Story"           : "an administrator should be able to create a client"
  #  "Labels"          : "administrative, client"
  #  "Iteration"       : "1"
  #  "Iteration Start" : "Apr 7, 2010"
  #  "Iteration End"   : "Apr 13, 2010"
  #  "Story Type"      : "feature"
  #  "Estimate"        : "1"
  #  "Current State"   : "accepted"
  #  "Created at"      : "Apr 8, 2010"
  #  "Accepted at"     : "Apr 12, 2010"
  #  "Deadline"        : nil
  #  "Requested By"    : "Josh Szmajda"
  #  "Owned By"        : "Josh Szmajda"
  #  "Description"     : nil
  #  "URL"             : "http://www.pivotaltracker.com/story/show/3090942"
  #  "Note"            : nil
  #  "Note"            : nil
  #  "Note"            : nil
  #  "Task"            : "password should be encrypted when created."
  #  "Task Status"     : "completed"
  #  "Task"            : nil
  #  "Task Status"     : nil
  #  "Task"            : nil
  #  "Task Status"     : nil
  #  "Task"            : nil
  #  "Task Status"     : nil
  # >
  since = Time.parse(row["Created at"]) if since.nil?

  u = row["Owned By"]
  u = "Unassigned" if u.nil?
  user_stories[u] = {:before => {:complete => [], :incomplete => []}, :after => {:complete => [], :incomplete => []}} if user_stories[u].nil?

  complete = row["Current State"] == "accepted" ? :complete : :incomplete
  at = row["Accepted at"]
  at = at.blank? ? nil : Time.parse(at)
  whenly = at.nil? || at > since ? :after : :before

  user_stories[u][whenly][complete] << row if row["Story Type"] == "feature"

  itr = row["Iteration"]
  if current_iteration != itr
    current_iteration = itr
    iterations << iteration if iteration.keys.size > 0
    iteration = {}
  end
  iteration[u] = 0 if iteration[u].nil?
  iteration[u] += row["Estimate"].to_i if row["Current State"] == "accepted"
end

users = user_stories.keys.sort
max_username = users.max{|a,b| a.length<=>b.length}

puts "\n\e[1;32mPoints by user:\e[0m"
users.each do |user|
  stories = user_stories[user]
  u = user_color(user, max_username.length)
  complete = "\e[32mComplete:\e[0m #{col_num stories[:after][:complete].inject(0){|sum,st| sum + st["Estimate"].to_i }, 3}"
  pending = "\e[31mPending:\e[0m #{col_num stories[:after][:incomplete].inject(0){|sum,st| sum + st["Estimate"].to_i }, 3, true}"
  puts "#{u} | #{complete} | #{pending}"
end

puts "\n\e[1;32m#{iterations.size} Iterations\e[0m"

#puts "#{"".ljust(max_username.length)} #{iterations.collect{|itr| "".ljust(2)}.join(" | ")}"
users.each do |user|
  puts "#{user_color(user,max_username.length)} | #{iterations.collect{|itr| col_num(itr[user], 2)}.join(" | ")} |"
end
