module RoutingHelper
  def typed_path(path, type)
    "#{path}?type=#{type}"
  end
end
