require 'riak'

class Zombie
  attr_accessor :fields, :data, :client, :robject

  def initialize(client=nil)
    @fields = [:dna, :sex, :name, :address, :city, :state,
               :zip, :phone, :birthdate, :ssn, :job, :bloodtype,
               :weight, :height, :latitude, :longitude]

    @data = {}

    @client = client
    @client = Riak::Client.new if client.nil?
  end

  def search_index(index, query)
    zombies = []
    results = @client['zombies'].get_index(index, query)

    unless results.nil?
      for zombie_key in results
        zombies << @client['zombies'].get(zombie_key).data
      end
    end

    return zombies
  end

  def create_robject()
    @robject = @client['zombies'].new(@data[:ssn])
  end

  def from_array(arr)
    i = 0
    for field in @fields
      @data[field] = arr[i]
      i+=1
    end

    self.create_robject()
  end

  def from_hash(hash)
    for field in @fields
      if hash.has_key? field.to_s
        @data[field] = hash[field.to_s]
      else
        @data[field] = "default"
      end
    end

    self.create_robject()
  end

  def add_index(index, value)
    @robject.indexes[index] << value
  end

  def save()
    @robject.data = @data
    @robject.store
  end
end