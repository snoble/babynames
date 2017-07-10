require 'csv'

names = {}
max_old_year_total = 0
max_recent_year_total = 0
Dir.foreach('./') do |item|
  if(item.split('.')[1] == 'txt')
    year = /[0-9]+/.match(item)[0].to_i
    rows = []
    CSV.foreach("./#{item}") do |row|
      rows << row
    end
    names_for_year = rows
      .select { |row| row[1] == 'M' }
      .map { |row| [row[0], row[2].to_f] }
      .to_h

    year_total = names_for_year.values.reduce(&:+)
    names_for_year.each do |name, count|
      data = (names[name] ||= {})
      if year <= 1935
        if data[:old_max_count].nil? || (count/year_total > data[:old_max_count]/data[:old_max_total])
          data[:old_max_count] = count
          data[:old_max_total] = year_total
          data[:old_max_year] = year
        end
        max_old_year_total = [max_old_year_total, year_total].max
      end
      if year > 1951
        if data[:recent_max_count].nil? || (count/year_total > data[:recent_max_count]/data[:recent_max_total])
          data[:recent_max_count] = count
          data[:recent_max_total] = year_total
          data[:recent_max_year] = year
        end
        max_recent_year_total = [max_recent_year_total, year_total].max
      end
    end
    STDERR.puts year
  end
end

names.each_value do |data|
  recent_max_count = data[:recent_max_count] || 0
  recent_max_total = data[:recent_max_total] || max_recent_year_total
  old_max_count = data[:old_max_count] || 0
  old_max_total = data[:old_max_total] || max_old_year_total
  def llr_component(count, total)
    p = count == 0 ? 0 : count/total
    (count == 0 ? 0 : count*Math.log(p)) + (total - count)*Math.log(1 - p)
  end
  data[:recent_max_rate] = recent_max_count.to_f / recent_max_total
  data[:old_max_rate] = old_max_count.to_f / old_max_total
  data[:llr] = llr_component(old_max_count, old_max_total) +
    llr_component(recent_max_count, recent_max_total) -
    llr_component(old_max_count + recent_max_count, old_max_total + recent_max_total)
end

names
  .to_a
  .select { |name, data| (data[:old_max_rate] || 0) > (data[:recent_max_rate] || 0) }
  .select { |name, data| (data[:old_max_count] || 0) > 50 }
  .select { |name, data| data[:recent_max_rate] < 0.0001 }
  .sort_by { |name, data| data[:llr] }
  .reverse[0 .. 500]
  .each { |name, data| p "#{name}: #{data}" }
