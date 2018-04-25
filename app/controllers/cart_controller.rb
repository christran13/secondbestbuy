class CartController < ApplicationController

before_action :authenticate_user!, only: [:checkout]

  def add_to_cart
  	# line_item = LineItem.new
  	# line_item.product_id = params[:product_id]
  	# line_item.quantity = params[:quantity]
  	# line_item.line_item_total = line_item.product.price * line_item.quantity
  	# line_item.save
  	if params[:quantity].blank?
  		flash[:error] = "Select Quantity."
  		redirect_to root_path
  	else
  	line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])
  	line_item.update(line_item_total: (line_item.quantity * line_item.product.price))

  	redirect_to view_order_path
  	end

  end

  def view_order
  	@line_items = LineItem.all
  end

  def delete_line_item
  	line_item = LineItem.find(params[:line_item_id])
  	line_item.destroy

  	redirect_to view_order_path
  end

  def checkout

  	line_items = LineItem.all
  	@order = Order.create(user_id: current_user.id, subtotal: 0)

  	line_items.each do |line_item|

  		line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))

  		if @order.order_items[line_item.product_id].nil?
  			@order.order_items[line_item.product_id] = line_item.quantity
  		else 
  			@order.order_items[line_item.product_id] += line_item.quantity 
  		end

  		@order.subtotal += line_item.line_item_total
  	end
  	@order.save
  	@order.update(sales_tax: (@order.subtotal * 0.08))
  	@order.update(grand_total:(@order.sales_tax + @order.subtotal))

  	line_items.destroy_all
  end

end