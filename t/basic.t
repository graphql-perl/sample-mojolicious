use strict;
use warnings;
BEGIN {
  $ENV{MOJO_MODE}    = 'testing';
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
}
use Test::More;
use JSON::MaybeXS;
use FindBin;
require "$FindBin::Bin/../myapp.pl";
use Test::Mojo;
my $t = Test::Mojo->new;

subtest 'GraphiQL' => sub {
  my $res = $t->get_ok('/graphql', {
    Accept => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  })->content_like(qr/React.createElement\(GraphiQL/, 'Content as expected');
};

subtest 'status' => sub {
  $t->post_ok('/graphql', json => { query => '{status}' })
    ->json_is({ 'data' => { 'status' => JSON()->true } })
    ->or(sub { diag explain $t->tx->res->body })
    ;
};

my $wsp = Mojolicious::Plugin::GraphQL->ws_protocol;
my $query_sub = <<'EOF';
subscription s($channels: [String!]) {
  subscribe(channels: $channels) {
    channel
    message
    username
  }
}
EOF
my $init = { type => $wsp->{GQL_CONNECTION_INIT} };
my $ack = { type => $wsp->{GQL_CONNECTION_ACK} };
my $ka = { type => $wsp->{GQL_CONNECTION_KEEP_ALIVE} };
my $t_sub1 = Test::Mojo->new;
subtest 'subscribe1' => sub {
  my $start1 = {
    payload => {
      query => $query_sub,
      variables => { channels => ['testing'] },
    },
    type => $wsp->{GQL_START},
    id => 1,
  };
  $t_sub1->websocket_ok('/graphql')
    ->send_ok({json => $init})
    ->message_ok->json_message_is($ack)
    ->or(sub { diag explain $t->message })
    ->message_ok->json_message_is($ka)
    ->send_ok({json => $start1});
};

my @messages = (
  { channel => "testing", message => "yo", username => "bob" },
  { channel => "other", message => "hi", username => "bill" },
);
subtest 'publish' => sub {
  $t->post_ok('/graphql', json => {
    query => <<'EOF',
mutation m($messages: [MessageInput!]!) {
  publish(input: $messages)
}
EOF
    variables => { messages => \@messages },
  })->json_like('/data/publish' => qr/\d/)
    ->or(sub { diag explain $t->tx->res->body })
    ;
};

subtest 'notification1' => sub {
  my $data1 = {
    payload => { data => { subscribe => $messages[0] } },
    type => $wsp->{GQL_DATA},
    id => 1,
  };
  $t_sub1->message_ok->json_message_is($data1)
    ->or(sub { diag explain $t->message })
    ;
};

done_testing;
