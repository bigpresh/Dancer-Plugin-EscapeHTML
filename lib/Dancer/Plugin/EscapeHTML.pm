package Dancer::Plugin::EscapeHTML;

use warnings;
use strict;

use Dancer::Plugin;
use Dancer qw(:syntax);

use HTML::Entities;

=head1 NAME

Dancer::Plugin::EscapeHTML - Escape HTML entities to avoid XSS vulnerabilities!

our $VERSION = '0.01';


=head1 SYNOPSIS

The plugin provides convenience keywords C<encode_entities> and
C<decode_entities> which are simply quick shortcuts to functions of the same
name provided by L<HTML::Entities>.


    use Dancer::Plugin::EscapeHTML;

    my $encoded = encode_entities($some_html);


=head1 KEYWORDS

When the plugin is loaded, the following keywords are exported to your app:

=head2 encode_entities

Encodes HTML entities; shortcut to C<encode_entities> from L<HTML::Entities>

=cut

register 'encode_entities' => sub {
    return HTML::Entities::encode_entities(@_);
};


=head2 decode_entities

Decodes HTML entities; shortcut to C<decode_entities> from L<HTML::Entities>

=cut

register 'decode_entities' => sub {
    return HTML::Entities::decode_entities(@_);
};


=head1 Automatic HTML encoding

If desired, you can also enable automatic HTML encoding of all params passed to
templates.

To do so, enable the automatic_encoding option in your app's config - for
instance, add the following to your C<config.yml>:

    plugins:
        EscapeHTML:
            automatic_encoding: 1

Now, all values passed to the template will be automatically encoded, so you
should be protected from potential XSS vulnerabilities.

Of course, this has the drawback that you cannot provide pre-prepared HTML in
template params to be used "as is".  It is planned that a future version of this
module will allow you to configure exceptions, naming params / param name
patterns which should be left alone.

=cut

hook before_template_render => sub {
    my $config = plugin_setting;
    return unless $config->{automatic_encoding};

    _encode($tokens);

};

# Santise a value appropriately
# TODO: this will probably choke on circular references
sub _encode {
    my $in = shift;
    if (!ref $in) {
        $in = HTML::Entities::encode_entities($in);
    } elsif (ref $in eq 'ARRAY') {
        _encode($_) for @$in;
    } elsif (ref $val eq 'HASH') {
        _encode($_) for values %$in;
    }
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
