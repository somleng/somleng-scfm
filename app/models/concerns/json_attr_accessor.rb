module JSONAttrAccessor
  def json_attr_accessor(*args)
    options = args.extract_options!
    json_attribute = options[:json_attribute]

    args.each do |arg|
      self.class_eval("def #{arg};#{json_attribute}['#{arg}'];end")
      self.class_eval("def #{arg}=(val);#{json_attribute}['#{arg}']=val;end")
    end
  end

  def hash_attr_reader(*args)
    options = args.extract_options!
    json_attribute = options[:json_attribute]

    args.each do |arg|
      self.class_eval("def #{arg};#{json_attribute}['#{arg}'] || {};end")
    end
  end

  def integer_attr_reader(*args)
    options = args.extract_options!
    json_attribute = options[:json_attribute]

    args.each do |arg|
      self.class_eval("def #{arg};#{json_attribute}['#{arg}'] && #{json_attribute}['#{arg}'].to_i;end")
    end
  end
end
