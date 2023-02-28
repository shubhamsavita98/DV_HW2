module my_mem_tb;
  
  logic clk, write, read;
  logic [7:0] data_in;
  logic [15:0] address;
  
  logic [8:0] data_out;
  
  //Initialize the memory model
  my_mem uut(.clk(clk), .write(write), .read(read), .data_in(data_in), .address(address), .data_out(data_out));
  
  // Starting clock ~ every 5ns
  always #5 clk=~clk;

  int error_count=0; //error count
  
  //dynamic array declaration
  bit [15:0] address_array[]; //dynamic array to store 16 bits of address
  bit [8:0] data_to_write_array[]; //dynamic array to store 9 bits of data
  //associative array
  bit [8:0] data_read_expect_assoc[int];
  //data read queue
  bit [8:0] data_read_queue[$];

  
  initial begin
    
    //intializing clk,read and write7
    clk=0; read=0; write=0;

    //initializing dynamic array
    address_array = new[6];
    data_to_write_array = new[6];
    
    //randomize addresses in address array
    for(int i=0; i<6; i++) begin
      address_array[i] = $random; //storing random address
      #1 $display("Address [%0d] = %0d",i, address_array[i]);
    end
    
    //randomize data in data array
    for(int j=0; j<6; j++) begin
      data_to_write_array[j] = $random; //storing random data
      #1 $display("Data [%0d] = %0d",j, data_to_write_array[j]);
    end
    
    //set write to 1 to start writing to memory
    write=1;

    for (int i = 0; i <= 5; i++)
    begin
      @(posedge clk);
      address = address_array[i];
      #5;
      data_in = data_to_write_array[i];
      #5;
    end
  
    @(negedge clk);
    write = 0;
    
    //associative array
    for(int k=0; k < 6; k++) begin
      data_read_expect_assoc[address_array[k]] = data_to_write_array[k];
      
    end
    
    @(posedge clk)
    read = 1;
    //compare data out with data read expected associative array
    //$display("data in data out found is %0d", data_out);
    //#20;
    $display("********* Starting Test*********");
    for(int i=5; i>=0; i--) begin
      $display(i);
      $display("Previous data out: %0d", data_out);
      #10;
      address = address_array[i];
      #10;
      $display("Address: %0d", address);
      $display("Data expected %0d", data_read_expect_assoc[address]);
      $display("Current data out %0d", data_out);
      data_read_queue.push_back(data_out); //adding data to queue
      if(data_out !== data_read_expect_assoc[address]) begin
        $display("Error!!");
        error_count = error_count + 1;
      end
      else begin
        $display("\ndata out %0d is equal to data expected.", data_out); 
        $display("\n Read Success! \n");
      end
    end

    $display("Total Error Count: %0d\n", error_count);
    $display("*************** End Test *************");
    
    $display("\n********* Traversing Queue *********");
    //traverse data read queue
    for(int i=0; i<=5; i++) begin
      //data_read_queue.push_back(data_out);
      $display("\tdata_read_queue[%0d]= %0d",i,data_read_queue[i]);
    end
    
    $finish;
  end
    
    initial begin
      $vcdplusmemon;
      $vcdpluson;
      $dumpfile("dump.vcd");
      $dumpvars;
    end
    
    
    endmodule