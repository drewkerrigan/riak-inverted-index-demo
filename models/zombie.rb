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

  def fetch_with_pagination(keys, start = 1, count = 50)
    zombies = []
    keys = [] unless keys

    result_count = 1
    keys.each_with_index do |zombie_key, i|
      break if result_count > count
      next if (i + 1) < start

      data = @client['zombies'].get(zombie_key).data
      data["dna"] = data["dna"][0..20] + "..."
      zombies << data
      result_count+=1
    end

    pages = 0
    current_page = 0
    next_index = 0
    prev_index = 0

    if keys.count > 0
      pages = (Float(keys.count) / Float(count)).ceil
      current_page = ((Float(start) / Float(keys.count)) * Float(pages)).ceil
      next_index = ((start + count) > keys.count) ?
          ((pages - 1) * count + 1) : (start + count)
      prev_index = (start == 1) ? 1 : start - count
    end

    {
        :start => start,
        :pages => pages,
        :current_page => current_page,
        :next_index => next_index,
        :prev_index => prev_index,
        :increment => count,
        :total_count => keys.count,
        :zombies => zombies
    }
  end

  def search_index(index, query)
    @client['zombies'].get_index(index, query)
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