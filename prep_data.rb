require 'pp'
require 'rubygems'
require 'json'

APPEARANCE_THRESHOLD = 600
FRIEND_THRESHOLD = 0
FRIEND_TO_LINEWIDTH_SCALE = 1000

WORKING_DIR = File.dirname(__FILE__)
names_file = WORKING_DIR + '/names.txt'
vertex_file = WORKING_DIR + '/vertex.txt'
output_file = WORKING_DIR + '/resources/json.js'

marvel_universe = {}

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

File.foreach(vertex_file) do |line|
  split_line = line.split
  id = split_line.shift.to_i
  marvel_universe[id][:apperances] += split_line.collect { |i| i.to_i }
  marvel_universe[id][:include] = (marvel_universe[id][:apperances].size > APPEARANCE_THRESHOLD)
end

comic_appearances = {}

marvel_universe.each do |id, hero|
  hero[:apperances].each do |apperance|
    comic_appearances[apperance] ||= []
    comic_appearances[apperance] << id
  end
end

marvel_universe.each do |id, hero|
  if hero[:include]
    hero[:friends] = {}
    hero[:apperances].each do |apperance|
      comic_appearances[apperance].each do |friend_id|
        if marvel_universe[friend_id][:include] && (friend_id != id)
          hero[:friends][friend_id] ||= 0
          hero[:friends][friend_id] += 1
        end
      end
    end
  end
end

marvel_universe_ready = []
count = 0

marvel_universe.each do |id, hero|
  if hero[:include]
    hero_hash = { 'adjacencies' => [], 'data' => {'$color' => '#83548B', '$type' => 'circle', '$dim' => 10}}
    hero_hash['name'] = hero[:name]
    hero_hash['id'] = id
    hero[:friends].each do |friend_id, friend_count|
        #puts "#{hero[:name]} ties to #{marvel_universe[friend_id][:name]}: #{friend_count}"
        edge_hash = {"nodeTo" => friend_id, "nodeFrom" => id, "data" => {"$color" => "#909291", "$lineWidth" => 10.0 * friend_count / FRIEND_TO_LINEWIDTH_SCALE } }
        hero_hash['adjacencies'] << edge_hash if friend_count > FRIEND_THRESHOLD 
    end
    marvel_universe_ready << hero_hash
    count += 1
  end
end


json =  marvel_universe_ready.to_json
File.open(output_file, 'w+') {|f| f.write("var json =#{json};") }
puts "Added #{count} heros to the file."