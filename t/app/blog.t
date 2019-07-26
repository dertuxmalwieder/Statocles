
=head1 DESCRIPTION

This tests the blog application, Statocles::App::Blog

=cut

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use FindBin qw( $Bin );
use Mojo::File qw( path );

$ENV{MOJO_HOME} = path( $Bin, '..', 'share', 'blog' );
my $t = Test::Mojo->new( Statocles => {
    apps => {
        blog => {
            route => '/',
            limit => 3,
        },
    },
} );

$t->get_ok( '/' )->status_is( 200 )
  ->text_is( 'article:nth-of-type(1) h1 a', 'Fourth Post', 'most recent post is first in list' )
  ->or( sub { diag shift->tx->res->body } )
  ->text_is( 'article:nth-of-type(2) h1 a', 'Third Post' )
  ->or( sub { diag shift->tx->res->body } )
  ->text_is( 'article:nth-of-type(3) h1 a', 'Second Post' )
  ->or( sub { diag shift->tx->res->body } )
  ->element_exists_not( 'article:nth-of-type(4)', 'page has limit => 3 articles' )
  ->or( sub { diag shift->tx->res->body } )
  ->element_exists( '.pager .next [rel=next][href=/2]', 'older button is enabled' )
  ->or( sub { diag shift->tx->res->dom->at( '.pager' ) } )
  ->element_exists( '.pager .prev button[disabled]', 'newer button is disabled' )
  ->or( sub { diag shift->tx->res->dom->at( '.pager' ) } )
  ->element_exists(
      'link[rel=alternate][type=application/rss+xml][href=/1.rss]',
      'rss feed <link> exists'
  )
  ->or( sub { diag shift->tx->res->dom->at( 'head' ) } )
  ->element_exists(
      'link[rel=alternate][type=application/atom+xml][href=/1.atom]',
      'atom feed <link> exists'
  )
  ->or( sub { diag shift->tx->res->dom->at( 'head' ) } )

  ->get_ok( '/2' )->status_is( 200 )
  ->text_is( 'article:nth-of-type(1) h1 a', 'First Post', 'final post on last page' )
  ->or( sub { diag shift->tx->res->body } )
  ->element_exists( '.pager .next button[disabled]', 'older button is disabled' )
  ->or( sub { diag shift->tx->res->dom->at( '.pager' ) } )
  ->element_exists( '.pager .prev [rel=prev][href=/]', 'newer button is enabled' )
  ->or( sub { diag shift->tx->res->dom->at( '.pager' ) } )
  ->element_exists(
      'link[rel=alternate][type=application/rss+xml][href=/1.rss]',
      'rss feed <link> exists'
  )
  ->or( sub { diag shift->tx->res->dom->at( 'head' ) } )
  ->element_exists(
      'link[rel=alternate][type=application/atom+xml][href=/1.atom]',
      'atom feed <link> exists'
  )
  ->or( sub { diag shift->tx->res->dom->at( 'head' ) } )

  ->get_ok( '/first-post' )->status_is( 200 )
  ->text_is( 'h1', 'First Post' )

  ->get_ok( '/second-post' )->status_is( 200 )
  ->text_is( 'h1', 'Second Post' )

  ->get_ok( '/1.rss', { Accept => 'application/rss+xml' } )->status_is( 200 )
  ->text_is( 'item:nth-of-type(1) title', 'Fourth Post', 'most recent post is first in list' )
  ->or( sub { diag shift->tx->res->body } )
  ->text_is( 'item:nth-of-type(2) title', 'Third Post' )
  ->or( sub { diag shift->tx->res->body } )
  ->text_is( 'item:nth-of-type(3) title', 'Second Post' )
  ->or( sub { diag shift->tx->res->body } )
  ->element_exists_not( 'item:nth-of-type(4) title', 'only 3 items per page' )
  ->or( sub { diag shift->tx->res->body } )

  ->get_ok( '/1.atom', { Accept => 'application/atom+xml' } )->status_is( 200 )
  ->text_is( 'entry:nth-of-type(1) title', 'Fourth Post', 'most recent post is first in list' )
  ->or( sub { diag shift->tx->res->body } )
  ->text_is( 'entry:nth-of-type(2) title', 'Third Post' )
  ->or( sub { diag shift->tx->res->body } )
  ->text_is( 'entry:nth-of-type(3) title', 'Second Post' )
  ->or( sub { diag shift->tx->res->body } )
  ->element_exists_not( 'entry:nth-of-type(4) title', 'only 3 items per page' )
  ->or( sub { diag shift->tx->res->body } )

  ;

is_deeply $t->app->export->pages, [ '/sitemap.xml', '/robots.txt', '/' ];

done_testing;
