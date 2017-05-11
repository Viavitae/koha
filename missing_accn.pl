#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright Paul Poulain 2002
# Parts Copyright Liblime 2007
# Copyright (C) 2013  Mark Tompsett
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::NewsChannels; # GetNewsToDisplay
use C4::Suggestions qw/CountSuggestion/;
use C4::Tags qw/get_count_by_tag_status/;
use Koha::Patron::Modifications;
use Koha::Patron::Discharge;
use Koha::Reviews;
use Koha::ArticleRequests;
use Data::Dumper;
#use Vvscustom::Missing_accn;
my $query = new CGI;
my $acc_from = $query->param('accfrom');
my $acc_to = $query->param('accto');



my @data;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "vvscustom/missing_accn.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1, },
    }
);

my $driver = "mysql"; 
my $database = "koha_library";
my $dsn = "DBI:$driver:database=$database";
my $userid = "root";
my $password = "mysqlroot";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;
my @acc;

sub accn_no{
my $sth = $dbh->prepare("SELECT barcode from items");
$sth->execute() or die $DBI::errstr;

while (my @row = $sth->fetchrow_array()) {
  my ($barcode ) = @row;   

push(@acc, $barcode);
}
return @acc;
$sth->finish();
}
@data=accn_no();
##############################
my @list1 = ($acc_from..$acc_to);
my @list2 = @data;
my %diff;
@diff{ @data }= ();

my @missing=grep !exists($diff{$_}), @list1;;

#############################


$template->param( 
	acc_from => $acc_from,
	acc_to => $acc_to,
	missing => \@missing
);

output_html_with_http_headers $query, $cookie, $template->output;
