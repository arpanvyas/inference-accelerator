#!/usr/bin/perl


##################################################################################################
#Usage: ./xls_to_regfile.pl <XLS_FILE> <SHEET_NUMBER1> <SHEET_NUMBER2> ... \n";
##################################################################################################

#use strict;
#use warnings;
use Spreadsheet::Read;




my $xls_file = $ARGV[0];


for(my $idx_sheet = 1; $idx_sheet <= $#ARGV; $idx_sheet = $idx_sheet + 1) {  


my $sheet_num = $ARGV[$idx_sheet];

if($sheet_num !~ /^\d+$/) {
    die "Argument: ".$sheet_num." at index: ". $idx_sheet." is not a number";
}


#some useful functions
sub pad {
    my ($arg, $tabs, $crs) = @_;
    if ($arg eq "") { $arg = " "; }
    if($tabs eq "") { $tabs = 1; }
    if($crs eq "" ) { $crs = 1; }
    my $tab_space = "\t"x$tabs;
    my $cr_space = "\n"x$crs;
    return "$tab_space"."$arg"."$cr_space";
}

sub num2veri {
    my ($arg, $bits ) = @_;
    $arg =~ s/^0x0*//;
    return "$bits"."'h"."$arg";
}


sub comma_end {

    @arg1 = @_;

    my $last = pop @arg1;
    $last =~ s/^(.*),/$1/;
    push @arg1, $last;
    return @arg1;
}


#Constants
my $r_name = 2;
my $addr = 3;
my $f_name = 4;
my $access = 5;
my $f_size = 6;
my $s_bit = 7;
my $def = 8;
my $descr = 9;
my $rmrk = 10;

my $addr_len = 14;
my $addr_l = $addr_len - 1;

 
# OO API

my $book = Spreadsheet::Read->new ($xls_file);
my $sheet = $book->sheet ($sheet_num);
my $sheet_label = $sheet->{"label"};
$sheet_label =~ s/(.*)/lc($1)/ge;
$sheet_label =~ s/ /_/;
$sheet_label_uc = $sheet_label;
$sheet_label_uc =~ s/(.*)/uc($1)/ge;
my $module_name = "regfile_"."$sheet_label";

my $maxrow = $book->[$sheet_num]{"maxrow"};
my $value;
my $regname;
my $fieldname;
my $accesstype;
my $fieldsize;
my $startbit;
my $default;
my $description;
my $remark;


my $db = {};
my $row = 1;
while($row <= $maxrow) {
    if($sheet->{cell}[1][$row] eq '//') {
        $row++;
    } else {
        $regname =  $sheet->{cell}[$r_name][$row];
        $address =  $sheet->{cell}[$addr][$row];
        

        $address = $sheet->{cell}[$addr][$row];
        $db->{$address}{"name"} = $regname;
        $db->{$address}{"address"} = $address;
        $db->{$address}{"fields"} = {};

        while($sheet->{cell}[$addr][$row] eq $address) {
            $startbit = $sheet->{cell}[$s_bit][$row];
            $fieldname = $sheet->{cell}[$f_name][$row];
            $accesstype = $sheet->{cell}[$access][$row];
            $fieldsize = $sheet->{cell}[$f_size][$row];
            $default = $sheet->{cell}[$def][$row];
            $description = $sheet->{cell}[$descr][$row];
            $remark = $sheet->{cell}[$rmrk][$row];
            #print "$regname, $startbit, $fieldname, $accesstype, $fieldsize, $default\n";
            
            $db->{$address}{"fields"}{$startbit} = {"fieldname" => "$regname"."__"."$fieldname", "startbit" => $startbit, "accesstype" => $accesstype, "fieldsize" => $fieldsize, "default" => $default, "description" => $description, "remark" => $remark};
            $row++;

        }
        #print "$value => $regname \n"; 
    }

}

#print $db->{"0x0007"}{"fields"}{3}{"description"},"\n";

my @inout;
my @veristart;
my @vericode;
my @veriend;

my $read_data = "read_data_"."$sheet_label_uc";

push @inout, "module $module_name (","\n";
push @inout,pad("input\tlogic\t\tclk,"), pad("input\tlogic\t\trst,");
push @inout, pad("input\tlogic\t\twr_en,"),pad("input\tlogic\t\trd_en,");
push @inout, pad("input\tlogic\t[$addr_l:0]\taddr,");
push @inout, pad("input\tlogic\t[15:0]\twrite_data,");
push @inout, pad("output\tlogic\t[15:0]\t$read_data,");



#Read Verilog Case Statement


push @veristart,pad("//DECLARATIONS",0);
foreach my $reg_addr (sort keys %$db) {
    my $reg = $db->{$reg_addr};
    my $reg_name = $reg->{"name"};
    push @veristart, pad("logic\t[15:0]\t$reg_name;",0);
}
push @veristart,"\n";

push @veristart, pad("//READ REGISTER",0);
push @veristart, pad('always@(*)',0);
push @veristart, pad('begin',0);
push @veristart, pad('case (addr)',1);
foreach my $reg_addr (sort keys %$db) {
    my $reg = $db->{$reg_addr};
    my $reg_name = $reg->{"name"};
    my $reg_addr = num2veri($reg->{"address"},$addr_len);
    push @veristart, pad("$reg_addr : $read_data = $reg_name;",2);
}
push @veristart, pad("default : $read_data = 16'h0;",2);
push @veristart, pad("endcase",1);
push @veristart, pad('end',0),"\n\n";

#push @veristart, pad("//READ REGISTER",0);
#push @veristart, pad('always@(posedge clk, posedge rst)',0);
#push @veristart, pad('begin',0), pad('if(rst) begin',1), pad("$read_data <= #1 16'h0;",2);
#push @veristart, pad('end else begin');
#push @veristart, pad('if(rd_en) begin',2);
#push @veristart, pad('case (addr)',3);
#foreach my $reg_addr (sort keys %$db) {
#    my $reg = $db->{$reg_addr};
#    my $reg_name = $reg->{"name"};
#    my $reg_addr = num2veri($reg->{"address"},$addr_len);
#    push @veristart, pad("$reg_addr : $read_data <= #1 $reg_name;",4);
#}
#push @veristart, pad("default : $read_data <= #1 16'h0;",4);
#push @veristart, pad("endcase",3);
#push @veristart, pad('end',2), pad('end',1), pad('end',0),"\n\n";


foreach my $reg_addr (sort keys %$db) {
    my $reg = $db->{$reg_addr};
    my $regname = $reg->{"name"},"\n";
    
    my @verideclr;
    my @verirw;
    my @verirw_1;
    my @verirw_2;
    my @verirw_3;
    my @verirw_a;#in reset
    my @verirw_b;#after reset

    my @veriro;
    my @veriro_1;
    my @veriro_2;
    my @veriro_3;
    my @veriro_4;

    my @veriwoc;
    my @veriwoc_1;
    my @veriwoc_2;
    my @veriwoc_3;
    my @veriwoc_4;

    my @veriroc;
    my @veriroc_1;
    my @veriroc_2;
    my @veriroc_3;
    my @veriroc_4;

    my @veriassign;
    my @veriassign_a1;
    my @veriassign_a2;
    my @veriassign_b1;
    my @veriassign_b2;

    push @inout, "\n\t//$regname\n";
    push @verideclr, pad("//REGISTER $regname",0);

    $reg_fields = $reg->{"fields"};

    foreach my $start_bit (sort keys %$reg_fields) {
        my $reg_field = $reg_fields->{$start_bit};
        $startbit = $reg_field->{"startbit"};
        $fieldname = $reg_field -> {"fieldname"};
        $accesstype = $reg_field -> {"accesstype"};
        $fieldsize = $reg_field -> {"fieldsize"};
        $fieldsiz = $fieldsize - 1;
        $default = $reg_field -> {"default"};
        $description = $reg_field -> {"description"};
        #print "$reg_name, $startbit, $fieldname, $accesstype, $fieldsize, $default\n";
        if( $accesstype eq "RW" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("output\tlogic\t[$fieldsiz:0]\t$fieldname,");
            } else {
                push @inout, pad("output\tlogic\t\t$fieldname,");
            }
        } elsif ( $accesstype eq "RO" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("input\tlogic\t[$fieldsiz:0]\t$fieldname,");
            } else {
                push @inout, pad("input\tlogic\t\t$fieldname,");
            }
        } elsif ( $accesstype eq "ROC" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("input\tlogic\t\t[$fieldsiz:0]\t$fieldname"."_wr,");
            } else {
                push @inout, pad("input\tlogic\t\t$fieldname"."_wr,");
            }   
            push @inout, pad("input\tlogic\t\t$fieldname"."_wr_en,");
        } elsif ( $accesstype eq "WOC" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("output\tlogic\t[$fieldsiz:0]\t$fieldname"."_wr,");
            } else {
                push @inout, pad("output\tlogic\t\t\t$fieldname"."_wr,");
            }   
            push @inout, pad("output\tlogic\t\t\t$fieldname"."_wr_en,");
        } else {

            die "ACCESSTYPE not valid for $fieldname";
        }        



        my $addit = $fieldsiz+$startbit;
        if( $accesstype eq "RW" ) {
            unshift  @veriassign_a2 , "$regname"."[$addit:$startbit],";
            unshift  @veriassign_a1 , "$fieldname".",";

            unshift  @verirw_1, "$regname"."[$addit:$startbit],";
            unshift  @verirw_2, "$fieldsize"."'h$default".",";
            unshift  @verirw_3, "write_data"."[$addit:$startbit],";

        } else {
            if($accesstype eq "WOC") {
                unshift @veriassign_b2, num2veri($default,$fieldsize),",";
                unshift @veriassign_b1 , "$regname"."[$addit:$startbit],";
                push @veriwoc_1, pad("$fieldname"."_wr <= #1 "."$fieldsize"."'h$default;",2);
                push @veriwoc_1, pad("$fieldname"."_wr_en <= #1 0;",2);
                push @veriwoc_2, pad("$fieldname"."_wr <= #1 write_data"."[$addit:$startbit];",3);
                push @veriwoc_2, pad("$fieldname"."_wr_en <= #1 1;",3);
                push @veriwoc_3, pad("$fieldname"."_wr <= #1 "."$fieldsize"."'h$default;",2);
                push @veriwoc_3, pad("$fieldname"."_wr_en <= #1 0;",2);

            } else {
                unshift @veriassign_b2 , "$fieldname,";
                unshift @veriassign_b1 , "$regname"."[$addit:$startbit],";

                if( $accesstype eq "ROC" ) {
                    push @veriroc_1, pad("$fieldname <= #1 "."$fieldsize"."'h$default;",2);
                    push @veriroc_2, pad("$fieldname <= #1 "."$fieldsize"."'h$default;",3);
                    push @veriroc_3, pad("if($fieldname"."_wr_en) begin",3);
                    push @veriroc_3, pad("$fieldname <= #1 $fieldname"."_wr;",4);
                    push @veriroc_3, pad("end",3);
                    
                    
                push @verideclr, pad("logic\t[$fieldsiz:0]\t$fieldname;",0);
                }
            }
        }


    }

    #REMOVE COMMAS FROM THE END
    @veriassign_a1 = comma_end(@veriassign_a1);
    @veriassign_a2 = comma_end(@veriassign_a2);
    @veriassign_b1 = comma_end(@veriassign_b1);
    @veriassign_b2 = comma_end(@veriassign_b2);
    
    @verirw_1 = comma_end(@verirw_1);
    @verirw_2 = comma_end(@verirw_2);
    @verirw_3 = comma_end(@verirw_3);

    my @verirw_a1 = @veriassign_a2;
    #PUT ASSIGNS, EQUALS AND SEMICOLONS
    if( @veriassign_a1[0] ne "" ) {
        unshift @veriassign_a1, "assign\t{";
        push @veriassign_a1, " }\t=\t";
        unshift @veriassign_a2, "{ ";
        push @veriassign_a2, " };\n";
    }

    if( @veriassign_b1[0] ne "" ) {
        unshift @veriassign_b1, "assign\t{";
        push @veriassign_b1, " }\t=\t";
        unshift @veriassign_b2, "{ ";
        push @veriassign_b2, " };\n";
    }

    #print @verirw_1,"\n";
    #print @verirw_2,"\n";
    #print @verirw_3,"\n";
    if ( @verirw_1[0] ne "" ) {
        push  @verirw_a, "{ ",@verirw_1," } <= #1 { ", @verirw_2, " };\n";
        push  @verirw_b, "{ ",@verirw_1," } <= #1 { ", @verirw_3, " };\n";
        push @verirw, pad("//RW fields",0);
        push @verirw, pad("always@(posedge clk, posedge rst) begin",0);
        push @verirw, pad("if (rst) begin",1);
        push @verirw, "\t\t",@verirw_a,pad("end else begin",1);
        push @verirw, pad("if (wr_en && addr == ".num2veri($reg_addr,$addr_len).") begin",2);
        push @verirw, "\t\t\t",@verirw_b;
        push @verirw, pad("end",2);
        push @verirw,pad("end",1),pad("end",0);
        #print @verirw;
    }
    
    if( @veriwoc_1[0] ne "" ) {
        push @veriwoc, pad("//WOC fields",0);
        push @veriwoc, pad("always@(posedge clk, posedge rst) begin",0);
        push @veriwoc, pad("if (rst) begin",1);
        push @veriwoc, @veriwoc_1;
        push @veriwoc, pad("end else begin",1);
        push @veriwoc, pad("if (wr_en && addr == ".num2veri($reg_addr,$addr_len).") begin",2);
        push @veriwoc, @veriwoc_2;
        push @veriwoc, pad("end else begin",2);
        push @veriwoc, @veriwoc_3;
        push @veriwoc, pad("end",2), pad("end",1),pad("end",0);
    }

    if (@veriroc_1[0] ne "" ) {
        push @veriroc, pad("//ROC fields",0);
        push @veriroc, pad("always@(posedge clk, posedge rst) begin",0);
        push @veriroc, pad("if (rst) begin",1);
        push @veriroc, @veriroc_1;
        push @veriroc, pad("end else begin",1);
        push @veriroc, pad("if (rd_en && addr == ".num2veri($reg_addr,$addr_len).") begin",2);
        push @veriroc, @veriroc_2;
        push @veriroc, pad("end else begin",2);
        push @veriroc, @veriroc_3;
        push @veriroc, pad("end",2), pad("end",1),pad("end",0);

    }
    #print @veriroc;




    push @veriassign, @veriassign_a1,@veriassign_a2,@veriassign_b1,@veriassign_b2;




    #RW fields



    push @vericode, @verideclr, @veriassign, @verirw, @veriro, @veriwoc, @veriroc,"\n\n\n\n\n";
    #push @vericode, @verideclr, @verirw, @veriro, @veriwoc, @veriroc,"\n\n\n\n\n";
    #push @vericode, @verideclr, @veriassign, @veriro, @veriwoc, @veriroc,"\n\n\n\n\n";
    #push @vericode, @verideclr, @veriassign, @verirw, @veriwoc, @veriroc,"\n\n\n\n\n";
    #push @vericode, @verideclr, @veriassign, @verirw, @veriro, @veriroc,"\n\n\n\n\n";
    #push @vericode, @verideclr, @veriassign, @verirw, @veriro, @veriwoc, "\n\n\n\n\n";

    }
    


#CLOSE INOUT
my $last_one = pop @inout;
$last_one =~ s/^(.*),$/$1/;
push @inout,$last_one, "\t);\n\n";
push @Inout, "\n\n";

#CLOSE MODULE
push @veriend, pad("\n\nendmodule",0);


#print @inout;
#print @veristart;
#print @vericode;
#print @veriend;
#print "\n";

my @final;
push @final, @inout, @veristart, @vericode, @veriend, "\n";
my $filename = "$module_name".".sv";
open (FILE, "> $filename") || die "problem opening $filename\n"; 
print FILE @final;
close (FILE);

} #for each argument
