`timescale 1ns / 1ps

///Matusa Sebastian-Nicolae 331AA

module maze(
	input									  clk,
	input [maze_width - 1:0]		  starting_col, starting_row, 	// indicii punctului de start
	input  								  maze_in, 								// ofera informatii despre punctul de coordonate [row, col]
	output reg [maze_width - 1:0]   row, col,	 							// selecteaza un rand si o coloana din labirint
	output reg							  maze_oe,								// output enable (activeaza citirea din labirint la randul si coloana date) - semnal sincron	
	output reg							  maze_we, 								// write enable (activeaza scrierea în labirint la randul si coloana date) - semnal sincron
	output reg							  done);		 							// iesirea din labirint a fost gasita; semnalul ramane activ 
	
	`define init					0
	`define choose_direction	1	
	`define right 					2
	`define up						3
	`define left					4
	`define down					5
	`define check_cell			6	
	`define back					7
	`define dir_move				8
		
	
	parameter maze_width = 6;       ///labirintul are dimensiune 64x64
	reg[maze_width-1:0] prev_row,prev_col;
	
	reg[3:0] state, next_state;
	
	reg[2:0] dir=0,prev_dir=0;       

	always @(posedge clk) begin
		if(!done) begin
			state<=next_state;
		end
	end

	always @(*) begin

		done = 0;
		maze_oe = 0;
		maze_we = 0;
		next_state = `init;

		case(state)
			
			`init: begin
				maze_we=1;     //marchez casuta actuala si salvez coordonatele de start
				row=starting_row;
				col=starting_col;
				next_state=`choose_direction;
			end
	
			`choose_direction: begin	
				
				case(dir)				// directiile de deplasare dir sunt memorate, se va urmari intotdeauna perete drept
					0:begin
						next_state=`up;
						dir=dir+1;
					end
					1:begin
						next_state=`left;
						dir=dir+1;
					end			
					2:begin
						next_state=`down;
						dir=dir+1;
					end		
					3:begin
						next_state=`right;	
						dir=dir+1;
					end
				endcase
			end
			
			`up: begin
				maze_oe=1;
			
				prev_dir=0;     // se retine valoarea anterioara a lui dir intr-o alta variabila
				prev_row=row;    // se retin coordonatele actuale în alte variabile
				prev_col=col;
				
				row=row-1;
				next_state=`check_cell;
			end
			
			`left: begin	
				maze_oe=1;
				
				prev_dir=1;
				prev_row=row;
				prev_col=col;
				
				col=col-1;
				next_state=`check_cell;
			end
			
			`down: begin
				maze_oe=1;
				
				prev_dir=2;
				prev_row=row;			
				prev_col=col;
				
				row=row+1;
				next_state=`check_cell;
			end
			
			`right: begin
				maze_oe=1;
				
				prev_dir=3;
				prev_row=row;			
				prev_col=col;
				
				col=col+1;
				next_state=`check_cell;
			end
			
			`check_cell: begin						//verific valoarea din coordonatele actuale
				if(maze_in==0) begin		// casuta libera, marchez pozitia actuala si merg mai departe
					maze_we=1; 		
					next_state=`dir_move;		
				end
				else begin  					 //perete , ma intorc la pozitia anterioara
					next_state=`back;
				end
			end
			
			`back: begin
				row=prev_row;   // ma intorc la coordonatele anterioare
				col=prev_col;
				if(dir==4) begin   ///resetez directia
					dir=0;
				end
				next_state=`choose_direction; 	//ma intorc la casuta anterioara si incerc urmatoare directie	
			end
			
			`dir_move:begin		
			
				dir=prev_dir;
				
				if(prev_row==row+1 && prev_col==col) begin		//verific peretele din drepta, directia de mers este in sus
					next_state=`right;
				end
				 if(prev_row==row-1 && prev_col==col) begin		//verific peretele din stanga, directia de mers este in jos
					next_state=`left;
				end
				 if(prev_row==row && prev_col==col+1) begin		//verific peretele de sus, directia de mers este in stanga
					next_state=`up;
				end
				if(prev_row==row && prev_col==col-1) begin		//verific peretele de jos, directia de mers este in dreapta
					next_state=`down;
				end

				if (row==0 || row==63 || col==0 || col==63) begin     ///verific daca am gasit iesirea din labirint
					done=1;
				end
				
			end
			
		endcase
		
	end
	
endmodule 