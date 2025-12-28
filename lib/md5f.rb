# Workaround for dsp_blueprint_parser bug with Ruby 3.2+
# The gem incorrectly requires 'md5f' instead of 'digest/md5'
require 'digest/md5'
