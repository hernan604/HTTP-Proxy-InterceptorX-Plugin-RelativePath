package My::Proxy;
use Test::More;
use Moose;
use lib './t';
use TestsConfig;
use TestServer;
use HTTP::Tiny;
use Data::Printer;
use Path::Class;

extends qw/HTTP::Proxy::Interceptor/;
with qw/
    HTTP::Proxy::InterceptorX::Plugin::RelativePath
/;

my $url_path;
my $proxy_port        = 32452;
my $tests_config      = TestsConfig->new();
my $server            = TestServer->new();
   $server->set_dispatch( $tests_config->conteudos );
my $pid_server        = $server->background();
#ok 1;

my $p = My::Proxy->new( urls_to_proxy => {
    $server->root . "/dir/(.+)"         => {  "relative_path" => dir( "t" , "somedir" ) },
} );

my $pid = fork_proxy( $p );

#User agents
my $ua       = HTTP::Tiny->new( );
my $ua_proxy = HTTP::Tiny->new( proxy => "http://127.0.0.1:$proxy_port" );


#  NORMAL REQUEST (WITHOUT PROXY)
my $res            = $ua->get( $server->root . "/dir/scripts.js" );
my $content_wanted = $tests_config->conteudos->{ "/dir/scripts.js" }->{args}->{ content }->{ original };
ok( $res->{ content } eq $content_wanted , "Content is fine" );

   $res            = $ua->get( $server->root . "/dir/scripts2.js" );
   $content_wanted = $tests_config->conteudos->{ "/dir/scripts2.js" }->{args}->{ content }->{ original };
ok( $res->{ content } eq $content_wanted , "Content is fine" );

   $res            = $ua->get( $server->root . "/dir/dir2/script.js" );
   $content_wanted = $tests_config->conteudos->{ "/dir/dir2/script.js" }->{args}->{ content }->{ original };
ok( $res->{ content } eq $content_wanted , "Content is fine" );

   $res            = $ua->get( $server->root . "/dir/dir2/css/style.css" );
   $content_wanted = $tests_config->conteudos->{ "/dir/dir2/css/style.css" }->{args}->{ content }->{ original };
ok( $res->{ content } eq $content_wanted , "Content is fine" );

#  REQUEST WITH PROXY (CONTENT WILL BE MODIFIED)
my $res_proxy      = $ua_proxy->get( $server->root . "/dir/scripts.js" );
my $content_original = $tests_config->conteudos->{ "/dir/scripts.js" }->{args}->{ content }->{ original };
ok( $res_proxy->{ content } ne $content_original , "Content is not like the original" );
ok( $res_proxy->{ content } =~ m|content modified with this file: somedir/scripts.js|ig, "content is modified correctly" );

   $res_proxy      = $ua_proxy->get( $server->root . "/dir/scripts2.js" );
   $content_original = $tests_config->conteudos->{ "/dir/scripts2.js" }->{args}->{ content }->{ original };
ok( $res_proxy->{ content } ne $content_original , "Content is not like the original" );
ok( $res_proxy->{ content } =~ m|content modified with this file: somedir/scripts2.js|ig, "content is modified correctly" );

   $res_proxy      = $ua_proxy->get( $server->root . "/dir/dir2/script.js" );
   $content_original = $tests_config->conteudos->{ "/dir/dir2/script.js" }->{args}->{ content }->{ original };
ok( $res_proxy->{ content } ne $content_original , "Content is not like the original" );
ok( $res_proxy->{ content } =~ m|content modified with this file: somedir/dir2/script.js|ig, "content is modified correctly" );

   $res_proxy      = $ua_proxy->get( $server->root . "/dir/dir2/css/style.css" );
   $content_original = $tests_config->conteudos->{ "/dir/dir2/css/style.css" }->{args}->{ content }->{ original };
ok( $res_proxy->{ content } ne $content_original , "Content is not like the original" );
ok( $res_proxy->{ content } =~ m|content modified with this file: somedir/dir2/css/style.css|ig, "content is modified correctly" );

# kill web server and proxy server
kill 'HUP', $pid, $pid_server;

sub fork_proxy {
    my $proxy = shift;
#   my $sub   = shift;
    my $pid = fork;
    die "Unable to fork proxy" if not defined $pid;
    if ( $pid == 0 ) {
        $0 .= " (proxy)";
        # this is the http proxy
        $proxy->run(  port => $proxy_port );
#       $sub->() if ( defined $sub and ref $sub eq 'CODE' );
        exit 0;
    }
    # back to the parent
    return $pid;
}

done_testing;
