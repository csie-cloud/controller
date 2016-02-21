class controller_node::horizon{
  class { 'memcached':
    listen_ip => '127.0.0.1',
    tcp_port  => '11211',
    udp_port  => '11211',
  }

  class { '::horizon':
    secret_key => $::password::horizon_secret_key,
    cache_server_ip       => '127.0.0.1',
    cache_server_port     => '11211',
    cache_backend => 'django.core.cache.backends.memcached.MemcachedCache',
    django_debug          => 'False',
    api_result_limit      => '2000',
    keystone_default_role => 'user',
    allowed_hosts => '*'
    # not secret key for now
  }
}
