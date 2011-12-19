#!/usr/bin/perl

use HTTP::Proxy;
use HTTP::Proxy::BodyFilter::save;

my $proxy = HTTP::Proxy->new( port => 8080 );

$proxy->push_filter(
    mime => undef,
    response => HTTP::Proxy::BodyFilter::save->new(
        multiple => false
      )
  );

$proxy->start();

