package HTTP::Proxy::InterceptorX::Plugin::RelativePath;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use Moose::Role;
use Path::Class;

sub RelativePath {
  my ( $self, $args ) = @_;
  foreach my $url ( keys $self->urls_to_proxy ) {
    next unless exists $self->urls_to_proxy->{ $url }->{ RelativePath }
                    && $self->http_request->{ _uri }->as_string =~ m/$url/;
    my $arquivo= file( $self->urls_to_proxy->{ $url }->{ RelativePath } , $+{caminho}||$+{path}||$1 );
    $arquivo =~ s/(\?.+$)//g; #tira os ?blablabla da url pois não é possível abrir arquivo
    if ( -e $arquivo ) {
      $self->print_file_as_request( $arquivo );
      return 1;
    } else {
        warn " ARQUIVO NAO ENCONTRADO: " . $arquivo;
    }
    return 0;
  }
}

after 'BUILD'=>sub {
    my ( $self ) = @_;
    $self->append_plugin_method( "RelativePath" );
};

1;
__END__

=encoding utf-8

=head1 NAME

HTTP::Proxy::InterceptorX::Plugin::RelativePath - Maps a website path into local path

=head1 SYNOPSIS

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

=head1 CONFIG

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

=head1 DESCRIPTION

HTTP::Proxy::InterceptorX::Plugin::RelativePath allows you to map a remote path to a local path.

Every file the browser try to access inside that path with be returned contents from your local path.

=head1 AUTHOR

Hernan Lopes E<lt>hernan@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Hernan Lopes

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
