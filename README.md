# NAME

HTTP::Proxy::InterceptorX::Plugin::RelativePath - Maps a website path into local path

# SYNOPSIS

    package My::Custom::Proxy;
    use Moose;
    extends qw/HTTP::Proxy::Interceptor/;
    with qw/
        HTTP::Proxy::InterceptorX::Plugin::RelativePath
    /;
    1;

    my $p = My::Custom::Proxy->new(
      config_path => 'config_file.pl',
      port        => 9919,
    );

    $p->start;
    1;

# CONFIG

create a config file

    {
        "http://some.site.com/some/dir/path/(?<path>.+)" => {
          RelativePath   => "/home/user/map/to/this/path/"
        },
        "http://some.site.com/some/dir/path/(.+)" => {
          RelativePath   => "/home/user/map/to/this/path/"
        },
    }

then start the proxy

# DESCRIPTION

HTTP::Proxy::InterceptorX::Plugin::RelativePath allows you to map a remote path to a local path.

Every file the browser try to access inside that path with be returned contents from your local path.

# AUTHOR

Hernan Lopes <hernan@cpan.org>

# COPYRIGHT

Copyright 2013- Hernan Lopes

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
