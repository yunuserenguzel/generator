require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)
require 'active_model/serializer'
Bundler.require()
require './map'
require './map_generator'
require './cell'
require './cell_type'
require './direction'
require './point'

size = 8
puts 'Generating maps...'
MapGenerator.new(size, size).generate_maps
