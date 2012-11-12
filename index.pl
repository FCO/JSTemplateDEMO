#!/usr/bin/perl 
use Mojolicious::Lite;
#use Mojolicious::Plugin::Mongodb;

get "/" => "index";

post "/search" => sub {
	my $self = shift;
	my $search = $self->param("search") || "search";
	$self->render_json({list => [{name => "${search}1"}, {name => "${search}2"}, {name => "${search}3"}]});
};

app->start;

__DATA__

@@ index.html.ep
<html>
	<head>
	</head>
	<body>
		<script src="JSTemplate/Template.js"></script>
		<form onsubmit="Template.renderOn('list.jstmpl', ['POST /search', this], 'result'); return false">
			<input name="search">
			<input type="submit" value="OK">
		</form>
		<div id="result">
		</div>
	</body>
</html>
