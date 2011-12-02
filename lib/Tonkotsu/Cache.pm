package Tonkotsu::Cache;
use strict;
use warnings;

my $cache = {};

sub new {
    my ($class) = @_;
    
    bless {}, $class;
}

sub get {
    my ($self, $key) = @_;
    
    $cache->{$key};
}

sub set {
    my ($self, $key, $val) = @_;
    
    $cache->{$key} = $val;
}

sub remove {
    my ($self, $key) = @_;
    
    delete $cache->{$key};
}

1;
