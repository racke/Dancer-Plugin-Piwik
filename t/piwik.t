#!perl

use strict;
use warnings;
use utf8;
use Test::More;

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

use Dancer ':tests';
use Dancer::Plugin::Piwik;
use Dancer::Test;

my $piwik_id = 1;
my $piwik_url = 'localhost/analytics';
set plugins => {
                'Piwik' => {
                            id => $piwik_id,
                            url => $piwik_url,
                           }
               };

like piwik, qr{\Q//$piwik_url/"\E}, "Found url on piwik";
like piwik, qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E}, "Found id on piwik";

my %args;

%args = ( category => 'Strazze' );
like piwik_category(%args), qr{\Q//$piwik_url/"\E}, "Found url on piwik category";
like piwik_category(%args), qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E},
  "Found id on piwik category";
like piwik_category(%args), qr{setEcommerceView}, "Found the view";
like piwik_category(%args), qr{Strazze}, "Found the view";

eval {
    piwik_category;
};
like $@, qr/Missing category/, "Found exception";

%args = (
         product => {
                     sku => 'A sku',
                     description => 'My desc',
                     categories => [qw/first second/],
                     price => 1.20,
                    },
        );

like piwik_view(%args), qr{\Q//$piwik_url/"\E}, "Found url on piwik view";
like piwik_view(%args), qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E},
  "Found id on piwik view";
like piwik_view(%args), qr{A sku.*My desc.*first.*second.*1\.2}s, "Product ok";


like piwik_cart(%args), qr{\Q//$piwik_url/"\E}, "Found url on piwik cart";
like piwik_cart(%args), qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E},
  "Found id on piwik cart";

like piwik_order(%args), qr{\Q//$piwik_url/"\E}, "Found url on piwik order";
like piwik_order(%args), qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E},
  "Found id on piwik order";

done_testing;




