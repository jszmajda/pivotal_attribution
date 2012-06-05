#!/usr/bin/ruby

require 'rubygems'

gem 'activesupport', '>= 2.3.9'
require 'fastercsv'
require 'chronic'
require 'active_support'
require 'outputters'

if ARGV.length < 1
  usage =<<-EOT
Usage: #{__FILE__} <Your CSV File Here> <Optional Report Start Date>

Example:
  #{__FILE__} my_awesome_project_20100803_1919.csv "Two Weeks Ago"

  EOT
  puts usage
  exit
end

use_faker = false
if ARGV[2] && ARGV[2] == "faker"
  require 'faker'
  use_faker = true
end

outputter = Outputters::Ansi
unless (ARGV.grep /--outputter/).empty?
  op = ARGV[ARGV.index('--outputter') + 1]
  case op
  when 'html'
    outputter = Outputters::Html
  end
end

if outputter == Outputters::Ansi
  unless (ARGV.grep /--tabs/).empty?
    separator = "\t"
  else
    separator = " | "
  end
end

user_stories = {}
since = Chronic.parse(ARGV[1]) if ARGV[1]
@out = outputter.new(separator)

@out.since_header(since)

iterations = []
idates = []
current_iteration = nil
iteration = {}
faker_map = {}
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
  if use_faker
    faker_map[u] = Faker::Name.name unless faker_map[u]
    u = faker_map[u]
  end
  u = "Unassigned" if u.nil?
  user_stories[u] = {:before => {:complete => [], :incomplete => []}, :after => {:complete => [], :incomplete => []}} if user_stories[u].nil?

  complete = row["Current State"] == "accepted" ? :complete : :incomplete
  at = row["Accepted at"]
  at = at.nil? || at.empty? ? nil : Time.parse(at)
  whenly = at.nil? || at > since ? :after : :before

  user_stories[u][whenly][complete] << row if row["Story Type"] == "feature"

  iend = row["Iteration End"]
  next if iend.nil? || Time.parse(iend) > Time.now

  itr = row["Iteration"]
  if current_iteration != itr
    current_iteration = itr
    if iteration.keys.size > 0
      iterations << iteration 
      idates << Time.parse(iend)
    end
    iteration = {}
  end
  iteration[u] = 0 if iteration[u].nil?
  iteration[u] += row["Estimate"].to_i if row["Current State"] == "accepted"
end

users = user_stories.keys.sort
@out.configure_users(users)

total_complete = 0
total_incomplete = 0

@out.points_header

users.each do |user|
  stories = user_stories[user]
  complete = stories[:after][:complete].inject(0){|sum,st| sum + st["Estimate"].to_i }
  total_complete += complete
  pending = stories[:after][:incomplete].inject(0){|sum,st| sum + st["Estimate"].to_i }
  total_incomplete += pending

  @out.points_per_user(user, complete, pending)
end
@out.points_per_user('Total', total_complete, total_incomplete)

@out.iterations_header(iterations)

@out.iterations_table_header(idates)
users.each do |user|
  @out.iterations_for_user(user, iterations)
end
@out.iterations_total(iterations)
@out.complete!
