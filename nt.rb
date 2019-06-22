require 'yaml'
require 'pry'

BOOKS = YAML.load_file('nt.yml')
TOTALS = YAML.load_file('totals.yml')
ITERATIONS = 1_000_000
DAYS_IN_YEAR = 365
W = 65

def get_fitness(sets, target_size)
  fitness = 0
  sets.each { |set| fitness += (set.values.reduce(:+) - target_size).abs }
  fitness
end

def make_collection(books, number_of_sets)
  sets = []
  number_of_sets.times { |index| sets[index] = {} }
  indexes = Array(0..number_of_sets - 1)
  books.each do |book, verses|
    indexes = Array(0..number_of_sets - 1).shuffle! if indexes.empty?
    sets[indexes.pop].merge!(book => verses)
  end
  sets
end

def get_results(array)
  result = ''
  array.size.times do |index|
    result += "\n #{(index + 1).to_s.rjust(20)} \n"
    array[index].each do |book, verses|
      result += book.rjust(20) + ' ' + verses.to_s.ljust(20) + "\n"
    end
    result += "\n"
  end
  result
end

puts ''
puts 'This program evenly divides the NT books into a number of sets'.center(W)
puts 'based on the number of verses memorized each day.'.center(W)
puts 'E.g. if you want to memorize 4 verses a day, it evenly divides'.center(W)
puts 'the books of the NT into 4 sets,'.center(W)
puts 'as evenly as possible based on word count.'.center(W)
puts ''
print 'Enter the number of NT verses you want to memorize each day: '.center(W)
number_of_sets = gets.chomp.to_i
puts 'Computing NT book sets...'.center(W)
target_size = TOTALS['words'] / number_of_sets
best_sets = make_collection(BOOKS, number_of_sets)
best_fitness = get_fitness(best_sets, target_size)

ITERATIONS.times do
  sets = make_collection(BOOKS, number_of_sets)
  fitness = get_fitness(sets, target_size)
  if fitness < best_fitness
    best_sets = sets
    best_fitness = fitness
  end
end

file = File.open('nt.out', 'w')
file.puts "It'll take #{TOTALS['verses'].to_f / number_of_sets /
  DAYS_IN_YEAR} years."
file.puts "Best Fitness Values: #{best_fitness}"
file.puts get_results(best_sets)
file.close

puts 'Done!'.center(W)
puts 'Look in nt.out for the results.'.center(W)
