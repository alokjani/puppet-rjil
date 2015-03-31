#
# Class rjil::http_proxy
# stands up a squid proxy for gcp node types
#
class rjil::http_proxy(
  $port = 3128,
  $cache_dir_list = ['ufs /var/spool/squid3 10000 16 256'],
  $max_object_size = '50096 KB',
  $max_object_size_in_memory = '5012 KB',
) {

  class { 'squid3':
    cache_dir => $cache_dir_list,
    # allow objects up to 500MB by default
    maximum_object_size => $max_object_size,
    # allow objects in memory up to 5M by default
    maximum_object_size_in_memory => $max_object_size_in_memory,
  }

  Service<| title == 'squid3_service' |> {
    provider => 'upstart',
    enable   => undef,
  }

  rjil::jiocloud::consul::service {'proxy':
    port          => $port,
    tags          => ['real'],
    check_command => "/usr/lib/nagios/plugins/check_http -H localhost -p ${port}",
  }

}

