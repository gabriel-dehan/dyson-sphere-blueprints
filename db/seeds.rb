# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Cleaning up..."

# User.destroy_all
# Collection.destroy_all
# Blueprint.destroy_all

puts "Creating admin..."
User.create!(email: "admin@dysonsphereblueprints.com", username: "Admin", password: "password", role: "admin")
# puts "Creating collections..."
# user = User.last
# puts "Creating blueprints..."
# tags =  "deuterium, optical grating crystal, iron ore"
# 5.times do
#   file = URI.open('http://cdn.mos.cms.futurecdn.net/nUTuo444A3wTqKVQfrxMXL.jpg')
#   bp = user.collections.first.blueprints.new(title: "60 Smelters", description: "Hello world", encoded_blueprint: "//f23fewoifjwfoewjifjw;]fwoeif")
#   bp.tag_list = tags
#   bp.cover.attach(io: file, filename: "dsp.jpg", content_type: 'image/jpg')
#   bp.mod = Mod.last
#   bp.mod_version = Mod.last.version_list.first
#   bp.save!

#   file = URI.open('http://cdn.mos.cms.futurecdn.net/nUTuo444A3wTqKVQfrxMXL.jpg')
#   bp2 = user.collections.last.blueprints.new(title: "60 Smelters", description: "Hello world", encoded_blueprint: "//f23fewoifjwfoewjifjw;]fwoeif")
#   bp2.tag_list = tags
#   bp2.cover.attach(io: file, filename: "dsp.jpg", content_type: 'image/jpg')
#   bp2.mod = Mod.last
#   bp2.mod_version = Mod.last.version_list.first
#   bp2.save!
# end

# puts "Done !"
