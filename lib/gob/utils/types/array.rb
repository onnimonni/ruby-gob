class Gob::Utils::Types::Array
	attr_accessor :type
	def initialize(opts={})
		@type = opts[:type]
	end
end