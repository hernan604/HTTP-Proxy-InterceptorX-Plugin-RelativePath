package TestsConfig;
use Moose;
use File::Slurp;
use Path::Class;

has conteudos => (
    is => 'ro',
    default => sub {
        return 
        {
            "/dir/scripts.js" => {
                ref     => \&html_content,
                args    => {
                    content => { original => "original content from /dir/scripts.js" }
                }
            },
            "/dir/scripts2.js" => {
                ref     => \&html_content,
                args    => {
                    content => { original => "HTTP original content from /dir/scripts2.js" }
                }
            },
            "/dir/dir2/script.js" => {
                ref     => \&html_content,
                args    => {
                    content => { original => "original content from /dir/dir2/script.js" }
                }
            },
            "/dir/dir2/css/style.css" => {
                ref     => \&html_content,
                args    => {
                    content => { original => "original content from css /dir/dir2/css/style.css" }
                }
            },
        };
    }
); 

sub html_content {
    my ( $cgi, $url_path, $args ) = @_;
    return if !ref $cgi;
    print
        $cgi->header(),
        (   defined $args 
        and exists $args->{ content } 
        and exists $args->{ content }->{ original } )
        ? $args->{ content }->{ original } : ""
}


1;
