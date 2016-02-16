use Mojolicious::Lite;
use Mojo::JSON qw(decode_json encode_json);

use FindBin;
use File::Slurp;

my $config_file = read_file("$FindBin::Bin/etc/config.json");
my $cfg = decode_json( $config_file );

app->config(
	hypnotoad => {
		listen => ['http://*:8080'],
		proxy  => 1
	}
);

helper rcon => sub {
	my ($self, $cmd) = @_;
	# TODO implement rcon in perl instead of using this C program
	return `$FindBin::Bin/bin/rcon -P$cfg->{password} -a$cfg->{host} -p$cfg->{port} $cmd`;
};

get '/api/listplayers' => sub {
	my ($self) = @_;

	my $rcon_response = $self->rcon("listplayers");
	my @players;

	foreach my $line ( $rcon_response =~ /\n\d+\.\s+(.+)/g ) {
		my ( $character_name, $steam_id ) = split( /,\s+/, $line );

		push( @players, {
			character_name => $character_name,
			steam_id       => $steam_id
		});
	};

	return $self->render(
		json => {
			players => \@players,
		}
	);
};

app->start;
