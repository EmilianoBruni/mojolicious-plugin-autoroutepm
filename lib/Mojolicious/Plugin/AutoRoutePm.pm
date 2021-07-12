package Mojolicious::Plugin::AutoRoutePm;

use Mojo::Base 'Mojolicious::Plugin';
# ABSTRACT: Mojolicious plugin to create routes by *.pm modules which are a controller

use File::Find::Rule;
use Module::Load;

=pod

=begin :badge
=begin html
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/EmilianoBruni/mojolicious-plugin-autoroutepm?style=plastic"> <a href="https://travis-ci.com/EmilianoBruni/mojolicious-plugin-mongodbv2"><img alt="Travis tests" src="https://img.shields.io/travis/com/EmilianoBruni/mojolicious-plugin-autoroutepm?label=Travis%20tests&style=plastic"></a>
=end html
=end :badge

=head1 USAGE

This module recursive passes through template_base_dir to find perl module
(*.pm) that are a subclass of Mojolicious::Controller and some paths;

For module X::Y::Z it adds the decamelize version

  x/y/z
  x/y/z/index
  x/y/z/index/*query

all redirect to action route inside module.

If Z is default_index it adds also

  x/y
  x/y/*query

The last structure is useful for routing seach. But be careful to correct
relative urls of other items in html page.

This can be done in many ways. One is, as an example, to add to the layout
a base_url like this

  % my $base_url = url_for(undef, {query => undef}); $base_url =~ s|/$||;
  <base href="<%= $base_url %>" />

=cut

=pod

=method register

  plugin->register($app);

Register plugin in L<Mojolicious> application.

=cut

sub register {
  my ($self, $app, $conf) = @_;

  # default index
  my $dindex	= $conf->{default_index} || 'index';
  # Parent route
  my $r 		= $conf->{route} || [ $app->routes ];
  # Excluded routes
  my $exclude	= $conf->{exclude} || [];
#  my %exclude	= map {$_ => 1} @$exclude;

  # Template Base
  my $system_template_base_dirs = $app->renderer->paths;
	# by default renderer->paths appends templates to base_app_path
	# removing it we got the base path
	my $template_base_dirs = [];
	foreach (@$system_template_base_dirs) {
        my $tmpl_base_dir = $_; # so next replace doesn't affect origianl path
		$tmpl_base_dir =~ s/templates$//;
		push @$template_base_dirs, $tmpl_base_dir;
	}
  # Top directory
  my $top_dir = $conf->{top_dir} || '.';
  $top_dir =~ s#^/##;
  $top_dir =~ s#/$##;

  # Search templates
  my @templates;
  for my $template_base_dir (@$template_base_dirs) {
    $template_base_dir =~ s#/$##;
    my $template_dir = "$template_base_dir/$top_dir";

    if (-d $template_dir) {
      # Find templates
        my $rules = File::Find::Rule->file()->name('*.pm')
            ->relative(0)->start($template_dir);
        while ( defined ( my $file = $rules->match ) ) {
            $file =~ s/\.pm$//;
            my $excluded = 0;
            foreach (@$exclude) {
                $excluded = 1 if ($file =~ /$_/);
            }
            push @templates, $file unless ($excluded);
        }

    }
  }
  # Register routes
  for my $template (@templates) {
    # Route
	my $ctl = $self->path_to_controller($template);
	load $ctl;
	if ($ctl->isa('Mojolicious::Controller')) {
		$template = "/$template";
		my $route = $self->get_best_matched_route($template,$r);
		my $routep = $route->to_string;
		$template =~ s/$routep//;
        # support for /url_component/index
        my $tr = $route->any($template)->to(app => $ctl, action => 'route');
        $tr->any('/');
        # and for /url_component/index/a/b/x
        $tr->any('/*query');
        if ($template =~ s/$dindex$//) {
            # support for /url_component
            my $tr = $route->any($template)->to(app => $ctl, action => 'route');
            $tr->any('/');
            # and for /url_component/a/b/x
            $tr->any('/*query');
        }
	}
  }
}

sub get_best_matched_route {
	my $s		= shift;
	my $url		= shift;

	my $routes	= shift;

	my @ret;

	foreach my $r (@$routes) {
		push @ret, $r if (substr($url,0,length($r->to_string)) eq $r->to_string);
	}

	return $ret[0] if (scalar(@ret) == 1); # only one

	# more than one
	my $ret = $ret[0];
	foreach my $r (@ret) {
		$ret = $r if (length($r->name) > length($ret->name));
	}
	return $ret;
}

sub path_to_controller {
    my $s   = shift;
    my $url = shift;

    $url =~s{^/}{};
    $url =~s{/}{::}g;
    $url =~s{\.(.*?)$}{};

    return $url;
}

=pod

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut


1;
