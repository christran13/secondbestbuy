# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.create([{name: "Computers"}, {name:'Televisions'}, {name: 'Smart Phones'}, {name: 'Stereos'}, {name: 'Other'}])

puts "Categories seeded!"


50.times do 
	Product.create(
	  	name: Faker::Name.name, 
	  	price: Faker::Commerce.price, 
	  	quantity: Faker::Number.number(5),
	  	description: Faker::Lorem.sentence, 
	  	brand: Faker::Company.name, 
	  	rating: Faker::Number.between(1,10),
	  	category_id: Faker::Number.between(1,Category.count),
   )
end 