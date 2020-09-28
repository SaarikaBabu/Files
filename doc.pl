use strict;
use warnings;
use WWW::Mechanize;
use LWP::UserAgent;
use Kubera::Kubera qw(error_msg_clean_up);
my ($c, $response, $count, $AUTOUPDATESITE, $AUTOUPDATEIO, $AUTOUPDATEHTTP);
my $OUTPUTFILENAME = '';
my $mech = WWW::Mechanize->new();

sub main {
    debug_print ("Inside main");
    debug_print ("Getting moneycontrol page");
    mechGet("https://www.moneycontrol.com/india/stockpricequote/diversified/3mindia/MI42");
    my $table = '';
	if ( $c =~ /pivot\s+levels.*?<tbody>(.*?)<\/table>/is ) { #Matching the table with regex 
		$table = $1; #If the regex matches table will be stored in $1
		print $table."\n"; #printing the content table
	} else {
		print "Table not found"; #Prints this msg if $c is does not match with the regex.
	}

    my @rows = $table =~ /<tr.*?>(.*?)<\/tr>/gis; #Matching the rows with the regex from the table 
	my $values;
    for( my $i = 0; $i < scalar(@rows); $i++) { #Getting all the rows from the table using array foreach loop
		next if ($rows[$i] =~ /Type.*?R1.*?R2.*?R3.*?PP.*?S1.*?S2.*?S3/is);
        my @cols = $rows[$i] =~ /<td.*?>\s*(.*?)\s*<\/td>/gis; #Matching all the columns with the each rows from the table using regex (.*?)-> will capture the values or contents between start and end tags[dot(.) denotes alphabet, Number, Space and Character/ * denotes 0,1/ ? denotes optional]
		my $Type = clean_up($cols[0]);
		my $R1 = clean_up($cols[1]);
		my $R2 = clean_up($cols[2]);
		my $R3 = clean_up($cols[3]);
		my $PP = clean_up($cols[4]);
		my $S1 = clean_up($cols[5]);
		my $S2 = clean_up($cols[6]);
		my $S3 = clean_up($cols[7]);
		$values .= $Type.",".$R1.",".$R2.",".$R3.",".$PP.",".$S1.",".$S2.",".$S3."\n";
    }
	print "$values\n"; 
}
sub mechGet {
    my ($link) = @_;
    debug_print("Getting URL $link");
    $response = $mech->get($link);#here we are hitting one page and taking the content into var $response
    get_response_content();#calling function
    #so overall $content here have the latest html content in it and $content will be override every time whenever the function calls
}

sub dump_file {
    my $filename = $OUTPUTFILENAME . $count . "Output.html";#will dump file with html count in current dir eg output1.html,output2.html
    open( OUTFILE, ">$filename" ) or print_error( $AUTOUPDATEIO, "Can't open $filename: $!" , 1);
    binmode(OUTFILE);
    print OUTFILE $c;
    close OUTFILE;
    debug_print("Response dumped in file $filename");
}

sub clean_up {
	my $text = shift;
	$text =~ s/<.*?>//gis;
	return $text;
}

sub get_response_content { 
    $c = $response->decoded_content();#After the response we get from $mech->get
    #decoded_content is inbuild function and used to decode the content get from the mechget (we are doing bcoz the content currently in encoded format hence we do decode and store in $content which is the html content)
    $c = $response->content() if(length($c) == 0);#if it is not in encoded format then we directly take the content (html) in var content
    my $ct = $mech->ct;#content type =>html, pdf , csv , zip etc
    my $k_status_line = $response->status_line;# status pf the response if it is 200 that means it may be  correct reposne , can be 400 0r 500 in case of error
    my $k_url_base = $response->base;# base url 
    debug_print("Status Line: $k_status_line");
    debug_print("Content Type: $ct");
    debug_print("Base: $k_url_base");
    $response->is_info ? debug_print("is_info: yes") : debug_print("is_info: no");
    $response->is_success ? debug_print("is_success: yes") : debug_print("is_success: no");
    $response->is_redirect ? debug_print("is_redirect: yes") : debug_print("is_redirect: no");
    $response->is_error ? debug_print("is_error: yes") : debug_print("is_error: no");
    dump_file($c, $OUTPUTFILENAME, "html");#function use to dump file in current directroy
    $count++;

	if($response->is_error) {
		print_error($AUTOUPDATEHTTP, "Unable to fetch url#. Status: " . $k_status_line, 1);#simple check of error status of response
	}
}

sub debug_print {
    my $msg = shift;
    print "KFetcher $msg \n";
}

sub print_error {
    my ($err_type, $message, $fatal, $ERROR) = @_;
    debug_print("Error is $err_type and message is $message and fatal is $fatal");
    if($err_type =~ /SITE/is ) {
        $err_type  = $AUTOUPDATESITE;
        $message = 'Bank website is down. Please try after sometime';
    }
    print $ERROR. " $err_type $message\n";
}


