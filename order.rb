class Bundle
  attr_reader :quantity, :price

  def initialize(quantity, price)
    @quantity = quantity
    @price = price
  end
end

class Order
  BUNDLES = {
    'IMG' => [Bundle.new(10, 800), Bundle.new(5, 450)],
    'FLAC' => [Bundle.new(9, 1147.5), Bundle.new(6, 810), Bundle.new(3, 427.5)],
    'VID' => [Bundle.new(9, 1530), Bundle.new(5, 900), Bundle.new(3, 570)]
  }.freeze

  def self.calculate_order(order)
    items = order.scan(/\d+\s\w+/)
    result = []

    items.each do |item|
      quantity, format = item.split(' ')
      bundles = BUNDLES[format].sort_by(&:quantity)

      min_cost = Array.new(quantity.to_i + 1, Float::INFINITY)
      min_cost[0] = 0

      bundle_used = Array.new(quantity.to_i + 1)

      (1..quantity.to_i).each do |i|
        bundles.each do |bundle|
          if i >= bundle.quantity && min_cost[i - bundle.quantity] + bundle.price < min_cost[i]
            min_cost[i] = min_cost[i - bundle.quantity] + bundle.price
            bundle_used[i] = bundle
          end
        end
      end

      total_price = min_cost[quantity.to_i]
      if total_price.infinite?
      
        items.each do |item|
          quantity, format = item.split(' ')
          bundles = BUNDLES[format].sort_by(&:quantity).reverse
      
          total_price = 0
          bundle_count = Hash.new(0)
      
          remaining_quantity = quantity.to_i
      
          perfect_bundle_combination = nil
      
          (1..remaining_quantity).each do |count|
            bundle_combination = bundles.combination(count).find do |bundles_combo|
              bundles_combo.sum(&:quantity) == remaining_quantity
            end
      
            if bundle_combination
              perfect_bundle_combination = bundle_combination
              break
            end
          end
      
          if perfect_bundle_combination
            perfect_bundle_combination.each do |bundle|
              bundle_count[bundle] += 1
              total_price += bundle.price
              remaining_quantity -= bundle.quantity
            end
          else
            while remaining_quantity > 0
              best_bundle = nil
      
              bundles.each do |bundle|
                if bundle.quantity <= remaining_quantity
                  best_bundle = bundle
                  break
                end
              end
      
              break unless best_bundle
      
              bundle_count[best_bundle] += 1
              total_price += best_bundle.price
              remaining_quantity -= best_bundle.quantity
            end
          end
          breakdown = bundle_count.map  { |quantity, count| "#{format}: #{count}pcs of bundle #{quantity.quantity}" }.join(', ')
          result << "\n#{breakdown}, Total: $#{'%.2f' % total_price}"
        end
      else
        breakdown = generate_bundle_breakdown(quantity.to_i, bundle_used, total_price, format)
        result << "\n#{breakdown}, Total: $#{'%.2f' % total_price}"
      end
    end

    result.join(', ')
  end

  def self.generate_bundle_breakdown(quantity, bundle_used, total_price, format)
    used_bundles = Hash.new(0)
    remainder = quantity
    
    while remainder > 0
      bundle = bundle_used[remainder]
      break if bundle.nil?

      used_bundles[bundle.quantity] += 1
      remainder -= bundle.quantity
    end

    breakdown = used_bundles.map { |quantity, count| "#{format}: #{count}pcs of bundle #{quantity}" }.join(', ')
    breakdown
  end

  def self.input_order
    puts "Enter the order in the format: <quantity> <format> ..."
    order = gets.chomp
    result = calculate_order(order)
    puts "Bundle breakdown and cost:"
    puts "#{result}"
    puts ""
  end
end

Order.input_order if __FILE__ == $PROGRAM_NAME
