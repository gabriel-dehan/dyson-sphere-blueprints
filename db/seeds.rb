# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Cleaning up..."

User.destroy_all
Collection.destroy_all
Blueprint.destroy_all

puts "Creating user..."
user = User.create!(email: "admin@dspblueprints.com", username: "Admin", password: "password");
puts "Creating collections..."

puts "Creating blueprints..."
5.times do
  user.collections.first.blueprints.create!(title: "60 Smelters", description: "Hello world", encoded_blueprint: "//f23fewoifjwfoewjifjw;]fwoeif")
  user.collections.last.blueprints.create!(title: "60 Smelters", description: "Hello world", encoded_blueprint: "//f23fewoifjwfoewjifjw;]fwoeif")
end

puts "Done !"