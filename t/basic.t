use strict;
use warnings;
BEGIN {
  $ENV{MOJO_MODE}    = 'testing';
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
}
use Test::More;
use FindBin;
require "$FindBin::Bin/../myapp.pl";
use Test::Mojo;
my $t = Test::Mojo->new;

subtest 'GraphiQL' => sub {
  my $res = $t->get_ok('/graphql', {
    Accept => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  })->content_like(qr/React.createElement\(GraphiQL/, 'Content as expected');
};

subtest 'GraphQL with POST' => sub {
  $t->post_ok('/graphql', { Content_Type => 'application/json' },
    '{"query":"{helloWorld}"}',
  )->json_is(
    { 'data' => { 'helloWorld' => 'Hello, world!' } },
  );
};

done_testing;
