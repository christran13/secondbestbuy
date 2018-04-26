class CartController < ApplicationController

before_action :authenticate_user!, only: [:checkout]

  def add_to_cart
  	# line_item = LineItem.new
  	# line_item.product_id = params[:product_id]
  	# line_item.quantity = params[:quantity]
  	# line_item.line_item_total = line_item.product.price * line_item.quantity
  	# line_item.save
    @order = current_order
  	if params[:quantity].blank?
  		flash[:error] = "Select Quantity."
  		redirect_to root_path
  	else
  	line_item = @order.line_items.new(product_id: params[:product_id], quantity: params[:quantity])
    @order.save
    session[:order_id] = @order.id
  	line_item.update(line_item_total: (line_item.quantity * line_item.product.price))

  	redirect_to view_order_path
  	end

  end

  def view_order
  	@line_items = current_order.line_items
  end

  def delete_line_item
  	line_item = LineItem.find(params[:line_item_id])
  	line_item.destroy

  	redirect_to view_order_path
  end

  def checkout

  	line_items = current_order.line_items
    @order = current_order
  	@order.update(user_id: current_user.id, subtotal: 0)

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

  end

  def order_complete

    line_items = current_order.line_items

    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
      )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'SecondBest Buy Customer',
      :currency    => 'usd'
      )

    session.delete(:order_id)
    line_items.destroy_all

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to root_path
  end

  def cancel_checkout
    session.delete(:order_id)
    Order.find(params[:order_id]).destroy

    redirect_to root_path
    
  end



end
