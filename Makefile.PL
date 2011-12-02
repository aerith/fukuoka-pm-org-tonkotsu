use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Tonkotsu',
    AUTHOR        => 'aerith',
    VERSION_FROM  => 'lib/Tonkotsu.pm',
    PREREQ_PM     => {
        # 'Amon2::DBI'                      => '0.06',
        # 'DBD::SQLite'                     => '1.33',
        # 'HTML::FillInForm::Lite'          => '1.09',
        # 'Plack::Session'                  => '0.14',
        'Amon2'                           => '3.18',
        'Calendar::Simple'                => '1.21',
        'JSON'                            => '2.50',
        'Log::Minimal'                    => '0.06',
        'Path::Class'                     => '',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'Plack::Middleware::Session'      => '0',
        'String::CamelCase'               => '0.02',
        'Test::More'                      => '0.98',
        'Test::WWW::Mechanize::PSGI'      => '0',
        'Text::Markdown'                  => '1.000031',
        'Text::Xslate'                    => '1.4001',
        'Text::Xslate::Bridge::TT2Like'   => '0.00008',
        'Time::Piece'                     => '1.20',

    },
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
