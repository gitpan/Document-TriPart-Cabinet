#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use Document::TriPart::Cabinet;
use Document::TriPart::Cabinet::Storage::Disk;
use Directory::Scratch;

my ($scratch, $document, $uuid, $cabinet);

$scratch = Directory::Scratch->new;
$cabinet = Document::TriPart::Cabinet->new( storage => Document::TriPart::Cabinet::Storage::Disk->new( dir => $scratch->base ) ); # Ugh, this feels like Java

ok( $cabinet );
ok( $document = $cabinet->create );
ok( $uuid = $document->uuid );

$document->edit( \<<_END_ );
title: Xyzzy
abstract: apple
---
The quick brown fox
_END_

cmp_deeply( $document->header, superhashof { title => "Xyzzy", abstract => "apple" } );
is( $document->body, <<_END_ );
The quick brown fox
_END_
ok( $document->creation );
# ok( ! $document->modification );

$document = $cabinet->load( $uuid );

cmp_deeply( $document->header, superhashof { title => "Xyzzy", abstract => "apple" } );

$document->edit( \<<_END_ );
title: Xyzzy
abstract: banana
summary: cherry
---
The quick brown fox jumped over the lazy dog
_END_

cmp_deeply( $document->header, superhashof { title => "Xyzzy", abstract => "banana", summary => "cherry" } );
is( $document->body, <<_END_ );
The quick brown fox jumped over the lazy dog
_END_
ok( $document->creation );
ok( $document->modification );
