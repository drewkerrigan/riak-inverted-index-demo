require 'riak'

class Zombie
  attr_accessor :fields, :data, :client

  def initialize()
    @fields = [:dna, :sex, :name, :address, :city, :state,
               :zip, :phone, :birthdate, :ssn, :job, :bloodtype,
               :weight, :height, :lattitude, :longitude]

    @data = {}
  end

  def from_array(arr)
    i = 0
    for field in @fields
      @data[field] = arr[i]
      i+=1
    end
  end
end