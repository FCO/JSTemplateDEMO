#!/usr/bin/perl 
use Mojolicious::Lite;
#use Mojolicious::Plugin::Mongodb;

get "/" => "index";

post "/search" => sub {
	my $self = shift;
	$self->render_json({list => [{name => "test1"}, {name => "test2"}, {name => "test3"}]});
};

app->start;

__DATA__

@@ index.html.ep
<html>
	<head>
	</head>
	<body>
		<script src="JSTemplate/Template.js"></script>
		<form onsubmit="Template.renderOn('list.jstmpl', 'POST /search', 'result'); return false">
			<input name="search">
			<input type="submit" value="OK">
		</form>
		<div id="result">
		</div>
	</body>
</html>
