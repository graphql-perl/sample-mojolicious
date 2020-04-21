## Mojolicious sample app

This is a trivial "hello, world" demonstration of using Mojolicious
to serve GraphQL, using
[GraphQL::Plugin::Convert::Test](https://metacpan.org/pod/GraphQL::Plugin::Convert::Test)
to make a schema. If using a recent enough version of the libraries,
the schema will include a working subscription.

### To use:

```
cpanm --installdeps .
./myapp.pl daemon -l http://*:5000
```

Point your browser at http://localhost:5000

After clicking through to the GraphiQL tool, try entering this query in
the upper left-hand pane:

```
{ helloWorld }
```
