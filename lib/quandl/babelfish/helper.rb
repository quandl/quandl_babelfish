class Helper

  # Actions expect a square table, make it so
  def self.make_square(table)
    longest_row = 0
    table.each { |row| longest_row = [longest_row, row.length].max }
    table.collect { |row| row += Array.new(longest_row - row.length, nil) }
  end
end