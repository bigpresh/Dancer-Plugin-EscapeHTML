package t::lib::TestApp;

use Dancer;
use Dancer::Plugin::EscapeHTML;

setting 'template' => 'Simple';
setting 'show_errors' => 1;

get '/straight' => sub {
    return template 'index', { foo => "<p>Foo</p>" };
};

get '/escaped' => sub {
    return template 'index', { foo => escape_html("<p>Foo</p>") };
};

1;
