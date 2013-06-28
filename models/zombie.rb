require 'riak'
require 'geohash'

class Zombie
  attr_accessor :fields, :data, :client, :robject

  def initialize(client=nil)
    @fields = [:dna, :sex, :name, :address, :city, :state,
               :zip, :phone, :birthdate, :ssn, :job, :bloodtype,
               :weight, :height, :latitude, :longitude]

    @data = {}

    @client = client
    if client.nil?
      @client = Riak::Client.new(:protocol => 'pbc') if client.nil?
    end
  end

  def search_index(index, query, start = 0, count = 100)
    zombies = []
    results = @client['zombies'].get_index(index, query)
    unless results == false
      result_count = 0
      for zombie_key in results
        break if result_count >= count
        next if result_count < start

        data = @client['zombies'].get(zombie_key).data
        data["dna"] = data["dna"][0..20] + "..."
        zombies << data
        result_count+=1
      end
    end

    return {
        :total_count => results.count,
        :count => zombies.count,
        :zombies => zombies
    }
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

  def geohash(precision)
    GeoHash.encode(@data[:latitude].to_f, @data[:longitude].to_f, precision)[0, precision]
  end

  def citystate()
    "#{@data[:city]}, #{@data[:state]}"
  end

  def add_index(index, value)
    @robject.indexes[index] << value
  end

  def save()
    @robject.data = @data
    @robject.store(options={:returnbody => false})
  end
end