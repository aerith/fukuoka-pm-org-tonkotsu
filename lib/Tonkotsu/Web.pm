package Tonkotsu::Web;
use strict;
use warnings;
use utf8;
use parent qw/Tonkotsu Amon2::Web/;
use File::Spec;

# dispatcher
use Tonkotsu::Web::Dispatcher;
sub dispatch {
    return Tonkotsu::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# load plugins
__PACKAGE__->load_plugins(
    # 'Web::FillInFormLite',
    'Web::NoCache', # do not cache the dynamic content by default
    # 'Web::CSRFDefender',
);

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
        $res->header( 'X-Frame-Options' => 'DENY' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        # ...
        return;
    },
);

1;
