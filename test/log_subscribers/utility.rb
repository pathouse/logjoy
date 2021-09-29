def assert_log_has_keys(log, keys)
  keys.each do |key|
    assert_match(/#{key}/, log)
  end
end
