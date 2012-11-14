#!/usr/bin/perl 
use Mojolicious::Lite;
use DBI;
use Data::Dumper;
#use Mojolicious::Plugin::Mongodb;

my $dbfile	= 	"./demo.db";
my $db		=	DBI->connect("dbi:SQLite:dbname=$dbfile", undef, undef);

get "/" => "index";

any "/search" => sub {
	my $self = shift;
	my $search = $self->param("search");
	my $strquery = "select id, title from ads" . ($search ? " where title like '%$search%'" : "");
	app->log->debug($strquery);
	my $query = $db->prepare($strquery);
	$query->execute;
	my @ads;
	my $line;
	push(@ads, $line) while $line = $query->fetchrow_hashref; 
	app->log->debug(Dumper(\@ads));
	$self->render_json({list => \@ads});
};

get "/ad/:id" => sub {
	my $self = shift;
	my $id = $self->param("id");
	my $strquery = "select * from ads where id = ?";
	app->log->debug($strquery);
	my $query = $db->prepare($strquery);
	$query->execute($id);
	$self->render_json($query->fetchrow_hashref);
	$query->finish;
};

put "/ad" => sub {
	my $self = shift;
	my $strquery = "insert into ads(title, body, price) values(?, ?, ?)";
	app->log->debug($strquery);
	my $query = $db->prepare($strquery);
	$query->execute($self->param("title"), $self->param("body"), $self->param("price"));
	$self->redirect_to("search");
	#my $strquery = "select id, title from ads";
	#app->log->debug($strquery);
	#$query = $db->prepare($strquery);
	#$query->execute;
	#my @ads;
	#my $line;
	#push(@ads, $line) while $line = $query->fetchrow_hashref; 
	#app->log->debug(Dumper(\@ads));
	#$self->render_json({list => \@ads});
};

app->start;

__DATA__

@@ index.html.ep
<html>
	<head>
	</head>
	<body>
		<a href="#" onclick='Template.renderOn("newad.jstmpl", {"title":"","body":"","price":""}, "result"); return false'>Create an Ad</a>
		<script src="JSTemplate/Template.js"></script>
		<form onsubmit="Template.renderOn('list.jstmpl', ['POST /search', this], 'result'); return false">
			<input name="search">
			<input type="submit" value="OK">
		</form>
		<div id="result">
		</div>
	</body>
</html>
