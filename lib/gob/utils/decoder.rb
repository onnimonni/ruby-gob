class Gob::Utils::Decoder
	def initialize(content)
		@content = content
	end

	# Calculates the content length according to the first bytes
	# Source: https://golang.org/pkg/encoding/gob/
	def content_byte_length(content=@content)
		first_byte = @content[0].unpack('C')[0]
		if first_byte <= 128
			# First byte tells the length if byte count is smaller than 128
			content_length = first_byte
			content_length_check_byte_count = 1
		else
			# First byte holds the byte count, negated
			content_length_check_byte_count = (first_byte ^ 0xFF) + 1 + 1

			# Take as many bytes as the first byte mentioned and unpack them as unsigned integer in big endian encoding
			content_length = @content[1..content_length_check_byte_count].unpack('S>')[0]
		end

		# Tells how big the content is and how many bytes in beginning are just for the checksum
		[content_length, content_length_check_byte_count]
	end

	# Checks if the gob encoded content length is valid and
	# no bytes were missing in the transit
	def content_length_correct?(content=@content)
		length, check_bytes = content_byte_length(content)
		length == content.length - check_bytes
	end

	# These are the supported types for gob encoding
	TYPES = {
		1 => :bool,
		2 => :int,
		3 => :uint,
		4 => :float,
		5 => :byte_array,
		6 => :string,
		7 => :complex,
		8 => :interface,
		# gap for reserved ids.
		16 => :WireType,
		17 => :ArrayType,
		18 => :CommonType,
		19 => :SliceType,
		20 => :StructType,
		21 => :FieldType,
		22 => :FieldType_slice,
		23 => :MapType
	}.freeze

	# Checks which kind of data is included
	def type(content=@content)
		content_length, skip_bytes = content_byte_length(@content)
		type_byte = @content[skip_bytes].unpack('C')[0]/2
		type = TYPES[type_byte]
		unless type
			raise NotImplementedError, "Type #{type_byte} is not yet implemented in ruby-gob"
		end
		type
	end

	def decode(content=@content)
		@type ||= type(content)
		case @type
		when :bool
			@content[-1].unpack('C')[0] == 1
		else
			raise NotImplementedError, "Type #{@type} is not yet implemented in ruby-gob"
		end
	end
end