#!/usr/bin/perl

use HTTP::Proxy;
use HTTP::Proxy::BodyFilter::save;
use Encode qw(encode_utf8);
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $proxy = HTTP::Proxy->new( port => 8080 );

$proxy->push_filter(
    mime => undef,
    response => HTTP::Proxy::BodyFilter::save->new(
        multiple => 0,
        filename => sub()
        {
          my $message = shift;

          # retrieve URI
          my $uri = $message->request->uri;
          my @segs = $uri->path_segments;
          shift @segs; # first element is empty

          # retrieve query string
          my $query = $uri->query;
          $query = "?$query" if $query;

          # combine and encode
          my $path = File::Spec->catfile(@segs);
          $path = md5_hex(encode_utf8($path));

          # retrieve content type
          my $mime = $message->headers->header('Content-Type');
          $mime = 'application/octet-stream' unless $mime; # according to RFC2616
          # get only type, ignore subtype and parameter
          $mime = (split(/\//, $mime))[0];

          # retrieve second-level domain name
          my $host = join('.', (split(/\./, $uri->host))[-2..-1]);

          # combine all
          $path = File::Spec->catfile($host, $mime, $path);

          return $path;
        }
      )
  );

$proxy->start();

