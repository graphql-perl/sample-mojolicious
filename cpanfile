requires 'Mojolicious::Lite';
requires 'GraphQL' => '0.16';
requires 'Mojolicious::Plugin::GraphQL' => '0.03';

on test => sub {
  requires 'Test::Mojo';
};
