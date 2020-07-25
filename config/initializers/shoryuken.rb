Shoryuken.default_worker_options["auto_visibility_timeout"] = true
Shoryuken.default_worker_options["retry_intervals"] = lambda { |attempts|
  (12.hours.seconds**(attempts / 10.0)).to_i
}
