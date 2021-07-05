# NAME

Mojolicious::Plugin::AutoRoutePm - Mojolicious plugin to create routes by \*.pm modules which are a controller

[![Build Status](https://travis-ci.com/EmilianoBruni/mojolicious-plugin-autoroutepm.png?branch=master)](https://travis-ci.com/EmilianoBruni/mojolicious-plugin-autoroutepm)

# VERSION

version 0.13

# METHODS

## register

    plugin->register($app);

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# USAGE

This module recursive passes through template\_base\_dir to find perl module
(\*.pm) that are a subclass of Mojolicious::Controller and some paths;

For module X::Y::Z it adds the decamelize version

    x/y/z
    x/y/z/index
    x/y/z/index/*query

all redirect to action route inside module.

If Z is default\_index it adds also

    x/y
    x/y/*query

The last structure is useful for routing seach. But be careful to correct
relative urls of other items in html page.

This can be done in many ways. One is, as an example, to add to the layout
a base\_url like this

    % my $base_url = url_for(undef, {query => undef}); $base_url =~ s|/$||;
    <base href="<%= $base_url %>" />

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).

# AUTHOR

Emiliano Bruni <info@ebruni.it>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Emiliano Bruni.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
