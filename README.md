## Mojolicious sample app

This is a demonstration of using Mojolicious to serve GraphQL, using
[GraphQL::Plugin::Convert::MojoPubSub](https://metacpan.org/pod/GraphQL::Plugin::Convert::MojoPubSub)
to make a schema. The schema includes a working subscription.

### To use:

```
cpanm --installdeps .
./myapp.pl daemon -l http://*:5000
```

Point your browser at http://localhost:5000

After clicking through to the GraphiQL tool, try entering the queries
given on the main page of the app, in the upper left-hand pane.
