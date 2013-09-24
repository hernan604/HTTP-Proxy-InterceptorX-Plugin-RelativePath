package HTTP::Proxy::InterceptorX::Plugin::RelativePath;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use Moose::Role;
use Path::Class;

=head2

This plugin maps a url path to a local directory. ie: 

    remote path: http://www.site.com.br/scripts/js/(.+)
     local path:                      /home/user/js/....

Vai tentar pegar nos mesmos diretórios mas vai abrir arquivos locais ao invés de remotos

=cut

sub replace_for_relativepath {
  my ( $self, $args ) = @_; 
  foreach my $url ( keys $self->urls_to_proxy ) {
    next unless exists $self->urls_to_proxy->{ $url }->{ relative_path }
                    && $self->http_request->{ _uri }->as_string =~ m/$url/;
    my $arquivo= file( $self->urls_to_proxy->{ $url }->{ relative_path } , $+{caminho}||$+{path}||$1 );
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
    $self->append_plugin_method( "replace_for_relativepath" );
};

1;
__END__

=encoding utf-8

=head1 NAME

HTTP::Proxy::InterceptorX::Plugin::RelativePath - Blah blah blah

=head1 SYNOPSIS

  use HTTP::Proxy::InterceptorX::Plugin::RelativePath;

=head1 DESCRIPTION

HTTP::Proxy::InterceptorX::Plugin::RelativePath is

=head1 AUTHOR

Hernan Lopes E<lt>hernan@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Hernan Lopes

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
