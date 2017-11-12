module HashAttrAccessor
  def hash_attr_accessor(*args)
    options = args.extract_options!
    attribute = options[:attribute]

    args.each do |arg|
      self.class_eval("def #{arg};#{attribute}['#{arg}'] || {};end")
      self.class_eval("def #{arg}=(val);#{attribute}['#{arg}']=val;end")
    end
  end
end
