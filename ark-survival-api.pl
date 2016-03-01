use Mojolicious::Lite;
use Mojo::JSON qw(decode_json encode_json);

use Net::RCON;
use FindBin;
use File::Slurp;

my $config_file = read_file("$FindBin::Bin/etc/config.json");
my $cfg = decode_json( $config_file );

my $rcon = Net::RCON->new({
	host     => $cfg->{host},
	port     => $cfg->{port},
	password => $cfg->{password}
}) or die;

app->config(
	hypnotoad => {
		listen => ['http://*:80'],
		proxy  => 1
	}
);

get '/api/listplayers' => sub {
	my ($self) = @_;

	my $rcon_response = $rcon->send("listplayers");
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
