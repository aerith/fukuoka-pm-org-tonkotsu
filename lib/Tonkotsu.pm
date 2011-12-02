package Tonkotsu;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;
use Encode qw(decode_utf8);
use File::Basename qw(dirname);
use Path::Class;
use JSON;
use YAML;
use Tonkotsu::Cache;
use Tonkotsu::Setup;

my $cache = Tonkotsu::Cache->new();

sub cache { $cache }

sub db {
    dir(dirname(dirname(__FILE__)), 'db');
}

sub setup {
    my ($c) = @_;
    
    Tonkotsu::Setup->setup($c);
}

sub entry_as_html {
    my ($c, $entry) = @_;
    my $html = file($entry->{file})->slurp;
    if ($entry->{format} eq 'md') {
        $html = Text::Markdown::markdown($html);
    } elsif ($entry->{format} eq 'html') {
        
    } else {
        return "[ERROR] unknown format " . $entry->{format};
    }
    return $html;
}

# setup view class
use Encode qw(decode_utf8);
use File::Spec;
use Text::Markdown;
use Text::Xslate qw(html_builder);
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
                        $static_file_cache{$fname} = (stat $fullpath)[9];
                    }
                    return $c->uri_for($fname, { 't' => $static_file_cache{$fname} || 0 });
                }
            },
            # markdown => html_builder {
            #     Text::Markdown::markdown(shift);
            # },
            summary => sub {
                my ($html) = @_;
                $html = decode_utf8($html);
                $html=~s|.*||;
                $html=~s|<.*?>||mg;
                $html;
            }
        },
        %$view_conf
    });
    sub create_view { $view }
}

1;
