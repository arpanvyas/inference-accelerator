#!/usr/bin/perl
#use strict;
#use warnings;
use Spreadsheet::Read;

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

 
# OO API
my $book = Spreadsheet::Read->new ("register_set.ods");
my $sheet_num = 2;
my $sheet = $book->sheet ($sheet_num);

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

push @inout, 'module regfile_general_config (',"\n";
push @inout,pad("clk,"), pad("rst,");



#Read Verilog Case Statement


push @veristart,pad("//REGISTER DECLARATIONS",0);
foreach my $reg_addr (sort keys %$db) {
    my $reg = $db->{$reg_addr};
    my $reg_name = $reg->{"name"};
    push @veristart, pad("reg\t[15:0]\t$reg_name;");
}
push @veristart,"\n";

push @veristart, pad("//READ REGISTER",0);
push @veristart, pad('always@(*)',0);
push @veristart, pad('begin',0);
push @veristart, pad('case (addr)');
foreach my $reg_addr (sort keys %$db) {
    my $reg = $db->{$reg_addr};
    my $reg_name = $reg->{"name"};
    my $reg_addr = num2veri($reg->{"address"},16);
    push @veristart, pad("$reg_addr : read_data = $reg_name;",2);
}
push @veristart, pad("default : read_data = 16'h0;",2);
push @veristart, pad("endcase");
push @veristart, pad('end',0);


foreach my $reg_addr (sort keys %$db) {
    my $reg = $db->{$reg_addr};
    my $regname = $reg->{"name"},"\n";
    
    my @verideclr;
    my @verirw;
    my @veriro;
    my @veriwoc;
    my @veriroc;

    my @veriassign;
    my @veriassign_a1;
    my @veriassign_a2;
    my @veriassign_b1;
    my @veriassign_b2;

    push @inout, "\n\t//$regname\n";
    push @verideclr, pad("//$regname");

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
                push @inout, pad("output\treg\t[$fieldsiz:0]\t$fieldname,");
            } else {
                push @inout, pad("output\treg\t\t$fieldname,");
            }
        } elsif ( $accesstype eq "RO" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("input\twire\t[$fieldsiz:0]\t$fieldname,");
            } else {
                push @inout, pad("input\twire\t\t$fieldname,");
            }
        } elsif ( $accesstype eq "ROC" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("input\twire\t[$fieldsiz:0]\t$fieldname"."_wr,");
            } else {
                push @inout, pad("input\twire\t\t$fieldname"."_wr,");
            }   
            push @inout, pad("input\twire\t$fieldname"."_wr_en,");
        } elsif ( $accesstype eq "WOC" ) {
            if($fieldsiz  > 1) {
                push @inout, pad("output\treg\t[$fieldsiz:0]\t$fieldname"."_wr,");
            } else {
                push @inout, pad("output\treg\t\t$fieldname"."_wr,");
            }   
            push @inout, pad("input\twire\t\t$fieldname"."_wr_en,");
        } else {

            die "ACCESSTYPE not valid for $fieldname";
        }        



        my $addit = $fieldsiz+$startbit;
        if( $accesstype eq "RW" ) {
            unshift  @veriassign_a2 , "$regname"."[$addit:$startbit],";
            unshift  @veriassign_a1 , "$fieldname".",";
       
        } else {
            if($accesstype eq "WOC") {
                unshift @veriassign_b2, num2veri($default,$fieldsize),",";
                unshift @veriassign_b1 , "$regname"."[$addit:$startbit],";

            } else {
                unshift @veriassign_b2 , "$fieldname,";
                unshift @veriassign_b1 , "$regname"."[$addit:$startbit],";
            }
        }

    }

    #REMOVE COMMAS FROM THE END
    my $last = pop @veriassign_a1;
    $last =~ s/^(.*),/$1/;
    push @veriassign_a1, $last;

    my $last = pop @veriassign_a2;
    $last =~ s/^(.*),/$1/;
    push @veriassign_a2, $last;

    my $last = pop @veriassign_b1;
    $last =~ s/^(.*),/$1/;
    push @veriassign_b1, $last;

    my $last = pop @veriassign_b2;
    $last =~ s/^(.*),/$1/;
    push @veriassign_b2, $last;

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

    push @veriassign, @veriassign_a1,@veriassign_a2,@veriassign_b1,@veriassign_b2;




    push @vericode, @verideclr, @veriassign, @verirw, @veriro, @veriwoc, @veriroc;

    }
    


#CLOSE INOUT
my $last_one = pop @inout;
$last_one =~ s/^(.*),$/$1/;
push @inout,$last_one, "\t);\n\n";
push @Inout, "\n\n";

#CLOSE MODULE
push @veriend, pad("\n\nendmodule",0);


print @inout;
print @veristart;
print @vericode;
print @veriend;

print "\n";
