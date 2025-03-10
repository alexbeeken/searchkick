require_relative "test_helper"

class PaginationTest < Minitest::Test
  def test_limit
    store_names ["Product A", "Product B", "Product C", "Product D"]
    assert_order "product", ["Product A", "Product B"], order: {name: :asc}, limit: 2
    assert_order_relation ["Product A", "Product B"], Product.search("product").order(name: :asc).limit(2)
  end

  def test_no_limit
    names = 20.times.map { |i| "Product #{i}" }
    store_names names
    assert_search "product", names
  end

  def test_offset
    store_names ["Product A", "Product B", "Product C", "Product D"]
    assert_order "product", ["Product C", "Product D"], order: {name: :asc}, offset: 2, limit: 100
    assert_order_relation ["Product C", "Product D"], Product.search("product").order(name: :asc).offset(2).limit(100)
  end

  def test_pagination
    store_names ["Product A", "Product B", "Product C", "Product D", "Product E", "Product F"]
    products = Product.search("product", order: {name: :asc}, page: 2, per_page: 2, padding: 1)
    assert_equal ["Product D", "Product E"], products.map(&:name)
    assert_equal "product", products.entry_name
    assert_equal 2, products.current_page
    assert_equal 1, products.padding
    assert_equal 2, products.per_page
    assert_equal 2, products.size
    assert_equal 2, products.length
    assert_equal 3, products.total_pages
    assert_equal 6, products.total_count
    assert_equal 6, products.total_entries
    assert_equal 2, products.limit_value
    assert_equal 3, products.offset_value
    assert_equal 3, products.offset
    assert_equal 3, products.next_page
    assert_equal 1, products.previous_page
    assert_equal 1, products.prev_page
    assert !products.first_page?
    assert !products.last_page?
    assert !products.empty?
    assert !products.out_of_range?
    assert products.any?
  end

  def test_pagination_relation
    store_names ["Product A", "Product B", "Product C", "Product D", "Product E", "Product F"]
    products = Product.search("product", padding: 1).order(name: :asc).page(2).per_page(2)
    assert_equal ["Product D", "Product E"], products.map(&:name)
    assert_equal "product", products.entry_name
    assert_equal 2, products.current_page
    assert_equal 1, products.padding
    assert_equal 2, products.per_page
    assert_equal 2, products.size
    assert_equal 2, products.length
    assert_equal 3, products.total_pages
    assert_equal 6, products.total_count
    assert_equal 6, products.total_entries
    assert_equal 2, products.limit_value
    assert_equal 3, products.offset_value
    assert_equal 3, products.offset
    assert_equal 3, products.next_page
    assert_equal 1, products.previous_page
    assert_equal 1, products.prev_page
    assert !products.first_page?
    assert !products.last_page?
    assert !products.empty?
    assert !products.out_of_range?
    assert products.any?
  end

  def test_pagination_body
    store_names ["Product A", "Product B", "Product C", "Product D", "Product E", "Product F"]
    products = Product.search("product", body: {query: {match_all: {}}, sort: [{name: "asc"}]}, page: 2, per_page: 2, padding: 1)
    assert_equal ["Product D", "Product E"], products.map(&:name)
    assert_equal "product", products.entry_name
    assert_equal 2, products.current_page
    assert_equal 1, products.padding
    assert_equal 2, products.per_page
    assert_equal 2, products.size
    assert_equal 2, products.length
    assert_equal 3, products.total_pages
    assert_equal 6, products.total_count
    assert_equal 6, products.total_entries
    assert_equal 2, products.limit_value
    assert_equal 3, products.offset_value
    assert_equal 3, products.offset
    assert_equal 3, products.next_page
    assert_equal 1, products.previous_page
    assert_equal 1, products.prev_page
    assert !products.first_page?
    assert !products.last_page?
    assert !products.empty?
    assert !products.out_of_range?
    assert products.any?
  end

  def test_pagination_nil_page
    store_names ["Product A", "Product B", "Product C", "Product D", "Product E"]
    products = Product.search("product", order: {name: :asc}, page: nil, per_page: 2)
    assert_equal ["Product A", "Product B"], products.map(&:name)
    assert_equal 1, products.current_page
    assert products.first_page?
  end

  def test_total_entries
    products = Product.search("product", total_entries: 4)
    assert_equal 4, products.total_entries
  end

  def test_kaminari
    require "action_view"

    I18n.load_path = Dir["test/support/kaminari.yml"]
    I18n.backend.load_translations

    view_args = [[], nil] if ActionView::VERSION::STRING.to_f >= 6.1
    view = ActionView::Base.new(ActionView::LookupContext.new([]), *view_args)

    store_names ["Product A"]
    assert_equal "Displaying <b>1</b> product", view.page_entries_info(Product.search("product"))

    store_names ["Product B"]
    assert_equal "Displaying <b>all 2</b> products", view.page_entries_info(Product.search("product"))
  end
end
