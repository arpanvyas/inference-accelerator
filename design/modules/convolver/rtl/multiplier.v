`include "header.vh"
module multiplier(
    input	[`WID_LINE-1:0]		i1,
	 input	[`WID_FILTER-1:0]		i2,
	 input	[`WID_FILTER-1:0]		i3,
	 input	[`WID_FILTER-1:0]		i4,
	 input	[`WID_FILTER-1:0]		i5,
	 input	[`WID_FILTER-1:0]		i6,
	 input	[`WID_FILTER-1:0]		i7,
	 input	[`WID_FILTER-1:0]		i8,
	 input	[`WID_FILTER-1:0]		i9,
	 input	[`WID_FILTER-1:0]		i10,
	 input	[`WID_FILTER-1:0]		i11,
	 input	[`WID_FILTER-1:0]		i12,
	 input	[`WID_FILTER-1:0]		i13,
	 input	[`WID_FILTER-1:0]		i14,
	 input	[`WID_FILTER-1:0]		i15,
	 input	[`WID_FILTER-1:0]		i16,
	 input	[`WID_FILTER-1:0]		i17,
	 input	[`WID_FILTER-1:0]		i18,
	 output	[`WID_MAC_MULT-1:0]	o1,
	 output	[`WID_MAC_MULT-1:0]	o2,
	 output	[`WID_MAC_MULT-1:0]	o3,
	 output	[`WID_MAC_MULT-1:0]	o4,
	 output	[`WID_MAC_MULT-1:0]	o5,
	 output	[`WID_MAC_MULT-1:0]	o6,
	 output	[`WID_MAC_MULT-1:0]	o7,
	 output	[`WID_MAC_MULT-1:0]	o8,
	 output	[`WID_MAC_MULT-1:0]	o9
    );

reg	[`WID_MAC_MULT-1:0]	o1,o2,o3,o4,o5,o6,o7,o8,o9,o;
always@*
	begin
	o1 = i1+i2+i3+i4;
	end
endmodule
