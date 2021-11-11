package welcome::anotherPage;

use Mojo::Base 'Mojolicious::Controller';

sub route() {
	my $c   = shift;
    $c->render(template => 'welcome/anotherPage');
}

1;
