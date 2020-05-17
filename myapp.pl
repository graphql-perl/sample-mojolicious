#!/usr/bin/env perl
use Mojolicious::Lite;
use GraphQL::Type::Scalar qw($String);
use Mojo::Redis;

get '/' => sub {
  my $c = shift;
  $c->render(template => 'index');
};

plugin GraphQL => {
  convert => [
    'MojoPubSub',
    {
      username => $String->non_null,
      message => $String->non_null,
    },
    Mojo::Redis->new($ENV{TEST_REDIS} || 'redis://localhost'),
  ],
  graphiql => 1,
  keepalive => 5,
};

app->start;
__DATA__

@@ index.html.ep
% title 'Perl-GraphQL demo app';
<!DOCTYPE html>
<html lang="en">
<head>
  <title><%= title %></title>
</head>
<body>
<div id="page">
  <div id="content">
    <h1>Perl GraphQL Mojolicious Demo App</h1>
    <p>This demonstrates use of GraphQL in a Mojolicious::Lite app.</p>
    <p>The schema has one query field: <code>status</code>.</p>
    <p>The schema has one mutation field: <code>publish</code>.</p>
    <p>The schema has one subscription field: <code>subscribe</code>.</p>
    <p>The frontend uses the GraphiQL tool to query the Perl GraphQL backend.</p>
    <p>To use the demo, try these queries:</p>
    <p><code>
      query q {status}<br>
      mutation m {publish(input: { username: "u1", message: "m1", channel: "t1"})}<br>
      subscription s {subscribe(channels: ["t1"]) {channel username dateTime message}}
    </code></p>
    <p>in the left hand pane in GraphiQL, then run your query using the button at the top.</p>
    <p>Results are displayed in the pane to the right.</p>
    <h2>Click to <%= link_to 'enter GraphiQL' => '/graphql' %>.</h2>
  </div>
<div>
</body>
</html>
