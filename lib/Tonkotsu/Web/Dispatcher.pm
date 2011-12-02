package Tonkotsu::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;
use Path::Class;

get '/' => sub {
    my ($c) = @_;

    my $data = $c->cache->get('data');

    $c->render('index.tt', {
        entries => [ sort { $b->{date} cmp $a->{date} } values %{ $data->{entry_map} } ]
    });
};

get '/category/:category/' => sub {
    my ($c, $args) = @_;

    my $data = $c->cache->get('data');
    my $entries = [
        sort {
            $b->{date} cmp $a->{date}
        } grep {
            scalar( grep { $_ eq $args->{category} } @{ $_->{category} } )
        } values %{ $data->{entry_map} }
    ];

    $c->render('index.tt', {
        entries => $entries
    });
};

get '/{year:[0-9]{4}}/{month:[0-9]{2}}/' => sub {
    my ($c, $args) = @_;

    my $data = $c->cache->get('data');
    my $entries = [
        sort {
            $b->{date} cmp $a->{date}
        } grep {
            $_->{year}  eq $args->{year} and
            $_->{month} eq $args->{month}
        } values %{ $data->{entry_map} }
    ];

    $c->render('index.tt', {
        entries => $entries
    });
};

get '/{year:[0-9]{4}}/{month:[0-9]{2}}/{day:[0-9]{2}}/' => sub {
    my ($c, $args) = @_;

    my $data = $c->cache->get('data');
    my $entries = [
        sort {
            $b->{date} cmp $a->{date}
        } grep {
            $_->{year}  eq $args->{year} and
            $_->{month} eq $args->{month} and
            $_->{mday}  eq $args->{day}
        } values %{ $data->{entry_map} }
    ];

    $c->render('index.tt', {
        entries => $entries
    });
};

get '/author/:author/' => sub {
    my ($c, $args) = @_;

    my $data = $c->cache->get('data');
    my $entries = [
        sort {
            $b->{date} cmp $a->{date}
        } grep {
            $_->{code} eq $args->{author}
        } values %{ $data->{entry_map} }
    ];

    $c->render('index.tt', {
        entries => $entries
    });
};

get '/:author/{year:[0-9]{4}}/{month:[0-9]{2}}/:page/' => sub {
    my ($c) = @_;
    
    my $path = $c->req->path;
    my $data = $c->cache->get('data');
    my $entry = $data->{entry_map}->{ $path };
    
    return $c->res_404() unless $entry;
    
    $c->render('index.tt', {
        mode => 'entry',
        entry => $entry,
        entries => [ $entry ]
    });
};

1;
