package Dancer::Plugin::Piwik;

use 5.010001;
use strict;
use warnings FATAL => 'all';
use Dancer qw/:syntax/;
use Dancer::Plugin;


=head1 NAME

Dancer::Plugin::Piwik - Generate JS code for Piwik

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

In your configuration:

  plugins:
    Piwik:
      id: "your-id"
      url: "your-url"

In your module

    use Dancer ':syntax';
    use Dancer::Plugin::Piwik;



=head1 EXPORTED KEYWORDS

=head2 piwik

Return generic code for page view tracking. No argument required.

=head2 piwik_category(category => "name")

Generate js for category pages. Requires a named argument C<category>
with the name of the category to track.

=head2 piwik_view(product => { sku => $sku, description => $desc, categories => \@categories, price => $price  })

Generate js for flypages. Expects a named argument product, paired
with an hashref with the product data, having the following keys

=over 4

=item sku

=item description

=item categories

(an arrayref with the names of the categories). An empty arrayref can
do as well).

=item price

The price of the item

=back

=head2 piwik_cart

Generate js for cart view

=head2 piwik_order

Generate js for the receipt

=cut


sub _piwik {
    return _generate_js();
}

sub _piwik_category {
    my %args = @_;
    my $category = $args{category};
    die "Missing category" unless $category;
    return _generate_js([ setEcommerceView => \0, \0, $category  ]);
}

sub _piwik_view {
    my %args = @_;
    my $product = $args{product};
    my $arg = [
               setEcommerceView => $product->{sku},
               $product->{description},
               [ @{ $product->{categories} } ],
               $product->{price} + 0,
              ];
    return _generate_js($arg);
}

sub _piwik_cart {
    my %args = @_;
    my @addendum;
    return _generate_js(@addendum);
}

sub _piwik_order {
    my %args = @_;
    my @addendum;
    return _generate_js(@addendum);
}

sub _generate_js {
    my (@args) = @_;
    my $piwik_url = plugin_setting->{url};
    my $piwik_id  = plugin_setting->{id};
    my $addendum = '';
    foreach my $arg (@args) {
        $addendum .= '_paq.push(' . to_json($arg) . ");\n";
    }

    die "Missing configuration: id and url are mandatory!"
      unless defined($piwik_url) && defined($piwik_id);
    my $js = <<"JAVASCRIPT";
<script type="text/javascript">
  var _paq = _paq || [];
  $addendum
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u=(("https:" == document.location.protocol) ? "https" : "http") + "://$piwik_url/";
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', $piwik_id ]);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0]; g.type='text/javascript';
    g.defer=true; g.async=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
<noscript><p><img src="http://$piwik_url/piwik.php?idsite=$piwik_id" style="border:0;" alt="" /></p></noscript>
JAVASCRIPT
        return $js;
}

register piwik => \&_piwik;
register piwik_category => \&_piwik_category;
register piwik_view => \&_piwik_view;
register piwik_cart => \&_piwik_cart;
register piwik_order => \&_piwik_order;

register_plugin;


=head1 AUTHOR

Stefan Hornburg (Racke), C<< <racke at linuxia.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-piwik at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-Piwik>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::Piwik


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-Piwik>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Plugin-Piwik>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-Piwik>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Plugin-Piwik/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Dancer::Plugin::Piwik
