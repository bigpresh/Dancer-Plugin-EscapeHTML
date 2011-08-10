use strict;
use warnings;

use Test::More import => ['!pass'];

use t::lib::TestApp;
use Dancer ':syntax';
use Dancer::Test;

plan tests => 4;

# First, check that the explicitly-escaped HTML got escaped, but the one passed
# as-is was unmolested:


response_content_is [ GET => '/straight' ], "<p>Foo</p>\n",
    "Content for /straight not escaped";
response_content_is [ GET => '/escaped'  ], "&lt;p&gt;Foo&lt;/p&gt;\n",
    "Content for /escaped is escaped";


# Now, enable automatic escaping and check it worked:
setting plugins => { 
    EscapeHTML => { 
        automatic_escaping => 1,
        exclude_pattern => '_html$',
    },
};

response_content_is [ GET => '/straight'  ], "&lt;p&gt;Foo&lt;/p&gt;\n",
    "Content for /escaped is escaped with automatic_escaping enabled";


response_content_is [ GET => '/excluded' ], "<p>Foo</p>\n",
    "Content for /excluded is not escaped even with automatic_escaping enabled";


