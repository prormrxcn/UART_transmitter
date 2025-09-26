`timescale 1ns / 1ps
/******************************************************************************/
/* Company: iist                                                              */
/* Engineer: daksh vaishnav                                                   */
/* Create Date: 09/22/2025 08:27:39 AM                                        */
/* Design Name: transmitter                                                   */
/* Module Name: UART                                                          */
/* Project Name: UART                                                         */
/* Target Devices: xc7a35tcpg236-1                                            */
/* Tool Versions: 2025.1                                                      */
/* Description: UART transmitter module with pipelined stages.                */
/*              Implements 10-bit frame (start, 8 data, stop),                */
/*              baud rate generator, and serial output.                       */
/* Dependencies: transmitter.v                                                */
/* Revision:                                                                  */
/* Revision 0.01 - File Created                                               */
/* Additional Comments:                                                       */
/******************************************************************************/


//[10-bit Frame Register] → [Shift Register] → [TX Output]
//         ↑                      ↑
//     [Load Control]        [Baud Rate Clock]
//         ↑                      ↑
//     [Enable Signal]      [Bit Counter (0-9)]
// UART Transmitter with Pipeline Stages
// Pipeline: [IDLE -> START -> DATA -> STOP]
module top_uart (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [7:0] datain,
    output wire serial_tx
);

    transmitter uart_tx (
        .clk(clk),  
        .rst(rst),
        .enable(enable),
        .data(datain), 
        .tx(serial_tx)
    );
endmodule

module transmitter(
    input clk,
    input rst,
    input enable,
    input [7:0] data,
    output reg tx
);

reg [3:0] bit_counter;
reg [13:0] counter;
reg state;
reg [9:0] shift_reg;

localparam BAUD_COUNT = 14'd10417;

always @(posedge clk) begin
    if (rst) begin
        state <= 0;
        counter <= 0;
        bit_counter <= 0;
        shift_reg <= 10'h3FF;
        tx <= 1'b1;
    end else begin
        case (state)
            0: begin
                tx <= 1'b1;
                if (enable) begin
                    state <= 1;
                    shift_reg <= {1'b1, data, 1'b0};
                    bit_counter <= 0;
                    counter <= 0;
                end
                else begin
                    state <= 0;
                end
            end
            
            1: begin
                counter <= counter + 1;
                
                if (counter >= BAUD_COUNT) begin
                    counter <= 0;
                    
                    if (bit_counter >= 10) begin
                        state <= 0;
                        tx <= 1'b1;
                    end else begin
                        tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        bit_counter <= bit_counter + 1;
                    end
                end
                else begin
                    state <= 1;
                end
            end
            default: state <= 0;
        endcase
    end
end
endmodule