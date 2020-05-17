requires 'Mojolicious::Lite';
requires 'GraphQL' => '0.40'; # subs
requires 'Mojolicious::Plugin::GraphQL' => '0.16'; # keepalive
requires 'GraphQL::Plugin::Convert::MojoPubSub' => '0.01';
requires 'Mojo::Redis' => '3.24';

on test => sub {
  requires 'Test::Mojo';
};
