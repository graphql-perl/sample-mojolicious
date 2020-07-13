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

get '/chat' => sub {
  my $c = shift;
  $c->render(template => 'chat',
    username => $c->param('username') || 'Demo-name',
    channel  => $c->param('channel') || 'Demo-channel',
  );
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
      mutation m($u: String!, $m: String!, $c: String!) {publish(input: { username: $u, message: $m, channel: $c})}<br>
      # put this in "Query Variables" pane: {"u": "u1", "m": "m1", "c": "starter"}<br>
      subscription s($c: [String!]) {subscribe(channels: $c) {channel username dateTime message}}
    </code></p>
    <p>in the left hand pane in GraphiQL, then run your query using the button at the top.</p>
    <p>Results are displayed in the pane to the right.</p>
    <h2>Click to <%= link_to 'enter GraphiQL' => '/graphql' %>.</h2>
  </div>
  <div id="chat-content">
  <h2>There is also a demonstration chat app</h2>
  <ul>
    <li><a href="/chat?channel=starter&username=Larry">Open Channel 'starter' as User 'Larry' with GraphQL endpoints</a></li>
  </ul>
  </div>
<div>
</body>
</html>

@@ chat.css
/* From https://www.w3schools.com/howto/howto_css_chat.asp */
/* Chat message containers */
.chat-container {
  border: 2px solid #dedede;
  background-color: #f1f1f1;
  border-radius: 5px;
  padding: 10px;
  margin: 10px 0;
  position: relative;
}
/* Darker chat container */
.darker {
  border-color: #ccc;
  background-color: #ddd;
}
/* Clear floats */
.chat-container::after {
  content: "";
  clear: both;
  display: table;
}
/* Style images */
.chat-container img {
  float: left;
  max-width: 40px;
  width: 100%;
  margin-right: 20px;
  border-radius: 50%;
}
/* Style the right image */
.chat-container img.right {
  float: right;
  margin-left: 20px;
  margin-right:0;
}
.chat-container span.right {
  float: right;
}
/* Style time text */
.time-right {
  float: right;
  color: #aaa;
  font-size: small;
}
/* Style time text */
.time-left {
  float: left;
  color: #999;
  font-size: small;
}
/* ------- END CHAT STYLE ----- */
html, body {
  height: 100%;
  margin: 0;
  padding: 10px;
  font-family: 'Alatsi';font-size: 18px;
}
.row {
  display: flex;
}
.column {
  flex: 50%;
}
@media screen and (max-width: 600px) {
  .column {
    width: 100%;
  }
}

@@ chat.html.ep
% title 'Perl-GraphQL demo Chat app';
<!DOCTYPE html>
<html lang="en">
<head>
  <title><%= title %></title>
  <link href="chat.css" rel="stylesheet" type="text/css">
</head>
<body>
  <div id="page">
    <div id="content">
    <h1>
      Chat Demo
      '<span id=username><%= $username %></span>'
      on channel
      '<span id=channel><%= $channel %></span>'
    </h1>
    <div class="row">
      <div class="column" id='chat-panel' style="background-color:#bbb; overflow: auto; max-height: 400px">
      </div>
    </div>
    <div class="row">
      <div class="column"></div>
      <div class="column">
        <form onsubmit="send_message(this.children[0]); return false">
          <input type="text" id="chat-text" name="chat-text" size=40>
          <input type="submit" value="Send Message">
        </form>
      </div>
    </div>
    </div>
  </div>
  <script src="//unpkg.com/subscriptions-transport-ws@0.9.16/browser/client.js"></script>
  <script src="chat.js"></script>
</html>

@@ chat.js
var username = document.getElementById("username").innerHTML;
var channel  = document.getElementById("channel").innerHTML;
var graphql_uri = '/graphql';
var websocket_uri = window.location.protocol === "https:" ? "ws" : "w";
websocket_uri += "s://" + window.location.host + graphql_uri;
var chatPanel = document.getElementById("chat-panel");
document.getElementById("chat-text").focus();
function send_message_graphql(msg) {
  return fetch( graphql_uri, {
    method: "POST",
    headers: {
      "accept": "application/json",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      query: "mutation m($u: String!, $m: String!, $c: String!) {publish(input: { username: $u, message: $m, channel: $c})}",
      variables: { u: username, m: msg, c: channel },
      operationName: "m",
    }),
    credentials: "include"
  });
}
send_message_graphql(username + ' has joined');
function message_html(msg, is_me) {
  var locale = window.navigator.userLanguage || window.navigator.language;
  var local_time_string = new Date( msg.dateTime + 'Z' ).toLocaleTimeString( locale, { hour: 'numeric',minute: 'numeric'} );
  var html = '';
  html += '<div class="chat-container';
  if (is_me) html += ' darker';
  html += '"><span class="right">' + msg.username + ' says:</span><hr/><p>' + msg.message + '</p>';
  html += '<span class="time-right">' + local_time_string + '</span></div>';
  return html;
}
if ("WebSocket" in window) {
  const subscriptionsClient = new window.SubscriptionsTransportWs.SubscriptionClient(websocket_uri, {
    lazy: true, // not in original
    reconnect: true
  });
  subscriptionsClient.request({
    "query":"subscription s($c: [String!]) {subscribe(channels: $c) {channel username dateTime message}}",
    "variables": { c: channel },
  }).subscribe({
    next(payload) {
      var message_json = payload.data.subscribe;
      chatPanel.innerHTML += message_html(message_json, message_json.username === username);
      chatPanel.scrollTop = chatPanel.scrollHeight;
    },
    error(err) { console.error('err', err); },
  });
} else {
  alert('WebSockets not supported by this browser');
}
function send_message(elt) {
  send_message_graphql( elt.value );
  elt.value = '';
  elt.focus();
}
