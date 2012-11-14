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
	my $min = $self->param("min");
	my $max = $self->param("max");
	my $where;
	$where .= "title like '%$search%'" if $search;
	$where .= "price >= ?" if $min;
	$where .= "price <= ?" if $max;
	my $strquery = "select id, title from ads" . ($where ? " where $where" : "");
	app->log->debug($strquery);
	my $query = $db->prepare($strquery);
	$query->execute(grep {$_} $min, $max);
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
};

post "/ad/:id" => sub {
	my $self = shift;
	my $id   = $self->param("id");
	my $strquery = "update ads set title=?, body=?, price=? where id = ?";
	app->log->debug($strquery);
	my $query = $db->prepare($strquery);
	$query->execute($self->param("title"), $self->param("body"), $self->param("price"), $id);
	$self->redirect_to("search");
};

del "/ad/:id" => sub {
	my $self = shift;
	my $id   = $self->param("id");
	my $strquery = "delete from ads where id = ?";
	app->log->debug($strquery);
	my $query = $db->prepare($strquery);
	$query->execute($id);
	$self->redirect_to("search");
};

app->start;

__DATA__

@@ index.html.ep
<html>
	<head>
	</head>
	<body onload="Template.renderOn('list.jstmpl', 'POST /search', 'result')">
		<a href="#" onclick='Template.stash.url = "PUT /ad"; Template.renderOn("newad.jstmpl", {"title":"","body":"","price":""}, "result"); return false'>Create an Ad</a>
		<script src="JSTemplate/Template.js"></script>
		<form onsubmit="Template.renderOn('list.jstmpl', ['POST /search', this], 'result'); return false">
			<table border=1>
				<tr>
					<th>Search</th>
				</tr>
				<tr>
					<td>Title:</td>
					<td><input id="search" name="search"></td>
				</tr>
				<tr>
					<th>Price:</th>
				</tr>
				<tr>
					<td><label for="min">Min:</label></td>
					<td><input id="min" name="min"></td>
				</tr>
				<tr>
					<td><label for="max">Max:</label></td>
					<td><input id="max" name="max"></td>
				</tr>
				<tr>
					<td colspan=2><input type="submit" value="OK"></td>
				</tr>
			</table>
		</form>
		<div id="result">
		</div>
	</body>
</html>
