#!perl

use strict;
use warnings;
use utf8;
use Test::More tests => 28;

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

use Dancer ':tests';
use Dancer::Plugin::Piwik;
use Dancer::Test;
use Data::Dumper;

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
ok !$@, "No exception for missing category";

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


%args = (
         subtotal => 200,
         cart => [
                  {
                   sku => '1234',
                   description => 'A shoe',
                   categories => [
                                  'sport shoes',
                                 ],
                   price => 100,
                   quantity => 2,
                  }
                 ],
        );

like piwik_cart(%args), qr{\Q//$piwik_url/"\E}, "Found url on piwik cart";
like piwik_cart(%args), qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E},
  "Found id on piwik cart";
like piwik_cart(%args), qr{addEcommerceItem.*1234.*A shoe.*sport shoes.*100.*2}s,
  "Cart seems ok";


delete $args{subtotal};

$args{order} = {
                order_number => '12341234',
                total_cost => 100,
                subtotal => 200,
                shipping => 15,
               };

like piwik_order(%args), qr{\Q//$piwik_url/"\E}, "Found url on piwik order";
like piwik_order(%args), qr{\Q//$piwik_url/piwik.php?idsite=$piwik_id"\E},
  "Found id on piwik order";

like piwik_order(%args), qr{addEcommerceItem.*1234.*A shoe.*sport shoes.*100.*2}s,
  "Cart seems ok";
like piwik_order(%args),
  qr{trackEcommerceOrder.*12341234.*100.*200.*false.*15.*false}s,
  "Orders appear good";


set plugins => {
                'Piwik' => {
                            id => '',
                            url => '',
                           }
               };

is piwik, '', "No output";
is_deeply piwik(ajax => 1), {}, "ajax: empty hash";

is piwik_category(category => 'Test'), '';
is_deeply piwik_category(ajax => 1, category => 'Test'), {}, "ajax: empty hash";

%args = (
         product => {
                     sku => 'A sku',
                     description => 'My desc',
                     categories => [qw/first second/],
                     price => 1.20,
                    },
        );

is piwik_view(%args), '';
is_deeply piwik_view(%args, ajax => 1), {};

%args = (
         subtotal => 200,
         cart => [
                  {
                   sku => '1234',
                   description => 'A shoe',
                   categories => [
                                  'sport shoes',
                                 ],
                   price => 100,
                   quantity => 2,
                  }
                 ],
        );

is piwik_cart(%args), '';
is_deeply piwik_cart(%args, ajax => 1), {};

delete $args{subtotal};

$args{order} = {
                order_number => '12341234',
                total_cost => 100,
                subtotal => 200,
                shipping => 15,
               };

read_logs;

is piwik_order(%args), '';

is_deeply piwik_order(%args, ajax => 1), {};

my $errors = read_logs;

is_deeply($errors,
          [
           {
            'message' => 'Missing url and id for Piwiki, plugin is disabled',
            'level' => 'warning'
           },
           {
            'message' => 'Missing url and id for Piwiki, plugin is disabled',
            'level' => 'warning'
           }
          ], "Found errors in the logs when plugin is disabled");

