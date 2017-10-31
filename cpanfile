requires 'Mojolicious::Lite';
requires 'GraphQL' => '0.17'; # default query etc type
requires 'Mojolicious::Plugin::GraphQL' => '0.03';

on test => sub {
  requires 'Test::Mojo';
};
