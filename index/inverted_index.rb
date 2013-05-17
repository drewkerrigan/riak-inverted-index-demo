require './crdt/gset'

class InvertedIndex

  attr_accessor :bucket, :client, :bucket_name

  def initialize(client, bucket_name)
    self.client = client
    self.bucket_name = "#{bucket_name}_inverted_indices"
    self.bucket = client.bucket(self.bucket_name)
  end

  def put_index(index_name, key)
    index_obj = get_index(index_name)

    index = index_obj.instance_variable_get('@inverted_index')

    index.add(key)

    index_obj.raw_data = index.to_marshal

    index_obj.store
  end

  def get_index(index_name)
    index_obj = self.bucket.get_or_new(index_name)

    index = GSet.new

    index_obj.siblings.each { | obj |
      if !obj.raw_data.nil?
        index.merge_marshal obj.raw_data
      end
    }

    # If resolving siblings...
    if index_obj.siblings.length > 1
      index_obj = index_obj.store
    end

    index_obj.instance_variable_set('@inverted_index', index)

    return index_obj
  end

end