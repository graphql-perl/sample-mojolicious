requires 'Mojolicious::Lite';
requires 'GraphQL';
requires 'Mojolicious::Plugin::GraphQL';

on test => sub {
  requires 'Test::Mojo';
};
