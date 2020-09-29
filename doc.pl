use strict;
use WWW::Mechanize;
use JSON;
use Data::Dumper;
use Kubera::Kubera qw(read_file);
use Kubera::KConstants;

my $mech = WWW::Mechanize->new();

my $url = "https://www.moneycontrol.com/india/stockpricequote/diversified/3mindia/MI42";
my ($c, $response, $count);

my $data = {};

main();
sleep(5);
exit(0);

sub main {
    debug_print ("Getting Money Control website");
    mechGet($url);

	debug_print("Scraping table from the website");
	scrape_table();

}

sub scrape_table {
    my $table;
	if ( $c =~ />Pivot\s+levels<.*?<tbody>(.*?)<\/tbody>/is ) { #Matching the table with regex 
		$table = $1; #If the regex matches table will be stored in $1
	} else {
		error_exit($AUTOUPDATEPAGE, "Table not found"); #Prints this msg if $c is does not match with the regex.
	}

    my @rows = $table =~ /<tr.*?>(.*?)<\/tr>/isg; #Matching the rows with the regex from the table 

	for my $row (@rows) {
		my @cols = $row =~ /<td.*?>\s*(.*?)\s*<\/td>/isg;#Matching the cols with each rows
    	my $Type = clean_up($cols[0]);
		my $R1 = $cols[1];
		my $R2 = $cols[2];
		my $R3 = $cols[3];
		my $PP = $cols[4];
		my $S1 = $cols[5];
		my $S2 = $cols[6];
		my $S3 = $cols[7];
		
		$data->{$Type}->{"R1"} = $R1;
		$data->{$Type}->{"R2"} = $R1;
		$data->{$Type}->{"R3"} = $R1;
		$data->{$Type}->{"PP"} = $PP;
		$data->{$Type}->{"S1"} = $S1;
		$data->{$Type}->{"S2"} = $S2;
		$data->{$Type}->{"S3"} = $S3;
	}
	print_data();
}

sub print_data {
	my $json = encode_json($data);
	print "JSON $json\n";
}

sub mechGet {
    my ($url) = @_;
    debug_print("Getting URL $url");
    $response = $mech->get($url);#here we are hitting one page and taking the content into var $response
    get_response_content();#calling function
    #so overall $content here have the latest html content in it and $content will be override every time whenever the function calls
}

sub clean_up {
	my $text = shift;
	$text =~ s/<.*?>//gis;
	return $text;
}

sub dump_file {
    my $filename = $OUTPUTFILENAME . $count . ".html";#will dump file with html count in current dir eg output1.html,output2.html
    open( OUTFILE, ">$filename" ) or error_exit ( $AUTOUPDATEIO, "Can't open $filename: $!" , 1);
    binmode(OUTFILE, ":utf8");
    print OUTFILE $c;
    close OUTFILE;
    debug_print("Response dumped in file $filename");
}

sub get_response_content { 
    $c = $response->decoded_content();#After the response we get from $mech->get
    #decoded_content is inbuild function and used to decode the content get from the mechget (we are doing bcoz the content currently in encoded format hence we do decode and store in $content which is the html content)
    $c = $response->content() if(length($c) == 0);#if it is not in encoded format then we directly take the content (html) in var content
    my $ct = $mech->ct;#content type =>html, pdf , csv , zip etc
    my $k_status_line = $response->status_line;# status of the response if it is 200 that means it may be  correct reposne , can be 400 0r 500 in case of error
    my $k_url_base = $response->base;# base url 
    debug_print("Status Line: $k_status_line");
    debug_print("Content Type: $ct");
    debug_print("Base: $k_url_base");
	$count++;
    $response->is_info ? debug_print("is_info: yes") : debug_print("is_info: no");
    $response->is_success ? debug_print("is_success: yes") : debug_print("is_success: no");
    $response->is_redirect ? debug_print("is_redirect: yes") : debug_print("is_redirect: no");
    $response->is_error ? debug_print("is_error: yes") : debug_print("is_error: no");
    dump_file($c, $OUTPUTFILENAME, "html");#function use to dump file in current directroy
    
	if($response->is_error) {
		error_exit($AUTOUPDATEHTTP, "Unable to fetch url#. Status: " . $k_status_line);#simple check of error status of response
	}
}

sub debug_print {
    my $msg = shift;
    print "KFetcher $msg \n";
}

sub error_exit {
    my ($err_type, $message) = @_;
    debug_print("Error is $err_type and message is $message");

    print " $err_type $message\n";
	exit(1);
}

