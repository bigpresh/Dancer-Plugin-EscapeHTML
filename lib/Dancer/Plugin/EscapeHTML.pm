package Dancer::Plugin::EscapeHTML;

use warnings;
use strict;

use Dancer::Plugin;
use Dancer qw(:syntax);

use HTML::Entities;

our $VERSION = '0.04';

=head1 NAME

Dancer::Plugin::EscapeHTML - Escape HTML entities to avoid XSS vulnerabilities


=head1 SYNOPSIS

This plugin provides convenience keywords C<escape_html> and
C<unescape_html> which are simply quick shortcuts to C<encode_entities>
and C<decode_entities> from L<HTML::Entities>.


    use Dancer::Plugin::EscapeHTML;

    my $encoded = escape_html($some_html);


It also provides optional automatic escaping of all HTML (see below.)


=head1 DESCRIPTION

This plugin is intended to provide a quick and simple way to ensure that
HTML passed in the tokens hashref to the template is safely escaped (encoded),
thereby helping to avoid
L<XSS/cross-site scripting vulnerabilities|http://en.wikipedia.org/wiki/Cross-site_scripting>.

You can encode specific bits of data yourself using the C<escape_html> and
C<unescape_html> keywords, or you can enable automatic escaping of all values
passed to the template.

In a future version, it is likely that this automatic escaping can be bypassed
for certain values - probably by providing parameter names/patterns in the
configuration to indicate parameters which should be left alone.


=head1 KEYWORDS

When the plugin is loaded, the following keywords are exported to your app:

=head2 escape_html

Encodes HTML entities; shortcut to C<encode_entities> from L<HTML::Entities>

=cut

register 'escape_html' => sub {
    return HTML::Entities::encode_entities(@_);
};


=head2 unescape_html

Decodes HTML entities; shortcut to C<decode_entities> from L<HTML::Entities>

=cut

register 'unescape_html' => sub {
    return HTML::Entities::decode_entities(@_);
};

=head1 Optional verbose debug

If you set the plugin variable 'debug' to a true value, you will get a
lot more noise in your log at the 'debug' level.

=cut

sub my_debug {
    debug @_ if plugin_setting->{debug};
}

=head1 Automatic HTML encoding

If desired, you can also enable automatic HTML encoding of all params passed to
templates.

To do so, enable the automatic_encoding option in your app's config - for
instance, add the following to your C<config.yml>:

    plugins:
        EscapeHTML:
            automatic_escaping: 1

Now, all values passed to the template will be automatically encoded, so you
should be protected from potential XSS vulnerabilities.

Of course, this has the drawback that you cannot provide pre-prepared HTML in
template params to be used "as is".  You can get round this by using the
C<exclude_pattern> option to provide a pattern to match token names which should
be exempted from automatic escaping - for example:

    plugins:
        EscapeHTML:
            automatic_escaping: 1
            exclude_pattern: '_html$'

The above would exclude token names ending in C<_html> from being escaped.

=cut

my $exclude_pattern;

hook before_template_render => sub {
    my $tokens = shift;
    my $config = plugin_setting;
    my_debug "Hook fired";
    return unless $config->{automatic_escaping};
    my_debug "OK, calling _encode";

    # compile $exclude_pattern once per template call
    $exclude_pattern = exists $config->{exclude_pattern}
        ? qr/$config->{exclude_pattern}/
        : undef;

    my_debug("Before encoding, tokens were:", $tokens);
    $tokens = _encode($tokens);
    my_debug("After encoding, tokens were:", $tokens);

};

# Encode values, recursing down into hash/arrayrefs.
# TODO: this will probably choke on circular references
sub _encode {
    my $in = shift;
    return unless defined $in; # avoid interpolation warnings
    my_debug "_encode called, looking at $in which is a " . ref $in;
    if (!ref $in) {
        my_debug "Encoding value $in...";
        $in = HTML::Entities::encode_entities($in);
        my_debug "Encoded value: $in";
    } elsif (ref $in eq 'ARRAY') {
        $in->[$_] = _encode($in->[$_]) for (0..$#$in);
    } elsif (ref $in eq 'HASH') {
        while (my($k,$v) = each %$in) {
            next if defined $exclude_pattern
                && $k =~ $exclude_pattern;
            $in->{$k} = _encode($v);
        }
    }
    return $in;
}


=head1 SEE ALSO

L<Dancer>

L<HTML::Entities>



=head1 AUTHOR

David Precious, C<< <davidp at preshweb.co.uk> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2011 David Precious.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

register_plugin;
1; # End of Dancer::Plugin::EscapeHTML
