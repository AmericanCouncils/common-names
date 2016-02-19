#!/usr/bin/ruby

require 'csv'

def fetch_names(d)
	name_priorities = {}

	dir_path = File.join(File.dirname(__FILE__), "data_#{d}")
	Dir.foreach(dir_path) do |filename|
		next unless filename =~ /\.csv$/
		names = CSV.read(File.join(dir_path, filename)).map(&:first)
		names.each_with_index do |name, idx|
			name = name.upcase.gsub(/[^A-Z]/, '')
			name_priorities[name] = [idx, name_priorities.fetch(name, 99999)].min
		end
	end

	return name_priorities
end

fname_priorities = fetch_names("first")
lname_priorities = fetch_names("last")
both = fname_priorities.keys & lname_priorities.keys

chosen_fnames = []
chosen_lnames = []
for name in both.sort
	fidx = fname_priorities[name]
	lidx = lname_priorities[name]
	if (fidx - lidx).abs < 100
		puts "#{name} : AMBIGUOUS F#{fidx} vs L#{lidx}"
	elsif fidx < lidx
		puts "#{name} : FIRST F#{fidx} vs L#{lidx}"
		chosen_fnames << name
	else
		puts "#{name} : LAST F#{fidx} vs L#{lidx}"
		chosen_lnames << name
	end
end

out_fnames = fname_priorities.keys - both + chosen_fnames
out_lnames = lname_priorities.keys - both + chosen_lnames

{fnames: out_fnames, lnames: out_lnames}.each do |k,v|
	csv = CSV.open(File.join(File.dirname(__FILE__), "#{k}.csv"), "w")
	for name in v.sort
		csv << [name]
	end
	csv.close
end

