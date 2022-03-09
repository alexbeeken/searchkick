module Searchkick
  class Relation
    NO_DEFAULT_VALUE = Object.new

    # note: modifying body directly is not supported
    # and has no impact on query after being executed
    # TODO freeze body object?
    delegate :body, :params, to: :query
    delegate_missing_to :private_execute

    def initialize(model, term = "*", **options)
      @model = model
      @term = term
      @options = options

      # generate query to validate options
      query
    end

    # same as Active Record
    def inspect
      entries = results.first(11).map!(&:inspect)
      entries[10] = "..." if entries.size == 11
      "#<#{self.class.name} [#{entries.join(', ')}]>"
    end

    def execute
      Searchkick.warn("The execute method is no longer needed")
      private_execute
      self
    end

    # experimental
    def limit(value)
      clone.limit!(value)
    end

    # experimental
    def limit!(value)
      check_loaded
      @options[:limit] = value
      self
    end

    # experimental
    def offset(value = NO_DEFAULT_VALUE)
      # TODO remove in Searchkick 6
      if value == NO_DEFAULT_VALUE
        private_execute.offset
      else
        clone.offset!(value)
      end
    end

    # experimental
    def offset!(value)
      check_loaded
      @options[:offset] = value
      self
    end

    # experimental
    def page(value)
      clone.page!(value)
    end

    # experimental
    def page!(value)
      check_loaded
      @options[:page] = value
      self
    end

    # experimental
    def per_page(value = NO_DEFAULT_VALUE)
      # TODO remove in Searchkick 6
      if value == NO_DEFAULT_VALUE
        private_execute.per_page
      else
        clone.per_page!(value)
      end
    end

    # experimental
    def per_page!(value)
      check_loaded
      @options[:per_page] = value
      self
    end

    # experimental
    def where(value)
      clone.where!(value)
    end

    # experimental
    def where!(value)
      check_loaded
      if @options[:where]
        @options[:where] = {_and: [@options[:where], ensure_permitted(value)]}
      else
        @options[:where] = ensure_permitted(value)
      end
      self
    end

    # experimental
    def rewhere(value)
      clone.rewhere!(value)
    end

    # experimental
    def rewhere!(value)
      check_loaded
      @options[:where] = ensure_permitted(value)
      self
    end

    # experimental
    def order(value)
      clone.order!(value)
    end

    # experimental
    def order!(value)
      check_loaded
      if @options[:order]
        order = @options[:order]
        order = [order] unless order.is_a?(Array)
        order << value
        @options[:order] = order
      else
        @options[:order] = value
      end
      self
    end

    # experimental
    def reorder(value)
      clone.reorder!(value)
    end

    # experimental
    def reorder!(value)
      check_loaded
      @options[:order] = value
      self
    end

    # experimental
    def only(*keys)
      Relation.new(@model, @term, **@options.slice(*keys))
    end

    # experimental
    def except(*keys)
      Relation.new(@model, @term, **@options.except(*keys))
    end

    def loaded?
      !@execute.nil?
    end

    private

    def private_execute
      @execute ||= query.execute
    end

    def query
      @query ||= Query.new(@model, @term, **@options)
    end

    def check_loaded
      raise Error, "Relation loaded" if loaded?

      # reset query since options will change
      @query = nil
    end

    # provides *very* basic protection from unfiltered parameters
    # this is not meant to be comprehensive and may be expanded in the future
    def ensure_permitted(obj)
      obj.to_h
    end
  end
end
