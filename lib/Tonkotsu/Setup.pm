package Tonkotsu::Setup;
use strict;
use warnings;
use Calendar::Simple;
use Encode qw(decode_utf8);
use File::Spec::Functions qw(abs2rel);
use JSON qw(decode_json);

sub setup {
    my ($class, $c) = @_;
    
    $class->setup_data($c);
    $class->setup_sidebar($c);
}

sub setup_data {
    my ($class, $c) = @_;
    
    my $entry_map;
    my $author_map;
    $c->db->recurse(
        callback => sub {
            my $file = shift;
            return unless (-f $file and -s $file);
            
            my $rel_path = abs2rel($file, $c->db);

            if ($rel_path=~m{^([^/]+)/profile\.(json|yaml)$}) {
                my ($code, $format) = ($1, $2);
                warn "[DEBUG] ${code}'s profile format is $format";
                my $author = decode_json($file->slurp);
                $author_map->{ $code } = $author;
            } elsif ($rel_path=~m{^([^/]+)/blog/(.*)?/?(\d{4})(\d{2})(\d{2})(\d{2})\.(.*)\.(md|html)$}) {
                my ($code, $category, $year, $month, $mday, $hour, $page, $format)
                    = ($1, $2, $3, $4, $5, $6, $7, $8);
                my $date  = sprintf '%04d/%02d/%02d %02d:00', $year, $month, $mday, $hour;
                my $iso   = sprintf '%04d-%02d-%02dT%02d:00:00+0900', $year, $month, $mday, $hour;
                my $url   = sprintf '/%s/%04d/%02d/%s/', $code, $year, $month, $page;
                warn "[DEBUG] ${code}'s entry $url";
                my $fh = $file->openr;
                chomp( my $title = <$fh> );
                $fh->close;
                $title = decode_utf8($title);
                $title=~s|^#\s*||;
                $title=~s|^<h1[^>]*>||;
                $title=~s|</h1>||;
                my @category = split '/', $category;
                my $entry = {
                    code     => $code,
                    year     => $year,
                    month    => $month,
                    mday     => $mday,
                    date     => $date,
                    iso      => $iso,
                    page     => $page,
                    url      => $url,
                    # abs_url  => $abs_url,
                    file     => $file->stringify,
                    md       => "$month/$mday",
                    title    => $title,
                    category => \@category,
                    format   => $format
                };
                $entry_map->{ $url } = $entry;
            } else {
                warn "[ERROR] unknown data $rel_path";
            }
        }
    );
    
    $c->cache->set('data', {
        entry_map => $entry_map,
        author_map => $author_map
    });
}

sub setup_sidebar {
    my ($class, $c) = @_;
    
    my $data = $c->cache->get('data');
    my $entry_map = $data->{entry_map};
    my $author_map = $data->{author_map};
    
    my @recents = sort { $b->{date} cmp $a->{date} } values %{ $entry_map };
    @recents = splice(@recents, 0, ($c->config->{max_recents} - 1))
        if scalar(@recents) > $c->config->{max_recents};
    
    
    my $month_hash = {};
    my $day_hash = {};
    my $category_hash = {};
    for my $entry ( values %{ $entry_map } ) {
        $month_hash->{ $entry->{year} . $entry->{month} } ||= {
            year  => $entry->{year},
            month => $entry->{month},
            name  => $entry->{year} . '/' . $entry->{month},
            url   => '/' . $entry->{year} . '/' . $entry->{month} . '/'
        };
        $month_hash->{ $entry->{year} . $entry->{month} }->{count}++;
        $day_hash->{ $entry->{year} . $entry->{month} . $entry->{mday} }++;
        for (@{ $entry->{category} }) {
            $category_hash->{$_} ||= {
                name => $_,
                url  => "/category/$_/"
            };
            $category_hash->{$_}->{count}++;
        }
    }
    my @categories = sort { $a->{name} cmp $b->{name} } values %$category_hash;
    my @months = sort { $a->{name} cmp $b->{name} } values %$month_hash;
    my $cur_month = (localtime)[4] + 1;
    my $cur_year = (localtime)[5] + 1900;
    my @this_calender = calendar();
    my $conv = sub {
        my ($y, $m, $d) = @_;
        return unless $d;
        my $ymd = sprintf '%04d%02d%02d', $y, $m, $d;
        my $url = sprintf '/%04d/%02d/%02d/', $y, $m, $d;
        +{
            day => $d,
            has_entry => $day_hash->{ $ymd },
            url => $url
        };
    };
    for my $week (@this_calender) {
        @$week = map { $conv->($cur_year, $cur_month, $_) } @$week;
    }
    my ($last_year, $last_month) = ($cur_year, $cur_month);
    $last_month--;
    $last_year-- if $last_month == 0;
    $last_month = 12 if $last_month == 0;
    my @last_calender = calendar($last_month, $last_year);
    for my $week (@last_calender) {
        @$week = map { $conv->($last_year, $last_month, $_) } @$week;
    }
    my $sidebar = $c->create_view->render('include/sidebar.tt', {
        recents       => \@recents,
        categories    => \@categories,
        months        => \@months,
        this_calendar => \@this_calender,
        last_calendar => \@last_calender
    });
    
    $c->cache->set('sidebar', $sidebar);
}

1;
