
def parse_filename(filename)
  parts = filename.split('.')[0].split('-')
  if parts.length == 6
    backend, bucket, index, gets, puts, duration = parts
    index_term = 'random'
  elsif parts.length == 7
    backend, bucket, index, gets, puts, duration, index_term = parts
  end
  pos = backend.rindex('/')
  unless pos.nil?
    backend = backend[pos+1..backend.length-1]
  end

  return [backend, bucket, index, gets, puts, duration, index_term]
end

def read_file(filename)
  results = []
  backend, bucket, index, gets, puts, duration, index_term = parse_filename(filename)
  File.open(filename) do |file|
    data = []
    total_ops = 0
    file.each_with_index do |line, i|
      parts = line.strip().split(',')
      if parts.length == 5
        op, min, avg, max, total = parts
      else
        puts 'error reading results'
      end
      total_ops += total.to_i
      data << [op, min, avg, max, total]
    end
    results << [backend, duration, gets, puts, index,
                data[0][0], data[0][1], data[0][2], data[0][3], data[0][4],
                data[1][0], data[1][1], data[1][2], data[1][3], data[1][4],
                index_term, total_ops, '%.2f' % (total_ops.to_f/duration.to_f)]
  end
  return results
end

filename = ARGV[0]

data = read_file(filename)

for row in data
  puts row.join(',')
end