requires 'Mojolicious::Lite';
requires 'GraphQL' => '0.20'; # convert plugin
requires 'Mojolicious::Plugin::GraphQL' => '0.06'; # convert plugin

on test => sub {
  requires 'Test::Mojo';
};
