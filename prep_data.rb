# Ruby script to prepare the Marvel vertex data and package it as JSON.
#
# Author         : Wally Glutton - http://stungeye.com
# Source Repo    : http://github.com/stungeye/marvel_social_network
# Ruby Version   : Written and tested using Ruby 1.8.7.
# License        : This is free and unencumbered software released into the public domain. See LICENSE for details.

require 'pp'
require 'rubygems'
require 'json'

APPEARANCE_THRESHOLD = 600        # A character must appear in this many comic books to be included in the graph.
SHARED_APPERANCE_THRESHOLD = 0              # Edges between character nodes are added if they represent more than this many shared appearances.
FRIEND_TO_LINEWIDTH_SCALE = 1000  # Used to scale the width of the edges. Edge Width = 0.4 + (shared_apperances / FRIEND_TO_LINEWIDTH_SCALE) pixels

WORKING_DIR = File.dirname(__FILE__)
names_file = WORKING_DIR + '/names.txt'
vertex_file = WORKING_DIR + '/vertex.txt'
output_file = WORKING_DIR + '/resources/json.js'

marvel_universe = {}
# We will process the data such that this marvel_universe hash will key on the ids of each marvel character listed in names.txt.
# The value for each key will be a hash with the following keys:
# :name = Character Name
# :appearance = Array of ids of comic books that feature this character.
# :include = Boolean flag. True if this character has appear in more than APPEARANCE_THRESHOLD comics.
# :friends = A hash where the keys represent the id of other marvel characters. The value represent the number of shared appearances.

# Start by finding all the character ids and names from the names_file.
# Populating the marvel_universe hash.
File.foreach(names_file) do |line|
  # Each line starts with the character id.
  split_line = line.split
  id = split_line.shift.to_i
  # The remainder of the line is the character name, which is cleaned up as follows:
  # - Swap "Lastname, Firstname" with "Firstname Lastname" while preserving the trailing words that follow a forward-slash.
  # - Trailing forward-slashes are removed.
  # For example:
  # ABBOTT, JACK -> JACK ABBOTT
  # PEREGRINE, LE/FRANCK -> LE PEREGRINE / FRANCK
  # PEACEMONGER/ -> PEACEMONGER
  name = split_line.join(' ').split('/').collect { |x| x.split(', ').reverse.join(' ') }.join(' / ')
  marvel_universe[id] = { :name => name, :apperances => [] }
end

# Now find all the comic appearances for each character in the vertex_file.
# Add this data to the marvel_universe hash.
File.foreach(vertex_file) do |line|
  # Each line of this file also starts with a character id.
  split_line = line.split
  id = split_line.shift.to_i
  # The other numbers are ids of comic books that feature this character.
  marvel_universe[id][:apperances] += split_line.collect { |i| i.to_i }
  marvel_universe[id][:include] = (marvel_universe[id][:apperances].size > APPEARANCE_THRESHOLD)
end

# Build a comic_apperances hash that keys on specific comic-book ids.
# The value of each key is an array of the ids of characters who appeared in this comic-book.
comic_appearances = {}
marvel_universe.each do |id, hero|
  hero[:apperances].each do |apperance|
    comic_appearances[apperance] ||= []
    comic_appearances[apperance] << id
  end
end

# Using the comic_appearances hash add the friends hash to the marvel_universe hash.
marvel_universe.each do |id, hero|
  if hero[:include]
    hero[:friends] = {}
    hero[:apperances].each do |apperance|
      comic_appearances[apperance].each do |friend_id|
        if marvel_universe[friend_id][:include] && (friend_id != id) # Only add friends that are included in the graph.
          hero[:friends][friend_id] ||= 0
          hero[:friends][friend_id] += 1
        end
      end
    end
  end
end

# Build the prepared data structure. 
marvel_universe_prepared = []
count = 0
marvel_universe.each do |id, hero|
  if hero[:include]
    hero_hash = { 'adjacencies' => [], 'data' => {'$color' => '#83548B', '$type' => 'circle', '$dim' => 10}}
    hero_hash['name'] = hero[:name]
    hero_hash['id'] = id
    hero[:friends].each do |friend_id, shared_apperances|
        edge_hash = {"nodeTo" => friend_id, "nodeFrom" => id, "data" => {"$color" => "#909291", "$lineWidth" => 0.4 + 10.0 * shared_apperances / FRIEND_TO_LINEWIDTH_SCALE } }
        hero_hash['adjacencies'] << edge_hash if shared_apperances > SHARED_APPERANCE_THRESHOLD # Only add edge if we exceed the 
    end
    marvel_universe_prepared << hero_hash
    count += 1
  end
end

# JSON export to the output_file for use with force.js.
json =  marvel_universe_prepared.to_json
File.open(output_file, 'w+') {|f| f.write("var json =#{json};") }
puts "Added #{count} heroes to the file."